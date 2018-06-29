#
#
#        TTJ
#        (c) Copyright 2018 Thomas Toftgaard Jarløv
#        Look at LICENSE for more info.
#        All rights reserved.
#
#

import
  asyncdispatch, 
  asyncfile, 
  asyncnet, 
  bcrypt, 
  cgi, 
  db_sqlite, 
  jester, 
  json, 
  macros, 
  md5, 
  os, 
  osproc,
  parsecfg, 
  parseutils, 
  random, 
  rdstdin, 
  re, 
  recaptcha, 
  sequtils, 
  strtabs, 
  strutils,
  times,
  oswalkdir as oc

import cookies as libcookies

#setCurrentDir(getAppDir().replace("/nimwcpkg", "") & "/")
#echo getCurrentDir()

macro configExists(): untyped =
  ## Macro to check if the config file is present
  let (dir, name, file) = splitFile(currentSourcePath())
  discard name 
  discard file

  if not fileExists(replace(dir, "/nimwcpkg", "") & "/config/config.cfg"):
    echo "\nERROR: Config file (config.cfg) could not be found."
    echo "A copy of the template (config_default.cfg) has been"
    echo "copied to config/config.cfg."
    echo " "
    echo "The program will now quit. Please configure it"
    echo "and restart the program."
    echo " "

    discard staticExec("cp " & dir & "/config/config_default.cfg " & dir & "/config/config.cfg")

    quit()

configExists()


import resources/administration/create_adminuser
import resources/administration/create_standarddata
import resources/administration/createdb
import resources/administration/help
import resources/email/email_registration
import resources/files/files_efs
import resources/files/files_utils
import resources/password/password_generate
import resources/password/salt_generate
import resources/session/user_data
import resources/utils/dates
import resources/utils/logging
import resources/utils/plugins
import resources/utils/random_generator
import resources/web/google_recaptcha
import resources/web/urltools


#setCurrentDir(getAppDir())


when defined(windows):
  echo "\nWindows is not supported\n"
  quit()



proc getPluginsPath*(): seq[string] {.compileTime.} =
  
  let (dir, name, file) = splitFile(currentSourcePath())
  discard name 
  discard file
  let realPath = replace(dir, "/nimwcpkg", "")

  var plugins = (staticRead(realPath & "/plugins/plugin_import.txt").split("\n"))

  var extensions: seq[string]
  for plugin in oc.walkDir("plugins/"):
    let (pd, ppath) = plugin
    discard pd
  
    if ppath in plugins:
      if extensions.len() == 0:
        extensions = @[realPath & "/" & ppath]
      else:
        extensions.add(realPath & "/" & ppath)

  return extensions




macro extensionImport(): untyped =
  ## Macro to import plugins
  ##
  ## Generate code for importing modules from extensions.
  ## The extensions main module needs to be in plugins/plugin_import.txt
  ## to be activated. Only 1 module will be imported.

  var extensions = ""
  for ppath in getPluginsPath():
    let splitted = split(ppath, "/")
    extensions.add("import " & ppath & "/" & splitted[splitted.len-1] & "\n")
    
  when defined(dev):
    echo "Plugins - imports:"
    echo extensions
  
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
  if getPluginsPath().len == 0:
    extensions.add("  discard")

  else:
    for ppath in getPluginsPath():
      let splitted = split(ppath, "/")
      extensions.add("  " & splitted[splitted.len-1] & "Start(db)\n")
    
    extensions.add("  echo \" \"")

  when defined(dev):
    echo "Plugins - required proc:"
    echo extensions

  result = parseStmt(extensions)

extensionUpdateDatabase()


macro extensionCss(): string =
  ## Macro with 2 functions
  ##
  ## 1) Copy the plugins style.css to the public css/ folder and
  ## renaming to <extensionname>.css
  ##
  ## 2) Insert <style>-link into HTML

  let (dir, name, file) = splitFile(currentSourcePath())
  discard name 
  discard file
  let mainDir = replace(dir, "nimwcpkg", "")
  

  var extensions = ""
  for ppath in getPluginsPath():
    let splitted = split(ppath, "/")

    if staticRead(ppath & "/public/style.css") != "":
      discard staticExec("cp " & ppath & "/public/style.css " & mainDir & "/public/css/" & splitted[splitted.len-1] & ".css")

      extensions.add("<link rel=\"stylesheet\" href=\"/css/" & splitted[splitted.len-1] & ".css\">\n")

    if staticRead(ppath & "/public/style_private.css") != "":
      discard staticExec("cp " & ppath & "/" & "/public/style_private.css " & mainDir & "/public/css/" & splitted[splitted.len-1] & "_private.css")
    
  when defined(dev):
    echo "Plugins - CSS:"
    echo extensions

  return extensions


