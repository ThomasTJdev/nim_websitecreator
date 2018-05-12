#
#
#        TTJ
#        (c) Copyright 2018 Thomas Toftgaard Jarløv
#        Look at License.txt for more info.
#        All rights reserved.
#
#

import
  os, strutils, times, md5, strtabs, cgi, jester, asyncdispatch, asyncnet, asyncfile, sequtils, rdstdin, parseutils, parsecfg, random, re, json, macros, db_sqlite, bcrypt, recaptcha, osproc

import cookies as libcookies

import ressources/administration/create_adminuser
import ressources/administration/create_standarddata
import ressources/administration/createdb
import ressources/administration/help
import ressources/email/email_registration
import ressources/files/files_efs
import ressources/files/files_utils
import ressources/password/password_generate
import ressources/password/salt_generate
import ressources/session/user_data
import ressources/web/google_recaptcha
import ressources/web/urltools
import ressources/utils/dates
import ressources/utils/logging
import ressources/utils/random_generator
import ressources/utils/extensions


macro configExists(): untyped =
  if not fileExists("config/config.cfg"):
    echo "\nERROR: Config file (config.cfg) could not be found."
    echo "Please create the config.cfg in the config folder or"
    echo "make a copy of the template (config_default.cfg).\n"
    quit()

configExists()


macro extensionImport(): untyped =
  ## Macro with 2 functions
  ##
  ## 1) Generate code for importing modules from extensions.
  ## The extensions main module needs to be in plugins/plugin_import.txt
  ## to be activated. Only 1 module will be imported.
  ##
  ## 2) Generate proc for updating the database with new tables etc.
  ## The extensions main module shall contain a proc named 'proc <extensionname>Start(db: DbConn) ='
  ## The proc will be executed when the program is executed.

  var plugins = (staticRead("plugins/plugin_import.txt").split("\n"))

  var extensions = ""
  
  if plugins.len() > 0:
    for importit in plugins:
      if importit.substr(0, 0) == "#" or importit == "":
        continue

      extensions.add("import " & importit.split(":")[1] & "/" & importit.split(":")[0] & "\n")

    when defined(dev):
      echo extensions

  result = parseStmt(extensions)

extensionImport()


macro extensionUpdateDatabase(): untyped =
  ## Macro with 2 functions
  ##
  ## 1) Generate code for importing modules from extensions.
  ## The extensions main module needs to be in plugins/plugin_import.txt
  ## to be activated. Only 1 module will be imported.
  ##
  ## 2) Generate proc for updating the database with new tables etc.
  ## The extensions main module shall contain a proc named 'proc <extensionname>Start(db: DbConn) ='
  ## The proc will be executed when the program is executed.

  var plugins = (staticRead("plugins/plugin_import.txt").split("\n"))

  var extensions = ""
 
  if plugins.len() > 0:
    extensions.add("proc extensionUpdateDB*(db: DbConn) =\n")
    for importit in plugins:
      if importit.substr(0, 0) == "#" or importit == "":
        continue
        
      extensions.add("  " & importit.split(":")[0] & "Start(db)\n")

    when defined(dev):
      echo extensions

  result = parseStmt(extensions)

extensionUpdateDatabase()



#[ 
      Defining variables
__________________________________________________]#
var
  db: DbConn
  
let dict = loadConfig("config/config.cfg")

let db_user = dict.getSectionValue("Database","user")
let db_pass = dict.getSectionValue("Database","pass")
let db_name = dict.getSectionValue("Database","name")
let db_host = dict.getSectionValue("Database","host")

let mainURL = dict.getSectionValue("Server","url")
let mainPort = parseInt dict.getSectionValue("Server","port")

let proxyURL = dict.getSectionValue("Proxy","url")
let proxyPath = dict.getSectionValue("Proxy","path")

when defined(release):
  let logfile = dict.getSectionValue("Logging","logfile")
when not defined(release):
  let logfile = dict.getSectionValue("Logging","logfiledev")


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
      echo("Skipped cfg, got: " & line)
      continue
    
    source &= "const cfg" & chunks[0] & "= \"" & chunks[1] & "\"\n"

  if source.len < 1: error("Input file empty!")
  echo "Constant vars compiled from configStatic.cfg:"
  echo source
  result = parseStmt(source)

readCfgAndBuildSource("/config/configStatic.cfg")



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
  c.rank          = Deactivated
  c.loggedIn      = false
  c.urlpath       = proxyURL & proxyPath


    

#[ 
      Validation check
__________________________________________________]#
proc loggedIn(c: TData): bool =
  ## Check if user is logged in
  ## by verifying that c.username is used

  result = c.username.len > 0




#[ 
      Check if user is signed in
__________________________________________________]#

proc checkLoggedIn(c: var TData) =
  ## Check if user is logged in

  if not c.req.cookies.hasKey("sid"): return
  let pass = c.req.cookies["sid"]
  if execAffectedRows(db,
      sql("update session set lastModified = " & $toInt(epochTime()) & " " &
           "where ip = ? and password = ?"),
           c.req.ip, pass) > 0:
    c.userpass  = pass
    c.userid    = getValue(db,
      sql"select userid from session where ip = ? and password = ?",
      c.req.ip, pass)

    let row = getRow(db, sql"select name, email, status from person where id = ?", c.userid)
    c.username  = row[0]
    c.email     = toLowerAscii(row[1])
    c.rank      = parseEnum[Rank](row[2])
    
    discard tryExec(db, sql"UPDATE person SET lastOnline = ? WHERE id = ?", toInt(epochTime()), c.userid)

  else:
    c.loggedIn = false



