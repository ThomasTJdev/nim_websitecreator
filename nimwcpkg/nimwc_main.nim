#        TTJ
#        (c) Copyright 2019 Thomas Toftgaard Jarløv
#        Look at LICENSE for more info.
#        All rights reserved.
when defined(windows):
  {.fatal: "Cannot run on Windows, but you can try Docker for Windows: http://docs.docker.com/docker-for-windows".}
{.passL: "-s".}  # Force strip all on the resulting Binary, so its smaller.

import
  asyncdispatch, bcrypt, cgi, jester, json, macros, os, osproc, logging, otp,
  parsecfg, random, re, recaptcha, sequtils, strutils, times, datetime2human,
  base32, streams, encodings, nativesockets, libravatar,
  oswalkdir as oc,

  resources/administration/create_adminuser,
  resources/administration/create_standarddata,
  resources/administration/createdb,
  resources/administration/help,
  resources/email/email_registration,
  resources/files/files_efs,
  resources/files/files_utils,
  resources/password/password_generate,
  resources/password/salt_generate,
  resources/session/user_data,
  resources/utils/logging_nimwc,
  resources/utils/plugins,
  resources/web/google_recaptcha

from md5 import getMD5
from strtabs import newStringTable, modeStyleInsensitive
from packages/docutils/rstgen import rstToHtml

when defined(postgres): import db_postgres
else:                   import db_sqlite

when not defined(webp): {. warning: "WebP is Disabled, No Image Optimizations." .}
else:                   from webp import cwebp

when not defined(firejail): {. warning: "Firejail is Disabled, Running Unsecure." .}
else:                       from firejail import firejailVersion, firejailFeatures


const
  config_not_found_msg = """
  🐛 ERROR: Config file (config.cfg) could not be found. 🐛
  A template (config_default.cfg) is copied to "config/config.cfg".
  Please configure it and restart Nim Website Creator. Bye. """

  startup_msg = """
  Package:      Nim Website Creator - https://NimWC.org
  Description:  Self-Firejailing Nim Web Framework thats simple to use.
  Author name:  Thomas Toftgaard Jarløv (TTJ) & Juan Carlos (http://github.com/juancarlospaco)"""

  checkCompileOptions* = ["",
    when defined(adminnotify): " -d:adminnotify",
    when defined(dev):         " -d:dev",
    when defined(devemailon):  " -d:devemailon",
    when defined(demo):        " -d:demo",
    when defined(ssl):         " -d:ssl",
    when defined(postgres):    " -d:postgres",
    when defined(webp):        " -d:webp",
    when defined(firejail):    " -d:firejail",
    when defined(release):     " -d:release"
  ].join  ## Checking for known compile options and returning them as a space separated string.
  # Used within plugin route, where a recompile is required to include/exclude a plugin.

  sql_now =
    when defined(postgres): "(extract(epoch from now()))" # Postgres epoch.
    else:                   "(strftime('%s', 'now'))"     # SQLite 3 epoch.


macro configExists(): untyped =
  ## Macro to check if the config file is present
  let dir = parentDir(currentSourcePath())
  if not fileExists(replace(dir, "/nimwcpkg", "") & "/config/config.cfg"):
    echo config_not_found_msg
    discard staticExec("cp " & dir & "/config/config_default.cfg " & dir & "/config/config.cfg")
    quit()

configExists()
randomize()

#
# Macros
#


proc getPluginsPath*(): seq[string] {.compileTime.} =
  ## Get all plugins path
  ##
  ## Generates a seq[string] with the path to the plugins
  let
    dir = parentDir(currentSourcePath())
    realPath = replace(dir, "/nimwcpkg", "")

  var
    plugins = (staticRead(realPath & "/plugins/plugin_import.txt").split("\n"))
    extensions: seq[string]

  # Loop through all files and folders
  for plugin in oc.walkDir("plugins/"):
    let (pd, ppath) = plugin
    discard pd

    # If the path matches a name in the plugin_import.txt
    if replace(ppath, "plugins/", "") in plugins:
      if extensions.len() == 0:
        extensions = @[realPath & "/" & ppath]
      else:
        extensions.add(realPath & "/" & ppath)

  return extensions