macro extensionJs*(): string =
  ## Macro with 2 functions
  ##
  ## 1) Copy the plugins js.js to the public js/ folder and
  ## renaming to <extensionname>.js
  ##
  ## 2) Insert <js>-link into HTML

  let (dir, name, file) = splitFile(currentSourcePath())
  discard name 
  discard file
  let mainDir = replace(dir, "nimwcpkg", "")

  var extensions = ""
  for ppath in getPluginsPath():
    let splitted = split(ppath, "/")

    if staticRead(ppath & "/public/js.js") != "":
      discard staticExec("cp " & ppath & "/public/js.js " & mainDir & "/public/js/" & splitted[splitted.len-1] & ".js")

      extensions.add("<script src=\"/js/" & splitted[splitted.len-1] & ".js\" defer></script>\n")

    if staticRead(ppath & "/public/js_private.js") != "":
      discard staticExec("cp " & ppath & "/public/js_private.js " & mainDir & "/public/js/" & splitted[splitted.len-1] & "_private.js")

  when defined(dev):
    echo "Plugins - JS:"
    echo extensions

  return extensions




#[ 
      Defining variables
__________________________________________________]#
macro readCfgAndBuildSource*(cfgFilename: string): typed =
  ## Generate constans with macro from configStatic file

  let inputString = slurp(cfgFilename.strVal)
  var source = ""
  
  for line in inputString.splitLines:
    # Ignore empty lines
    if line.len < 1 and line.substr(0, 0) != "[": continue
    var chunks = split(line, " = ")
    #if chunks.len != 2: continue
    if chunks.len != 2:
      continue
    
    source &= "const cfg" & chunks[0] & "= \"" & chunks[1] & "\"\n"

  if source.len < 1: error("Input file empty!")

  when defined(dev):
    echo "Constant vars compiled from configStatic.cfg:"
    echo source

  result = parseStmt(source)

readCfgAndBuildSource("config/configStatic.cfg")


var db: DbConn
  
let dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")

let db_user = dict.getSectionValue("Database","user")
let db_pass = dict.getSectionValue("Database","pass")
let db_name = dict.getSectionValue("Database","name")
let db_host = dict.getSectionValue("Database","host")

let mainURL   = dict.getSectionValue("Server","url")
let mainPort  = parseInt dict.getSectionValue("Server","port")

let proxyURL  = dict.getSectionValue("Proxy","url")
let proxyPath = dict.getSectionValue("Proxy","path")

when defined(release):
  let logfile = dict.getSectionValue("Logging","logfile")
when not defined(release):
  let logfile = dict.getSectionValue("Logging","logfiledev")




# Jester setting server settings
settings:
  port = Port(mainPort)
  bindAddr = mainURL



proc init(c: var TData) =
  ## Empty out user session data
  c.userpass      = ""
  c.username      = ""
  c.userid        = ""
  c.timezone      = ""
  c.rank          = NotLoggedin
  c.loggedIn      = false


    

#[ 
      Validation check
__________________________________________________]#
proc loggedIn(c: TData): bool =
  ## Check if user is logged in
  ## by verifying that c.username is more than 0:int

  result = c.username.len > 0




#[ 
      Check if user is signed in
__________________________________________________]#

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



#[ 
      User login
__________________________________________________]#

proc login(c: var TData, email, pass: string): tuple[b: bool, s: string] =
  ## User login

  when not defined(demo):
    if email == "test@test.com":
      return (false, "Email may not be test@test.com")

  const query = sql"SELECT id, name, password, email, salt, status, secretUrl FROM person WHERE email = ? AND status <> 'Deactivated'"
  if email.len == 0 or pass.len == 0:
    return (false, "Missing password or username")

  for row in fastRows(db, query, toLowerAscii(email)):
    if row[6] != "":
      dbg("INFO", "Login failed. Account not activated")
      return (false, "Your account is not activated")

    if parseEnum[Rank](row[5]) notin [Admin, Moderator, User]:
      dbg("INFO", "Login failed. Your account is not active.")
      return (false, "Your account is not active")

    if row[2] == makePassword(pass, row[4], row[2]):
      c.userid   = row[0]
      c.username = row[1]
      c.userpass = row[2]
      c.email    = toLowerAscii(row[3])
      c.rank     = parseEnum[Rank](row[5])

      let key = makeSessionKey()
      exec(db, sql"INSERT INTO session (ip, key, userid) VALUES (?, ?, ?)", c.req.ip, key, row[0])
      
      dbg("INFO", "Login successful")
      return (true, key)

  dbg("INFO", "Login failed")
  return (false, "Login failed")



proc logout(c: var TData) =
  ## Logout

  const query = sql"DELETE FROM session WHERE ip = ? AND key = ?"
  c.username = ""
  c.userpass = ""
  exec(db, query, c.req.ip, c.req.cookies["sid"])







#[ 
      Check if logged in
__________________________________________________]#
template createTFD() =
  ## Check if logged in and assign data to user

  var c {.inject.}: TData
  new(c)
  init(c)
  c.req = request
  if request.cookies.len > 0:
    checkLoggedIn(c)
  c.loggedIn = loggedIn(c)