#[ 
      User login
__________________________________________________]#

proc login(c: var TData, email, pass: string): bool =
  ## User login

  when not defined(demo):
    if email == "test@test.com":
      return false

  # get form data:
  const query = sql"select id, name, password, email, salt, status, secretUrl from person where email = ?"
  if email.len == 0:
    return false

  var success = false
  for row in fastRows(db, query, toLowerAscii(email)):
    if row[6] != "":
      dbg("INFO", "Login failed. Account not activated")
      return false

    if row[2] == makePassword(pass, row[4], row[2]):
      c.userid   = row[0]
      c.username = row[1]
      c.userpass = row[2]
      c.email    = toLowerAscii(row[3])
      c.rank     = parseEnum[Rank](row[5])
      
      success = true
      break

  if success:
    # create session:
    exec(db,
      sql"insert into session (ip, password, userid) values (?, ?, ?)",
      c.req.ip, c.userpass, c.userid)
    dbg("INFO", "Login successful")
    return true
  else:
    dbg("INFO", "Login failed")
    return false



proc logout(c: var TData) =
  ## Logout

  const query = sql"delete from session where ip = ? and password = ?"
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
  c.startTime = epochTime()
  if request.cookies.len > 0:
    checkLoggedIn(c)
  c.loggedIn = loggedIn(c)


template checkboxToInt(checkboxOnOff: string): string =
  if checkboxOnOff == "on":
    "1"
  else:
    "0"

template checkboxToChecked(checkboxOnOff: string): string =
  if checkboxOnOff == "1":
    "checked"
  else:
    ""

template statusIntToText(status: string): string =
  if status == "0":
    "Development"
  elif status ==  "1":
    "Private"
  elif status ==  "2":
    "Public"
  else:
    "Error"


template statusIntToCheckbox(status, value: string): string =
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
include "tmpl/user.tmpl"
include "tmpl/main.tmpl"



#[ 
      Routes for WWW
__________________________________________________]#

macro generateRoutes(): typed =
  ## The macro generates the routes for Jester.
  ## Routes are found in the ressources/web/routes.nim.
  ## All plugins 'routes.nim' are also included.

  var plugins = (staticRead("plugins/plugin_import.txt").split("\n"))

  var extensions = staticRead("ressources/web/routes.nim")
    
  for caseit in plugins:
    if caseit.substr(0, 0) == "#" or caseit == "":
      continue

    extensions.add("\n")
    extensions.add(staticRead(caseit.split(":")[1] & "/routes.nim"))
  
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
    createStandardData(db)




#[
      Main module
__________________________________________________]#
when isMainModule:
  echo ""
  echo "--------------------------------------------"
  echo "  Package:       " & cfgPackageName
  echo "  Version:       " & cfgPackageVersion & " - " & cfgPackageDate
  echo "  Description:   " & cfgPackageDescription
  echo "  Author name:   " & cfgAuthorName
  echo "  Author email:  " & cfgAuthorEmail
  echo "  Current time:  " & $getTime()
  echo "--------------------------------------------"
  echo ""

  # Show commandline help info
  if "help" in commandLineParams():
    echo commandLineHelp()
    quit()


  dbg("INFO", "Main module started at: " & $getTime())

  dbg("INFO", "Main is started")


  randomize()


  # Create folders
  dbg("INFO", "Checking dir's exists (cron, log & tmp)")
  discard existsOrCreateDir("log")
  discard existsOrCreateDir("tmp")
  
  # Storage location
  when not defined(release):
    dbg("INFO", "Checking EFS dev (locally folders) exists")
    discard existsOrCreateDir("files")
  when not defined(ignoreefs) and defined(release):
    # Check access to EFS file system
    dbg("INFO", "Checking storage (EFS) access")
    if not existsDir(storageEFS):
      dbg("ERROR", "isMainModule: No access to storage (EFS). Critical")
      sleep(2000)
      quit()


  # Generate DB
  #when defined(newdb):
  #  generateDB()

  if "newdb" in commandLineParams() or defined(newdb): 
    generateDB()


  # Connect to DB
  db = open(connection=db_host, user=db_user, password=db_pass, database=db_name)
  try:
    db = open(connection=db_host, user=db_user, password=db_pass, database=db_name)
    dbg("INFO", "Connection to DB is established")
  except:
    dbg("ERROR", "Connection to DB could not be established")
    sleep(5000)
    quit()

  

  # Add admin user
  #when defined(newuser):
  #  createAdminUser(db)
  if "newuser" in commandLineParams() or defined(newuser):
    createAdminUser(db)

  # Add test user
  when defined(demo):
    dbg("INFO", "Demo option is activated")
    echo "  Demo option is activated"
    createTestUser(db)
    asyncCheck emptyDB(db)


  # Activate Google reCAPTCHA
  setupReCapthca()


  # Update sql database from extensions
  extensionUpdateDB(db)
      

  # Insert standard data
  #when defined(insertdata):
  #  createStandardData(db)
  if "insertdata" in commandLineParams() or defined(insertdata):
    createStandardData(db)


  dbg("INFO", "Up and running!")
  
  
  runForever()
  db.close()
  dbg("INFO", "Connection to DB is closed")
  