let pluginsPath = getPluginsPath()


macro extensionImport(): untyped =
  ## Macro to import plugins
  ##
  ## Generate code for importing modules from extensions.
  ## The extensions main module needs to be in plugins/plugin_import.txt
  ## to be activated. Only 1 module will be imported.
  var extensions = ""
  for ppath in pluginsPath:
    let splitted = split(ppath, "/")
    extensions.add("import " & ppath & "/" & splitted[splitted.len-1] & "\n")

  when defined(dev):
    echo "Plugins - imports:\n" & $extensions

  result = parseStmt(extensions)

extensionImport()


macro extensionUpdateDatabase(): untyped =
  ## Macro to generate proc for plugins init proc
  ##
  ## Generate proc for updating the database with new tables etc.
  ## The extensions main module shall contain a proc named 'proc <extensionname>Start(db: DbConn) ='
  ## The proc will be executed when the program is executed.
  var extensions = ""

  extensions.add("proc extensionUpdateDB*(db: DbConn) =\n")
  if pluginsPath.len == 0:
    extensions.add("  discard")

  else:
    for ppath in pluginsPath:
      let splitted = split(ppath, "/")
      extensions.add("  " & splitted[splitted.len-1] & "Start(db)\n")

    extensions.add("  echo \" \"")

  when defined(dev):
    echo "Plugins - required proc:\n" & $extensions

  result = parseStmt(extensions)

extensionUpdateDatabase()


macro extensionCss(): string =
  ## Macro with 2 functions
  ##
  ## 1) Copy the plugins style.css to the public css/ folder and
  ## renaming to <extensionname>.css
  ##
  ## 2) Insert <style>-link into HTML
  let dir = parentDir(currentSourcePath())
  let mainDir = $replace(dir, "/nimwcpkg", "")

  var extensions = ""
  for ppath in pluginsPath:
    let splitted = split(ppath, "/")

    if staticRead(ppath & "/public/style.css") != "":
      discard staticExec("cp " & ppath & "/public/style.css " & mainDir & "/public/css/" & splitted[splitted.len - 1] & ".css")
      extensions.add("<link rel=\"stylesheet\" href=\"/css/" & splitted[splitted.len - 1] & ".css\">\n")

    if staticRead(ppath & "/public/style_private.css") != "":
      discard staticExec("cp " & ppath & "/public/style_private.css " & mainDir & "/public/css/" & splitted[splitted.len-1] & "_private.css")

  when defined(dev):
    echo "Plugins - CSS:\n" & $extensions
  return extensions


macro extensionJs*(): string =
  ## Macro with 2 functions
  ##
  ## 1) Copy the plugins js.js to the public js/ folder and
  ## renaming to <extensionname>.js
  ##
  ## 2) Insert <js>-link into HTML
  let dir = parentDir(currentSourcePath())
  let mainDir = replace(dir, "/nimwcpkg", "")

  var extensions = ""
  for ppath in pluginsPath:
    let splitted = split(ppath, "/")

    if staticRead(ppath & "/public/js.js") != "":
      discard staticExec("cp " & ppath & "/public/js.js " & mainDir & "/public/js/" & splitted[splitted.len-1] & ".js")
      extensions.add("<script src=\"/js/" & splitted[splitted.len-1] & ".js\" defer></script>\n")

    if staticRead(ppath & "/public/js_private.js") != "":
      discard staticExec("cp " & ppath & "/public/js_private.js " & mainDir & "/public/js/" & splitted[splitted.len-1] & "_private.js")

  when defined(dev):
    echo "Plugins - JS:\n" & $extensions
  return extensions


#
# Loading config file
#


var db {.global.}: DbConn