template checkboxToInt(checkboxOnOff: string): string =
  ## When posting checkbox data from HTML form
  ## an "on" is sent when true. Convert to 1 or 0.

  if checkboxOnOff == "on":
    "1"
  else:
    "0"


template checkboxToChecked(checkboxOnOff: string): string =
  ## When parsing DB data on checkboxes convert
  ## 1 or 0 to HTML checked to set checkbox

  if checkboxOnOff == "1":
    "checked"
  else:
    ""


template statusIntToText(status: string): string =
  ## When parsing DB status convert
  ## 0, 1 and 3 to human names
  
  if status == "0":
    "Development"
  elif status ==  "1":
    "Private"
  elif status ==  "2":
    "Public"
  else:
    "Error"


template statusIntToCheckbox(status, value: string): string =
  ## When parsing DB status convert
  ## to HTML selected on selects

  if status == "0" and value == "0":
    "selected"
  elif status ==  "1" and value == "1":
    "selected"
  elif status ==  "2" and value == "2":
    "selected"
  else:
    ""



#[ 
      Include HTML files
__________________________________________________]#

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



#[ 
      Routes for WWW
__________________________________________________]#

proc checkCompileOptions*(): string {.compileTime.} =
  # Checking for known compile options
  # and returning them as a space separated string.
  # See README.md for explation of the options.
  
  result = ""

  when defined(nginx):
    result.add(" -d:nginx")
  when defined(adminnotify):
    result.add(" -d:adminnotify")
  when defined(dev):
    result.add(" -d:dev")
  when defined(devemailon):
    result.add(" -d:devemailon")
  when defined(demo):
    result.add(" -d:demo")
  
  return result


macro generateRoutes(): typed =
  ## The macro generates the routes for Jester.
  ## Routes are found in the resources/web/routes.nim.
  ## All plugins 'routes.nim' are also included.


  var extensions = staticRead("resources/web/routes.nim")
  
  for ppath in getPluginsPath():
    extensions.add("\n")
    extensions.add(staticRead(ppath & "/routes.nim"))

  when defined(dev):
    echo extensions

  result = parseStmt(extensions)

generateRoutes()



#[ 
      Proc's for demo usage
__________________________________________________]#
when defined(demo):
  proc emptyDB(db: DbConn) {.async.} =
    await sleepAsync((60*10) * 1000)
    var standarddata = true
    when defined(demoloadbackup):
      standarddata = false
      let execOutput = execCmd("cp data/website.bak.db data/website.db")
      if execOutput != 0:
        dbg("ERROR", "emptyDB(): Error backing up the database")
        await sleepAsync(2000)
        discard execCmd("cp data/website.bak.db data/website.db")

    if standarddata:
      createStandardData(db)



#[
      Main module
__________________________________________________]#
when isMainModule:

  echo "\n"
  echo "--------------------------------------------"
  echo "  Package:        " & cfgPackageName
  echo "  Version:        " & cfgPackageVersion & " - " & cfgPackageDate
  echo "  Description:    " & cfgPackageDescription
  echo "  Author name:    " & cfgAuthorName
  echo "  Author email:   " & cfgAuthorEmail
  echo "  Current time:   " & $getTime()
  echo "--------------------------------------------"
  echo "\n"

  # Show commandline help info
  if "help" in commandLineParams():
    echo commandLineHelp()
    quit()


  dbg("INFO", "Main module started at: " & $getTime())


  randomize()


  # Storage location
  # Folders are created in the module files_efs.nim
  when not defined(ignoreefs) and defined(release):
    # Check access to EFS file system
    dbg("INFO", "Checking storage access")
    if not existsDir(storageEFS):
      dbg("ERROR", "isMainModule: No access to storage in release mode. Critical")
      sleep(2000)
      quit()


  # Generate DB
  if "newdb" in commandLineParams() or not fileExists(db_host): 
    generateDB()


  # Connect to DB
  try:
    db = open(connection=db_host, user=db_user, password=db_pass, database=db_name)
    dbg("INFO", "Connection to DB is established")
  except:
    dbg("ERROR", "Connection to DB could not be established")
    sleep(5000)
    quit()

  

  # Add admin user
  if "newuser" in commandLineParams():
    createAdminUser(db, commandLineParams())


  # Add test user
  when defined(demo):
    dbg("INFO", "Demo option is activated")
    echo "  Demo option is activated"
    when defined(demoloadbackup):
      discard execCmd("cp data/website.db data/website.bak.db")
    createTestUser(db)
    asyncCheck emptyDB(db)


  # Activate Google reCAPTCHA
  setupReCapthca()


  # Update sql database from extensions
  extensionUpdateDB(db)
      

  # Insert standard data
  if "insertdata" in commandLineParams():
    echo "\nInsert standard data?"
    echo "This will override existing data (y/N):"
    if readLine(stdin) == "y":
      createStandardData(db)


  dbg("INFO", "Up and running!")
  
  
  runForever()
  db.close()
  dbg("INFO", "Connection to DB is closed")
  
