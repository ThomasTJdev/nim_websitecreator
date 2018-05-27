# Copyright 2018 - Thomas T. Jarløv
 
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
      if useCaptcha:
        if not await checkReCaptcha(@"g-recaptcha-response", c.req.ip):
          resp genFormLogin(c, "Error: You need to verify, that you are not a robot!")
    
    if login(c, @"email", replace(@"password", " ", "")):
      jester.setCookie("sid", c.userpass, daysForward(7))
      redirect("/settings")
    else:
      resp genFormLogin(c, "Error in login")
  
  get "/logout":
    createTFD()
    logout(c)
    redirect("/")

  get "/error/@errorMsg":
    createTFD()
    resp genMain(c, "<h3>" & decodeUrl(@"errorMsg") & "</h3>")




  #[

      Plugins

  ]#

  get "/plugins":
    ## Access the plugin overview
    
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      resp genMain(c, genPlugins(c))


  get "/plugins/status":
    ## Change the status of a plugin
    ##
    ## How to compile and restart the program?

    createTFD()
    if c.rank != Admin and defined(demo):
      resp("/error/" & encodeUrl("The test user is not authorized to access this area"))

    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      resp("/error/" & encodeUrl("You are not authorized to access this area"))

    let pluginPath = if @"status" == "false": ("#plugins/" & @"pluginname") else: ("plugins/" & @"pluginname")

    var newFile = ""
    for line in lines("plugins/plugin_import.txt"):
      if line == "":
        continue

      if line == pluginPath:
        if @"status" == "false":
          newFile.add("plugins/" & @"pluginname")
        else:
          newFile.add("#plugins/" & @"pluginname")

      else:
        newFile.add(line)

      newFile.add("\n")

    writeFile("plugins/plugin_import.txt", newFile)

    if @"status" == "false":
      redirect("/plugins/updating?pluginActivity=" & encodeUrl("installing " & @"pluginname"))
    else:
      redirect("/plugins/updating?pluginActivity=" & encodeUrl("uninstalling " & @"pluginname"))
  

  get "/plugins/updating":
    createTFD()
    if c.rank != Admin and defined(demo):
      resp("/error/" & encodeUrl("The test user is not authorized to access this area"))

    if not c.loggedIn or c.rank notin [Admin, Moderator]:
      resp("/error/" & encodeUrl("You are not authorized to access this area"))
      
    await response.sendHeaders()
    await response.send("Updating plugins: " & decodeUrl(@"pluginActivity") & "<br>")
    await response.send("Please wait while the program is compiling ..<br>")

    let output = execCmd("nim c " & checkCompileOptions() & " -o:websitecreator_main_new " & getAppDir() & "/websitecreator_main.nim")
    if output == 1:
      echo "\nAn error occured"
      await response.send("<br><br>An error occured<br>")
      await response.send("<a href=\"/\">Click here to go to the plugin page</a>")
    else:
      echo "\nCompiling done. Starting websitecreator:"
      await response.send("<br><br>Compiling done. Starting websitecreator<br>")
      await response.send("<a href=\"/\">Compiling is done, click here to reload</a>")
    quit()



  #[

      Settings

  ]#

  get "/settings":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      resp genMain(c, genSettings(c))
  
  get "/settings/edit":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      resp genMain(c, genSettingsEdit(c), "edithtml")

  get "/settings/editrestore":
    createTFD()
    if c.rank != Admin and defined(demo):
      redirect("/error/" & encodeUrl("Error: The test user can not change the main settings"))

    if c.loggedIn and c.rank in [Admin, Moderator]:
      standardDataSettings(db)
      redirect("/settings/edit")

  post "/settings/update":
    createTFD()
    if c.rank != Admin and defined(demo):
      redirect("/error/" & encodeUrl("Error: The test user can not change the main settings"))

    if c.loggedIn and c.rank in [Admin, Moderator]:  
      discard execAffectedRows(db, sql"UPDATE settings SET title = ?, head = ?, navbar = ?, footer = ? WHERE id = ?", @"title", @"head", @"navbar", @"footer", "1")
      if @"inbackground" == "true":
        resp("OK")
      redirect("/settings/edit")

  get "/settings/editjs":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      resp genMain(c, genSettingsEditJs(c), "editjs")

  post "/settings/updatejs":
    createTFD()
    if c.rank != Admin and defined(demo):
      redirect("/error/" & encodeUrl("Error: The test user can not change the main settings"))

    if c.loggedIn and c.rank in [Admin, Moderator]:  
      try:
        writeFile("public/js/js.js", @"js")
        if @"inbackground" == "true":
          resp("OK")
        redirect("/settings/editjs")
      except:
        resp "Error"

  get "/settings/editcss":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      resp genMain(c, genSettingsEditCss(c), "editcss")

  post "/settings/updatecss":
    createTFD()
    if c.rank != Admin and defined(demo):
      redirect("/error/" & encodeUrl("Error: The test user can not change the main settings"))
      
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      try:
        writeFile("public/css/style.css", @"css")
        if @"inbackground" == "true":
          resp("OK")
        redirect("/settings/editcss")
      except:
        resp "Error"




  #[

      Files

  ]#

  get "/files":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      resp genMain(c, genFiles(c), "edit")


  get "/files/raw":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      resp genFilesRaw(c)


  get "/files/stream/@access/@filename":
    ## Get a file
    createTFD()
    let filename = decodeUrl(@"filename")
    
    var filepath = ""

    if @"access" == "private":
      if not c.loggedIn:
        resp("Error: You are not authorized")
      filepath = storageEFS & "/files/private/" & filename

    else:
      filepath = storageEFS & "/files/public/" & filename

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
    
    if "nginx" notin commandLineParams() and not defined(nginx):
      response.client.close()


  post "/files/upload/@access":
    ## Upload a file

    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      if c.rank != Admin and defined(demo):
        if c.email == "test@test.com":
          resp("Error: The test user can not upload files")
          
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
    if c.loggedIn and c.rank in [Admin, Moderator]:
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
      if c.rank != Admin and defined(demo):
        if c.email == "test@test.com":
          redirect("/error/" & encodeUrl("Error: The test user can not change profile settings"))

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
    if c.loggedIn and c.rank in [Admin, Moderator]:
      if c.rank != Admin and defined(demo):
        if c.email == "test@test.com":
          redirect("/error/" & encodeUrl("Error: The test user can not delete users"))

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
        exec(db, sql"DELETE FROM session WHERE userid = ?", @"userID")
        redirect("/users")
      else:
        redirect("/error/" & encodeUrl("Could not delete user"))


  post "/users/add":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      if c.rank != Admin and defined(demo):
        if c.email == "test@test.com":
          redirect("/error/" & encodeUrl("Error: The test user can not add new users"))

      cond(@"status" in ["User", "Moderator", "Admin", "Deactivated"])

      if (c.rank != Admin and @"status" == "Admin") or c.rank == User:
        redirect("/error/" & encodeUrl("Error: You are not allowed to add a user with this status"))

      if @"name" == "" or @"email" == "" or @"status" == "":
        redirect("/error/" & encodeUrl("Error: Name, email and status are required"))

      if @"email" == "test@test.com":
        redirect("/error/" & encodeUrl("Error: test@test.com is taken by the system"))
      
      if not ("@" in @"email" and "." in @"email"):
        redirect("/error/" & encodeUrl("Error: Your email has a wrong format"))

      let emailExist = getValue(db, sql"SELECT id FROM person WHERE email = ?", @"email")
      if emailExist != "":
        redirect("/error/" & encodeUrl("Error: A user with that email does already exists"))
      
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
    
    if "nginx" notin commandLineParams() and not defined(nginx):
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
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      resp genMain(c, genNewBlog(c), "edit")


  post "/blogpagenew/save":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      let url = urlEncoderCustom(@"url")
      discard insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, head, navbar, footer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"head", @"navbar", @"footer")
      redirect("/blog/" & url)


  post "/blogpage/update":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      let url = urlEncoderCustom(@"url")
      let urloriginal = urlEncoderCustom(@"urloriginal")
      discard execAffectedRows(db, sql"UPDATE blog SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, head = ?, navbar = ?, footer = ? WHERE url = ?", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"head", @"navbar", @"footer", urloriginal)

      if @"inbackground" == "true":
        resp("OK")
      redirect("/editpage/blog/" & @"url")


  get "/blogpage/delete":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      let url = @"url"
      exec(db, sql"DELETE FROM blog WHERE url = ?", url)
      redirect("/")


  get "/editpage/blogallpages":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      resp genMain(c, genAllBlogPagesEdit(c))


  get re"/editpage/blog/*.":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      let urlName = c.req.path.replace("/editpage/blog/", "")
      
      if c.rank != Admin and defined(demo):
        if urlName == "frontpage" or urlName == "about":
          redirect("/editpage/blogallpages")
          
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
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      resp genMain(c, genAllPagesEdit(c))


  get re"/editpage/page/*.":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      let urlName = c.req.path.replace("/editpage/page/", "")
      resp genMain(c, genEditPage(c, urlName), "edit")


  get "/pagenew":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:  
      resp genMain(c, genNewPage(c), "edit")


  post "/pagenew/save":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      let url = urlEncoderCustom(@"url")
      discard insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, head, navbar, footer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"head", @"navbar", @"footer")
      if url == "frontpage":
        redirect("/")
      else:
        redirect("/p/" & url)


  post "/page/update":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      let url = urlEncoderCustom(@"url")
      let urloriginal = urlEncoderCustom(@"urloriginal")
      discard execAffectedRows(db, sql"UPDATE pages SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, head = ?, navbar = ?, footer = ? WHERE url = ?", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"head", @"navbar", @"footer", urloriginal)

      if @"inbackground" == "true":
        resp("OK")
      redirect("/editpage/page/" & @"url")


  get "/page/delete":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      if @"url" in "frontpage":
        resp("Error: You can not delete the frontpage")

      exec(db, sql"DELETE FROM pages WHERE url = ?", @"url")
      redirect("/")
  

  get re"/p/.*":
    createTFD()
    let urlName = c.req.path.replace("/p/", "")
    resp genPage(c, urlName)