let
  dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")

  db_user   = dict.getSectionValue("Database", "user")
  db_pass   = dict.getSectionValue("Database", "pass")
  db_name   = dict.getSectionValue("Database", "name")
  db_host   = dict.getSectionValue("Database", "host")
  db_port   = Port(dict.getSectionValue("Database", "port").parseInt)

  mainURL   = dict.getSectionValue("Server", "url")
  mainPort  = parseInt dict.getSectionValue("Server", "port")
  mainWebsite = dict.getSectionValue("Server", "website")

  proxyURL  = dict.getSectionValue("Proxy", "url")
  proxyPath = dict.getSectionValue("Proxy", "path")

  logfile =
    when defined(release): dict.getSectionValue("Logging", "logfile")
    else:                  dict.getSectionValue("Logging", "logfiledev")


# Jester setting server settings
settings:
  port = Port(mainPort)
  bindAddr = mainURL


proc init(c: var TData) =
  ## Empty out user session data
  c.userpass = ""
  c.username = ""
  c.userid   = ""
  c.timezone = ""
  c.rank     = NotLoggedin
  c.loggedIn = false


#
# Recompile
#


proc recompile*(): int {.inline.} =
  ## Recompile nimwc_main
  let outp = execCmd("nim c " & checkCompileOptions & " -o:" & getAppDir() & "/nimwc_main_new_tmp " & getAppDir() & "/nimwc_main.nim")
  moveFile(getAppDir() & "/nimwc_main_new_tmp", getAppDir() & "/nimwc_main_new")
  return outp

#
# Validation check
#


func loggedIn(c: TData): bool {.inline.} =
  ## Check if user is logged in by verifying that c.username is more than 0:int
  c.username.len > 0


#
# Check if user is signed in
#


proc checkLoggedIn(c: var TData) =
  ## Check if user is logged in
  if not c.req.cookies.hasKey("sid"): return
  let sid = c.req.cookies["sid"]
  if execAffectedRows(db, sql("UPDATE session SET lastModified = " & $toInt(epochTime()) & " " & "WHERE ip = ? AND key = ?"), c.req.ip, sid) > 0:

    c.userid = getValue(db, sql"SELECT userid FROM session WHERE ip = ? AND key = ?", c.req.ip, sid)

    let row = getRow(db, sql("SELECT name, email, status FROM person WHERE id = ?"), c.userid)
    c.username  = row[0]
    c.email     = toLowerAscii(row[1])
    c.rank      = parseEnum[Rank](row[2])
    if c.rank notin [Admin, Moderator, User]:
      c.loggedIn = false

    discard tryExec(db, sql("UPDATE person SET lastOnline = ? WHERE id = ?"), toInt(epochTime()), c.userid)

  else:
    c.loggedIn = false


#
# User login
#


proc login(c: var TData, email, pass, totpRaw: string): tuple[b: bool, s: string] =
  ## User login
  when not defined(demo):
    if email == "test@test.com":
      return (false, "Email must not be test@test.com.")
  if email.len == 0 or pass.len == 0:
    return (false, "Empty password or username")

  const query = sql"SELECT id, name, password, email, salt, status, secretUrl, twofa FROM person WHERE email = ? AND status <> 'Deactivated'"

  for row in fastRows(db, query, toLowerAscii(email)):
    # Check that password matches
    if row[2] == makePassword(pass, row[4], row[2]):

      # Check if email has been confirmed
      if row[6] != "":
        info("Login failed. Account not activated")
        return (false, "Your account is not activated. Please click on the confirmation link on your email.")

      # Check user status, e.g. Deactivated
      if parseEnum[Rank](row[5]) notin [Admin, Moderator, User]:
        info("Login failed. Your account is not active.")
        return (false, "Your account is not active")

      # If an OTP key is present
      if row[7].len() != 0:
        if totpRaw == "" or not isDigit(totpRaw):
          return (false, "Insert your 2 Factor Authentication code")

        let totp = parseInt(totpRaw)
        if totp in [000000, 111111, 222222, 333333, 444444, 555555, 666666, 777777, 888888, 999999]:
          return (false, "2 Factor Authentication Number must not be 6 identical digits")

        let totpServerSide = $newTotp(row[7]).now()
        when not defined(release):
          echo "TOTP SERVER: " & totpServerSide
          echo "TOTP USER  : " & $totp
        if $totp != totpServerSide and not defined(demo):
          info("Login failed. 2 Factor Authentication number is invalid or expired.")
          return (false, "2 Factor Authentication number is invalid or expired")

      c.userid   = row[0]
      c.username = row[1]
      c.userpass = row[2]
      c.email    = toLowerAscii(row[3])
      c.rank     = parseEnum[Rank](row[5])

      let key = makeSessionKey()
      exec(db, sql"INSERT INTO session (ip, key, userid) VALUES (?, ?, ?)", c.req.ip, key, row[0])

      info("Login successful")
      return (true, key)

  info("Login failed")
  return (false, "Login failed")


