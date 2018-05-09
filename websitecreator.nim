#
#
#        TTJ
#        (c) Copyright 2017 Thomas Toftgaard Jarløv
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
import ressources/utils/dates
import ressources/utils/logging
import ressources/utils/random_generator

import ressources/utils/extensions


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
routes:


  get "/":
    createTFD()
    resp genPage(c, "frontpage")
  

  get "/login":
    createTFD()
    resp genFormLogin(c)


  post "/dologin":
    createTFD()
    when not defined(dev):
      if not await checkReCaptcha(@"g-recaptcha-response", c.req.ip):
        resp genMain(c, genFormLogin(c, "Error: You need to verify, that you are not a robot!"))
    
    if login(c, @"email", replace(@"password", " ", "")):
      jester.setCookie("sid", c.userpass, daysForward(7))
      redirect("/settings")
    else:
      resp genMain(c, genFormLogin(c, "Error in login"))
  
  get "/logout":
    createTFD()
    logout(c)
    redirect("/")

  get "/error/@errorMsg":
    createTFD()
    resp decodeUrl(@"errorMsg")




  #[

      Settings

  ]#

  get "/settings":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genSettings(c))
  
  get "/settings/edit":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genSettingsEdit(c), "edit")

  get "/settings/editrestore":
    createTFD()
    if c.loggedIn:
      standardDataSettings(db)
      redirect("/settings/edit")

  post "/settings/update":
    createTFD()
    if c.loggedIn:  
      discard execAffectedRows(db, sql"UPDATE settings SET title = ?, head = ?, navbar = ?, footer = ? WHERE id = ?", @"title", @"head", @"navbar", @"footer", "1")
      redirect("/settings/edit")

  get "/settings/editjs":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genSettingsEditJs(c), "editjs")

  post "/settings/updatejs":
    createTFD()
    if c.loggedIn:  
      try:
        writeFile("public/js/js.js", @"js")
        redirect("/settings/editjs")
      except:
        resp "Error"

  get "/settings/editcss":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genSettingsEditCss(c), "editcss")

  post "/settings/updatecss":
    createTFD()
    if c.loggedIn:  
      try:
        writeFile("public/css/style.css", @"css")
        redirect("/settings/editcss")
      except:
        resp "Error"




  #[

      Files

  ]#

  get "/files":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genFiles(c), "edit")


  get "/files/raw":
    createTFD()
    if c.loggedIn:  
      resp genFilesRaw(c)


  get "/files/stream/@access/@filename":
    ## Get a file
    createTFD()
    let filename = decodeUrl(@"filename")
    
    var filepath = ""

    if @"access" == "private":
      if not c.loggedIn:
        resp("Error: You are not authorized")
      filepath = "files/efs/files/private/" & filename

    else:
      filepath = "files/efs/files/public/" & filename

    if not fileExists(filepath):
      resp("Error: File was not found")
      
    # Serve the file
    let ext = splitFile(filename).ext
    await response.sendHeaders(Http200, {"Content-Disposition": "", "Content-Type": "application/" & ext}.newStringTable())
    var file = openAsync(filepath, fmRead)
    var data = await file.read(4000)

    while data.len != 0:
      await response.client.send(data)
      data = await file.read(4000)
    
    file.close()
    
    when not defined(nginx):
      response.client.close()


  post "/files/upload/@access":
    ## Upload a file

    createTFD()
    if c.loggedIn:
      let filename  = request.formData["file"].fields["filename"]
      let access    = if @"access" == "private": "private" else: "public"
      let path = storageEFS & "/files/" & access & "/" & filename
      
      if fileExists(path):
        resp("Error: A file with the same name exists")
      
      try:
        writeFile(path, request.formData.getOrDefault("file").body)
        if fileExists(path):
          redirect("/files")

      except:
        resp("Error")

      resp("Error: Something went wrong")


  get "/files/delete/@access/@filename":
    ## Delete a file

    createTFD()
    if c.loggedIn:
      let filepath = storageEFS & "/files/" & @"access" & "/" & @"filename"
      echo filepath
      if tryRemoveFile(filepath): 
        redirect("/files")

      else: 
        resp("Error: File not found")




  #[

      Users

  ]#

  get "/users":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genUsers(c))


  get "/users/profile":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genUsersProfile(c), "users")


  post "/users/profile/update":
    createTFD()
    if c.loggedIn:  
      if @"name" == "" or @"email" == "":
        redirect("/error/" & encodeUrl("Error: Name and email are required"))

      if "@" notin @"email":
        redirect("/error/" & encodeUrl("Error: Your email has a wrong format (missing [a]: " & @"email"))

      if @"password" != @"passwordConfirm":
        redirect("/error/" & encodeUrl("Error: Your passwords did not match"))

      if @"password" != "":
        let salt = makeSalt()
        let password = makePassword(@"password", salt)

        exec(db, sql"UPDATE person SET name = ?, email = ?, password = ?, salt = ? WHERE id = ?", @"name", @"email", password, salt, c.userid)
      
      else:
        exec(db, sql"UPDATE person SET name = ?, email = ? WHERE id = ?", @"name", @"email", c.userid)

      redirect("/users/profile")
      

  get "/users/delete/@userID":
    createTFD()
    if c.loggedIn:
      if c.rank notin [Admin, Moderator]:
        redirect("/error/" & encodeUrl("Error: You are not allowed to delete users"))

      if c.userid == @"userID":
        redirect("/error/" & encodeUrl("Error: You can not delete yourself"))

      let userStatus = getValue(db, sql"SELECT status FROM person WHERE id = ?", @"userID")
      if userStatus == "":
        redirect("/error/" & encodeUrl("Error: Missing status on user"))

      if userStatus == "Admin" and c.rank != Admin:
        redirect("/error/" & encodeUrl("Error: You can not delete an admin user"))

      if tryExec(db, sql"DELETE FROM person WHERE id = ?", @"userID"):
        redirect("/users")
      else:
        redirect("/error/" & encodeUrl("Could not delete user"))


  post "/users/add":
    createTFD()
    if c.loggedIn:
      cond(@"status" in ["User", "Moderator", "Admin", "Deactivated"])
      if (c.rank != Admin and @"status" == "Admin") or c.rank == User:
        redirect("/error/" & encodeUrl("Error: You are not allowed to add a user with this status"))

      if @"name" == "" or @"email" == "" or @"status" == "":
        redirect("/error/" & encodeUrl("Error: Name, email and status are required"))

      let emailExist = getValue(db, sql"SELECT id FROM person WHERE email = ?", @"email")
      if emailExist != "":
        redirect("/error/" & encodeUrl("Error: A user with that email already exists"))
      
      let salt = makeSalt()
      let passwordOriginal = randomString(12)
      let password = makePassword(passwordOriginal, salt)
      let secretUrl = randomStringDigitAlpha(99)

      let userID = insertID(db, sql"INSERT INTO person (name, email, status, password, salt, secretUrl) VALUES (?, ?, ?, ?, ?, ?)", @"name", @"email", @"status", password, salt, secretUrl)

      asyncCheck sendEmailActivationManual(@"email", @"name", passwordOriginal, "/users/activate?id=" & $userID & "&ident=" & secretUrl, c.username)

      redirect("/users")

  
  get "/users/activate":
    createTFD()
    if @"id" == "" or @"ident" == "":
      redirect("/error/" & encodeUrl("Error: Something is wrong with the link"))

    let secretUrlConfirm = getValue(db, sql"SELECT id FROM person WHERE id = ? AND secretUrl = ?", @"id", @"ident")

    if secretUrlConfirm != "":
      exec(db, sql"UPDATE person SET secretUrl = NULL WHERE id = ? AND secretUrl = ?", @"id", @"ident")
      redirect("/login")
    else:
      redirect("/error/" & encodeUrl("Error: This is not a valid confirmation link"))


  get "/users/photo/stream/@filename":
    ## Get a file
    createTFD()
    let filename = decodeUrl(@"filename")
    
    var filepath = storageEFS & "/users/" & filename

    if not fileExists(filepath):
      resp("")
      
    # Serve the file
    let ext = splitFile(filename).ext
    await response.sendHeaders(Http200, {"Content-Disposition": "", "Content-Type": "application/" & ext}.newStringTable())
    var file = openAsync(filepath, fmRead)
    var data = await file.read(4000)

    while data.len != 0:
      await response.client.send(data)
      data = await file.read(4000)
    
    file.close()
    
    when not defined(nginx):
      response.client.close()


  post "/users/photo/upload":
    ## Uploads a new profile image for a user

    createTFD()
    if c.loggedIn:
      let path = storageEFS & "/users/" & c.userid
      let base64 = split(c.req.body, ",")[1]

      try:
        writeFile(path & ".txt", base64)
        discard execProcess("base64 -d > " & path & ".png < " & path & ".txt")
        removeFile(path & ".txt")
        if fileExists(path & ".png"):
          resp("File saved")

      except:
        resp("Error")

      resp("Error: Something went wrong")




  #[

      Blog

  ]#

  get "/blogpagenew":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genNewBlog(c), "edit")


  post "/blogpagenew/save":
    createTFD()
    if c.loggedIn:
      let url = @"url".replace(" ", "-")
      discard insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, head, navbar, footer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"head", @"navbar", @"footer")
      redirect("/blog/" & @"url")


  post "/blogpage/update":
    createTFD()
    if c.loggedIn:
      discard execAffectedRows(db, sql"UPDATE blog SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, head = ?, navbar = ?, footer = ? WHERE url = ?", c.userid, @"status", @"url", @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"head", @"navbar", @"footer", @"urloriginal")
      redirect("/editpage/blog/" & @"url")


  get "/blogpage/delete":
    createTFD()
    if c.loggedIn:
      exec(db, sql"DELETE FROM blog WHERE url = ?", @"url")
      redirect("/")


  get "/editpage/blogallpages":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genAllBlogPagesEdit(c))


  get re"/editpage/blog/*.":
    createTFD()
    if c.loggedIn:  
      let urlName = c.req.path.replace("/editpage/blog/", "")
      resp genMain(c, genEditBlog(c, urlName), "edit")


  get "/blog":
    createTFD()
    resp genMain(c, genBlogAllPages(c))
  

  get re"/blog/*.":
    createTFD()
    let urlName = c.req.path.replace("/blog/", "")
    resp genPageBlog(c, urlName)




  #[

      Pages

  ]#

  get "/editpage/allpages":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genAllPagesEdit(c))


  get re"/editpage/page/*.":
    createTFD()
    if c.loggedIn:  
      let urlName = c.req.path.replace("/editpage/page/", "")
      resp genMain(c, genEditPage(c, urlName), "edit")


  get "/pagenew":
    createTFD()
    if c.loggedIn:  
      resp genMain(c, genNewPage(c), "edit")


  post "/pagenew/save":
    createTFD()
    if c.loggedIn:
      let url = @"url".replace(" ", "-")
      discard insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, head, navbar, footer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"head", @"navbar", @"footer")
      if url == "frontpage":
        redirect("/")
      else:
        redirect("/p/" & url)


  post "/page/update":
    createTFD()
    if c.loggedIn:
      discard execAffectedRows(db, sql"UPDATE pages SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, head = ?, navbar = ?, footer = ? WHERE url = ?", c.userid, @"status", @"url", @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"head", @"navbar", @"footer", @"urloriginal")
      redirect("/editpage/page/" & @"url")


  get "/page/delete":
    createTFD()
    if c.loggedIn:
      if @"url" in "frontpage":
        resp("Error: You can not delete the frontpage")

      exec(db, sql"DELETE FROM pages WHERE url = ?", @"url")
      redirect("/")
  

  get re"/p/*.":
    createTFD()
    let urlName = c.req.path.replace("/p/", "")
    resp genPage(c, urlName)


  get re"/e/*.":
    createTFD()
    let urlName = c.req.path.replace("/e/", "")
    resp genMain(c, genExtension(c, db, urlName))


  post re"/e/*.":
    createTFD()
    let urlName = c.req.path.replace("/e/", "")
    resp genMain(c, genExtension(c, db, urlName))


    



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


  # Create foldsers
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
  when defined(newdb):
    generateDB()

  if "newdb" in commandLineParams():
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
  when defined(newuser):
    createAdminUser(db)
  if "newuser" in commandLineParams():
    createAdminUser(db)
  

  # Activate Google reCAPTCHA
  setupReCapthca()


  # Update sql database from extensions
  extensionUpdateDB(db)
      

  # Insert standard data
  when defined(insertdata):
    createStandardData(db)
  if "insertdata" in commandLineParams():
    createStandardData(db)


  dbg("INFO", "Up and running!")
  
  
  runForever()
  db.close()
  dbg("INFO", "Connection to DB is closed")
  
