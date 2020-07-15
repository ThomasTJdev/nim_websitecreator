import
  asyncdispatch, base32, cgi, encodings, logging, md5, nativesockets, os,
  osproc, parsecfg, random, re, rdstdin, sequtils, streams, strtabs,
  strutils, tables, times, macros, mimetypes, packages/docutils/rstgen

import bcrypt, jester, otp

import
  constants/constants, enums/enums, databases/databases, emails/emails, files/files, utils/utils,
  passwords/passwords, sessions/sessions, utils/loggers, plugins/plugins, webs/html_utils

when defined(postgres): import db_postgres
else:                   import db_sqlite

when not defined(webp): {. warning: "WebP is disabled, no image optimizations possible." .}
when not defined(firejail): {. warning: "Firejail is disabled, running unsecure." .}
else:                       from firejail import firejailVersion, firejailFeatures

when defined(packedjson): import packedjson
else: import json

hardenedBuild()
randomize()


#
# Macros
#


proc getPluginsPath*(): seq[string] {.compileTime.} =
  ## Get all plugins path
  ##
  ## Generates a seq[string] with the path to the plugins
  const
    realPath = replace(parentDir(currentSourcePath()), "/nimwcpkg", "")
    plugins = staticRead(realPath & "/plugins/plugin_import.txt").splitLines
  # Loop through all files and folders
  for plugin in walkDir("plugins/"):
    let (_, ppath) = plugin
    # If the path matches a name in the plugin_import.txt
    if replace(ppath, "plugins/", "") in plugins:
      result.add realPath & "/" & ppath

const pluginsPath = getPluginsPath()


macro extensionImport() =
  ## Macro to import plugins
  ##
  ## Generate code for importing modules from extensions.
  ## The extensions main module needs to be in plugins/plugin_import.txt
  ## to be activated. Only 1 module will be imported.
  when pluginsPath.len > 0:
    result = newStmtList()
    for it in pluginsPath:
      let splitted = split(it, "/")
      let module = it / splitted[splitted.len - 1]
      result.add quote do:
        import `module`
  else: discard # Error: implementation of 'extensionImport' expected.

extensionImport()


macro extensionUpdateDatabase(procs: static[seq[string]]) =
  ## Macro to generate proc for plugins init proc.
  ## Generate proc for updating the database with new tables etc.
  ## The extensions main module shall contain a proc named 'proc <extensionname>Start(db: DbConn) ='
  result = newStmtList()
  for it in procs:
    let function = newIdentNode(it & "Start") # pluginStart
    let database = newIdentNode("db")         # db
    result.add newCall(function, database)    # pluginStart(db)


proc extensionCss(): string {.compiletime.} =
  ## Macro with 2 functions
  ##
  ## 1) Copy the plugins style.css to the public css/ folder and
  ## renaming to <extensionname>.css
  ##
  ## 2) Insert <style>-link into HTML
  let dir = parentDir(currentSourcePath())
  let mainDir = replace(dir, "/nimwcpkg", "")

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


proc extensionJs*(): string {.compiletime.} =
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
      extensions.add("<script src=\"/js/" & splitted[splitted.len-1] & ".js\" defer ></script>\n")

    if staticRead(ppath & "/public/js_private.js") != "":
      discard staticExec("cp " & ppath & "/public/js_private.js " & mainDir & "/public/js/" & splitted[splitted.len-1] & "_private.js")

  when defined(dev):
    echo "Plugins - JS:\n" & $extensions
  return extensions


#
# Loading config file
#