proc logout(c: var TData) =
  ## Logout
  const query = sql"DELETE FROM session WHERE ip = ? AND key = ?"
  c.username = ""
  c.userpass = ""
  exec(db, query, c.req.ip, c.req.cookies["sid"])


#
# Check if logged in
#


template createTFD() =
  ## Check if logged in and assign data to user
  var c {.inject.}: TData
  new(c)
  init(c)
  c.req = request
  if request.cookies.len > 0:
    checkLoggedIn(c)
  c.loggedIn = loggedIn(c)


#
# HTML tools
#


template notifyHtml*(message: string, title="NimWC 👑", iconUrl="/favicon.ico", timeout: byte = 3): string =
  "Notification.requestPermission(()=>{const n=new Notification('" & title & "',{body:'" & message.strip & "',icon:'" & iconUrl & "'});setTimeout(()=>{n.close()}," & $timeout & "000)});"


template minifyHtml*(htmlstr: string): string =
  when defined(release): replace(htmlstr, re">\s+<", "> <").strip else: htmlstr


template rst2html*(stringy: string): string =
  ## RST/MD to HTML using std lib.
  try:
    rstToHtml(stringy.strip, {}, newStringTable(modeStyleInsensitive))
  except:
    stringy


template checkboxToInt(checkboxOnOff: string): string =
  ## When posting checkbox data from HTML form
  ## an "on" is sent when true. Convert to 1 or 0.
  if checkboxOnOff == "on": "1" else: "0"


template checkboxToChecked(checkboxOnOff: string): string =
  ## When parsing DB data on checkboxes convert
  ## 1 or 0 to HTML checked to set checkbox
  if checkboxOnOff == "1": "checked" else: ""


template statusIntToText(status: string): string =
  ## When parsing DB status convert 0, 1 and 3 to human names
  case status
  of "0": "Development"
  of "1": "Private"
  of "2": "Public"
  else:   "Error"


template statusIntToCheckbox(status, value: string): string =
  ## When parsing DB status convert to HTML selected on selects
  if status == "0" and value == "0":
    "selected"
  elif status == "1" and value == "1":
    "selected"
  elif status == "2" and value == "2":
    "selected"
  else:
    ""


#
# Main module
#


when isMainModule:
  echo startup_msg
  # Show commandline help info
  if "help" in commandLineParams():
    echo commandLineHelp()
    quit()
  randomize()

  # Storage location. Folders are created in the module files_efs.nim
  when not defined(ignoreefs) and defined(release):
    # Check access to EFS file system
    info("Checking storage access.")
    if not existsDir(storageEFS):
      fatal("isMainModule: No access to storage in release mode. Critical.")
      sleep(2_000)
      quit()

  # Generate DB
  if "newdb" in commandLineParams() or not fileExists(db_host):
    generateDB()

  # Connect to DB
  let dbconnection =
    when defined(postgres): "host=" & $db_host & " port=" & $db_port & " dbname=" & $db_name & " user=" & $db_user & " password=" & $db_pass & " connect_timeout=9"
    else: db_host
  db =
    when defined(postgres): db_postgres.open("", "", "", dbconnection)
    else:                   db_sqlite.open(dbconnection, "", "", "")
  assert db is DbConn, "Connection to DB could not be established, failed to open Database."
  info("Connection to DB is established.")

  # Add admin user
  if "newuser" in commandLineParams():
    createAdminUser(db, commandLineParams())

  # When Demo Mode, Reset everything at start, create Test User, create Test Data, for use with Firejail `timeout=1`
  when defined(demo):
    {. hint: "Demo is Enabled, Database Resets Automatically every hour." .}
    const resetSql = sql"DELETE FROM session; DELETE FROM pages; DELETE FROM blog; DELETE FROM files; DELETE FROM person"
    exec(db, resetSql)      # Reset everything
    createTestUser(db)      # Recreate Demo user
    createStandardData(db)  # Recreate Demo Data (Pages & Blogs)
    # doAssert dict.getSectionValue("firejail", "timeout") == "1", "Firejail Timeout must be 1"
    info("Demo Mode: Database reset successful")

  # Activate Google reCAPTCHA
  setupReCapthca()

  # Update sql database from extensions
  extensionUpdateDB(db)

  # Insert standard data
  if "insertdata" in commandLineParams():
    echo "\nInsert standard data?"
    echo "This will override existing data (y/N):"
    if readLine(stdin).string.strip.toLowerAscii == "y":
      if "bootstrap" in commandLineParams():
        createStandardData(db, "bootstrap")
      elif "clean" in commandLineParams():
        createStandardData(db, "clean")
      else:
        createStandardData(db, "bulma")

  # Create robots.txt
  writeFile("public/robots.txt", "User-agent: *\nSitemap: " & mainWebsite & "/sitemap.xml")

  # Check if custom js and css exists
  if not fileExists("public/css/style_custom.css"):
    writeFile("public/css/style_custom.css", "")
  if not fileExists("public/js/js_custom.js"):
    writeFile("public/js/js_custom.js", "")
  info("Up and running!.")


#
# Include HTML files
#


include "tmpl/utils.tmpl"
include "tmpl/blog.tmpl"
include "tmpl/blogedit.tmpl"
include "tmpl/blognew.tmpl"
include "tmpl/files.tmpl"
include "tmpl/page.tmpl"
include "tmpl/pageedit.tmpl"
include "tmpl/pagenew.tmpl"
include "tmpl/settings.tmpl"
include "tmpl/plugins.tmpl"
include "tmpl/user.tmpl"
include "tmpl/main.tmpl"
include "tmpl/sitemap.tmpl"
include "tmpl/logs.tmpl"
include "tmpl/serverinfo.tmpl"
include "tmpl/editconfig.tmpl"
include "tmpl/delayredirect.tmpl"
when defined(firejail): include "tmpl/firejail.tmpl"


#
# Routes for WWW
#


template restrictTestuser(httpMethod: HttpMethod) =
  ## Check if this is the testuser. If it is true, return
  ## error message based on HTTP method (GET/POST).
  ##
  ## It is possible to override the method with the param
  ## httpMeth.
  when defined(demo):
    if c.loggedIn and c.rank != Admin:
      if httpMethod == HttpPost:
        resp("Error: The test user does not have access to this area")
      else:
        redirect("/error/" & encodeUrl("Error: The test user does not have access to this area"))


template restrictAccessTo(c: var TData, ranks: varargs[Rank]) =
  if not c.loggedIn or c.rank notin ranks:
    if c.req.reqMethod == HttpGet:
      redirect("/")
    else:
      resp(Http404, "")


macro generateRoutes(): typed =
  ## The macro generates the routes for Jester.
  ## Routes are found in the resources/web/routes.nim.
  ## All plugins 'routes.nim' are also included.
  var extensions = staticRead("resources/web/routes.nim")

  for ppath in pluginsPath:
    extensions.add("\n\n" & staticRead(ppath & "/routes.nim"))
  # when not compiles(parseStmt(extensions)): {.fatal:"Plugin Route Error, remove or fix the Plugin.".}
  when defined(dev):
    echo extensions
  result = parseStmt(extensions)


generateRoutes()