var db {.global.}: DbConn
assert existsFile(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg"), "config.cfg not found"
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

  stdLang   = dict.getSectionValue("Language", "standardLang")

  logfile =
    when defined(release): dict.getSectionValue("Logging", "logfile")
    else:                  dict.getSectionValue("Logging", "logfiledev")


# Jester setting server settings
settings:
  port = Port(mainPort)
  bindAddr = mainURL


func init(c: var TData) {.inline.} =
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
  let appName = dict.getSectionValue("Server", "appname")
  let appPath = getAppDir() / appName
  result = execCmd("nim c " & compileOptions & " -o:" & appPath & "_new_tmp " & getAppDir() & "/nimwc_main.nim")
  when defined(release):
    if result == 0 and findExe"strip".len > 0: discard execCmd(cmdStrip & appPath & "_new_tmp")
  moveFile(getAppDir() & "/" & appName & "_new_tmp", getAppDir() & "/" & appName & "_new")


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

    let row = getRow(db, sql"SELECT name, email, status FROM person WHERE id = ?", c.userid)
    c.username  = row[0]
    c.email     = toLowerAscii(row[1])
    c.rank      = parseEnum[Rank](row[2])
    if c.rank notin [Admin, Moderator, User]:
      c.loggedIn = false

    discard tryExec(db, sql"UPDATE person SET lastOnline = ? WHERE id = ?", toInt(epochTime()), c.userid)

  else:
    c.loggedIn = false


#
# User login
#


proc login(c: var TData, email, pass, totpRaw: string): tuple[isLoginOk: bool, statusMessage: string] =
  ## User login
  when not defined(demo):
    if email == "test@test.com":
      return (false, "Email must not be test@test.com")
  if unlikely(email.len == 0 and pass.len == 0 and totpRaw.len == 0):
    return (false, "Username, password and 2 Factor Authentication are all empty")
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
        if totpRaw == "":
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


proc logout(c: var TData) {.inline.} =
  exec(db, sql"DELETE FROM session WHERE ip = ? AND key = ?", c.req.ip, c.req.cookies["sid"])
  c.username = ""
  c.userpass = ""


#
# Check if logged in
#


template createTFD() =
  ## Check if logged in and assign data to user
  var c {.inject.}: TData
  new(c)
  init(c)
  c.req = request
  if likely(request.cookies.len > 0):  # Make it faster for Logged-in Users.
    checkLoggedIn(c)
  c.loggedIn = loggedIn(c)


#
# Main module
#


when isMainModule:
  echo startup_msg

  # Connect to DB
  let dbconnection =
    when defined(postgres): "host=" & $db_host & " port=" & $db_port & " dbname=" & $db_name & " user=" & $db_user & " password=" & $db_pass & " connect_timeout=9"
    else: db_host

  db =
    when defined(postgres): db_postgres.open("", "", "", dbconnection)
    else:                   db_sqlite.open(dbconnection, "", "", "")

  assert db is DbConn, "Connection to DB could not be established, failed to open Database."
  info("Connection to DB is established.")

  # When Demo Mode, Reset everything at start, create Test User, create Test Data, for use with Firejail `timeout=1`
  when defined(demo):
    {. hint: "Demo is Enabled, reverting demo users changes." .}
    const sqlDeleteBlogTestuser = sql"""DELETE FROM blog;
    DELETE FROM person WHERE name = 'Testuser' AND email = 'test@test.com';"""
    exec(db, sqlDeleteBlogTestuser)  # Delete blogposts
    standardDataBlogpost1(db)         # Add blogpost 1
    standardDataBlogpost2(db)         # Add blogpost 2
    standardDataBlogpost3(db)         # Add blogpost 3
    createTestUser(db)                # Add Test user
    info("Demo Mode: Database reverted to default")

  # Update sql database from extensions
  extensionUpdateDatabase(pluginsPath)

  # Insert standard data
  if "insertdata" in commandLineParams() and readLineFromStdin(
    "Insert standard data?\nThis will override existing data! (y/n):").normalize == "y":
    if "water" in commandLineParams():    createStandardData(db, cssWater)
    elif "official" in commandLineParams(): createStandardData(db, cssOfficial)
    else:                                   createStandardData(db, cssBulma)

  # If user has provided arguments then quit
  if commandLineParams().len != 0:
    quit()

  # Create robots.txt
  writeFile("public/robots.txt", "User-agent: *\nSitemap: " & mainWebsite & "/sitemap.xml")

  # Check if custom js and css exists
  if not fileExists("public/css/style_custom.css"):
    writeFile("public/css/style_custom.css", "")
  if not fileExists("public/js/js_custom.js"):
    writeFile("public/js/js_custom.js", "")

  info("Up and running!")


#
# Include HTML files
#
include nimfs/nimfs

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
      else:  # encodeUrl() the string.
        redirect("/error/Error%3A+The+test+user+does+not+have+access+to+this+area")


template restrictAccessTo(c: var TData, ranks: varargs[Rank]) =
  if not c.loggedIn or c.rank notin ranks:
    if c.req.reqMethod == HttpGet:
      redirect("/")
    else:
      resp(Http404, "")


macro generateRoutes() =
  ## The macro generates the routes for Jester.
  ## Routes are found in the webs/routes.nim.
  ## All plugins "routes.nim" are also included.
  var extensions = staticRead("webs/routes.nim")

  for ppath in pluginsPath:
    extensions.add("\n\n" & staticRead(ppath & "/routes.nim"))
  # when not compiles(parseStmt(extensions)): {.fatal:"Plugin Route Error, remove or fix the Plugin.".}
  when defined(dev):
    echo extensions
  result = parseStmt(extensions)


generateRoutes()
