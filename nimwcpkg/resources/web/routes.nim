# Copyright 2018 - Thomas T. Jarløv
 
routes:
  #error Http404:
  #  redirect("/")
  # Duplicated issue #152 & #155
  #error Http404:
  #  discard

  get "/":
    createTFD()
    let pageid = getValue(db, sql"SELECT id FROM pages WHERE url = ?", "frontpage")
    resp genPage(c, pageid)


  get "/login":
    createTFD()
    resp genFormLogin(c, decodeUrl(@"msg"))


  post "/dologin":
    createTFD()
    when not defined(dev):
      if useCaptcha:
        if not await checkReCaptcha(@"g-recaptcha-response", c.req.ip):
          redirect("/login?msg=" & encodeUrl("Error: You need to verify, that you are not a robot!"))
    
    let (loginB, loginS) = login(c, @"email", replace(@"password", " ", ""))
    if loginB:
      jester.setCookie("sid", loginS, daysForward(7))
      redirect("/settings")
    else:
      redirect("/login?msg=" & encodeUrl(loginS))
  
  get "/logout":
    createTFD()
    logout(c)
    redirect("/")

  get "/error/@errorMsg":
    createTFD()
    resp genMain(c, "<h3 style=\"text-align: center; color: red;\">" & decodeUrl(@"errorMsg") & "</h3>")




  #[

      Plugins

  ]#

  get "/plugins":
    ## Access the plugin overview
    
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genPlugins(c))


  get "/plugins/status":
    ## Change the status of a plugin
    ##
    ## @"status" == false => Plugin is not enabled
    ##                       this will enable the plugin (add a line)
    ## @"status" == true  => Plugin is enabled, 
    ##                       this will disable the plugin (remove the line)

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    if @"status" == "false":
      redirect("/plugins/updating?status=" & @"status" & "&pluginname=" & @"pluginname" & "&pluginActivity=" & encodeUrl("installing " & @"pluginname"))
    else:
      redirect("/plugins/updating?status=" & @"status" & "&pluginname=" & @"pluginname" & "&pluginActivity=" & encodeUrl("uninstalling " & @"pluginname"))


  get "/plugins/updating":
    ## Enable or disable a plugin
    ##
    ## This will re-compile the program due to plugins
    ## are loaded at compiletime. The newly compile filename
    ## will be named ..._new. After compiling the launcher
    ## identify the newly compiled file within 1,5 sec
    ## and restart the process.

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    let pluginPath = if @"status" == "false": "" else: (@"pluginname")
    pluginEnableDisable(pluginPath, @"pluginname", @"status")

    let output = recompile()
    if output == 1:
      echo "\nrecompile(): An error occurred"
      redirect("/plugins")
    else:
      redirect("/plugins")


  get "/plugins/repo":
    ## Shows all the plugins in the plugin repo

    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genPluginsRepo(c))

  
  get "/plugins/repo/download":
    ## Shows all the plugins in the plugin repo

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    if not pluginRepoClone():
      redirect("/error/" & encodeUrl("Something went wrong downloading the repository."))

    redirect("/plugins/repo")


  get "/plugins/repo/update":
    ## Updates the plugins repo

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    if not pluginRepoUpdate():
      redirect("/error/" & encodeUrl("Something went wrong downloading the repository."))

    redirect("/plugins/repo")


  get "/plugins/repo/updateplugin":
    ## Updates an installed plugin

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    if pluginUpdate(@"pluginfolder"):
      redirect("/plugins/updating?pluginActivity=" & encodeUrl("installing " & @"pluginname"))
    else:
      redirect("/error/" & encodeUrl("Something went wrong. Please check the git: " & @"pluginfolder"))


  get "/plugins/repo/deleteplugin":
    ## Updates an installed plugin

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    if pluginDelete(@"pluginfolder"):
      var isInstalled = false
      for line in lines("plugins/plugin_import.txt"):
        if ("plugins/" & @"pluginfolder") == line:
          isInstalled = true
          break
          
      if isInstalled:    
        pluginEnableDisable(("plugins/" & @"pluginfolder"), @"pluginfolder", "true")
        redirect("/plugins/updating?pluginActivity=" & encodeUrl("uninstalling " & @"pluginname"))
          
      redirect("/plugins/repo")
    else:
      redirect("/error/" & encodeUrl("Something went wrong. Please ensure, that you have disabled the plugin at /plugins"))


  get "/plugins/repo/downloadplugin":
    ## Download a plugin

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    if pluginDownload(@"pluginrepo", @"pluginfolder"):
      redirect("/plugins")
    else:
      redirect("/error/" & encodeUrl("Something went wrong. Please check the git: " & @"pluginrepo"))


  #[

      Settings

  ]#

  get "/settings":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genSettings(c))
    
  get "/settings/edit":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genSettingsEdit(c), "edithtml")

  get "/settings/editrestore":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    standardDataSettings(db)
    redirect("/settings/edit")

  post "/settings/update":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin, Moderator])

    discard execAffectedRows(db, sql"UPDATE settings SET title = ?, head = ?, navbar = ?, footer = ? WHERE id = ?", @"title", @"head", @"navbar", @"footer", "1")
    if @"inbackground" == "true":
      resp("OK")
    redirect("/settings/edit")

  get "/settings/editjs":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator]) 
    
    resp genMainAdmin(c, genSettingsEditJs(c, false), "editjs")

  get "/settings/editjscustom":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator]) 
    
    resp genMainAdmin(c, genSettingsEditJs(c, true), "editjs")

  post "/settings/updatejs":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin, Moderator])

    let jsFile = if @"customJs" == "true": "public/js/js_custom.js" else: "public/js/js.js"

    try:
      writeFile(jsFile, @"js")
      if @"inbackground" == "true":
        resp("OK")

      if @"customJs" == "true":
        redirect("/settings/editjscustom")
      else:
        redirect("/settings/editjs")
    except:
      resp "Error"

  get "/settings/editcss":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genSettingsEditCss(c, false), "editcss")

  get "/settings/editcsscustom":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genSettingsEditCss(c, true), "editcss")

  post "/settings/updatecss":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin, Moderator])

    let cssFile = if @"customJs" == "true": "public/css/style_custom.css" else: "public/css/style.css"

    try:
      writeFile(cssFile, @"css")
      if @"inbackground" == "true":
        resp("OK")

      if @"customJs" == "true":
        redirect("/settings/editcsscustom")
      else:
        redirect("/settings/editcss")
    except:
      resp "Error"




  #[

      Files

  ]#

  get "/files":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    
    resp genMainAdmin(c, genFiles(c), "edit")


  get "/files/raw":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    
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

    sendFile(filepath)


  post "/files/upload/grapesjs":
    # Upload a file via GrapesJS

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    let filename = request.formData["file[]"].fields["filename"]
    let path = "public/images/" & filename

    if fileExists(path):
      resp("ERROR")

    try:
      writeFile(path, request.formData.getOrDefault("file[]").body)
      if fileExists(path):
        resp("[\"/images/" & filename & "\"]")

    except:
      resp("ERROR")
    
    resp("ERROR")


  post "/files/upload/@access":
    ## Upload a file

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])
    
    if @"access" notin ["private", "public", "publicimage"]:
      resp("Error: Missing access right")

    let filename  = request.formData["file"].fields["filename"]
    var path: string

    if @"access" == "publicimage":
      path = "public/images/" & filename

    else:
      path = storageEFS & "/files/" & @"access" & "/" & filename
    
    if fileExists(path):
      resp("Error: A file with the same name exists")

    try:
      writeFile(path, request.formData.getOrDefault("file").body)
      if fileExists(path):
        redirect("/files")

    except:
      resp("Error: Something went wrong adding the file")

    resp("Error: Something went wrong")


  get "/files/delete/@access/@filename":
    ## Delete a file

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    var fileDeleted = false

    if @"access" == "publicimage":
      fileDeleted = tryRemoveFile("public/images/" & decodeUrl(@"filename"))

    else:
      fileDeleted = tryRemoveFile(storageEFS & "/files/" & @"access" & "/" & decodeUrl(@"filename")) 

    if fileDeleted:
      redirect("/files")

    else: 
      resp("Error: File not found")




  #[

      Users

  ]#

  get "/users":
    createTFD()
    if c.loggedIn:  
      resp genMainAdmin(c, genUsers(c))


  get "/users/profile":
    createTFD()
    if c.loggedIn:  
      resp genMainAdmin(c, genUsersProfile(c), "users")


  post "/users/profile/update":
    createTFD()
    restrictTestuser(HttpGet)

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
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

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
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin, Moderator])

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
      redirect("/login?msg=" & encodeUrl("Your account is now activated"))
    else:
      redirect("/error/" & encodeUrl("Please login using your username and password"))


  get "/users/photo/stream/@filename":
    ## Get a file
    createTFD()
    let filename = decodeUrl(@"filename")
    
    var filepath = storageEFS & "/users/" & filename

    if not fileExists(filepath):
      resp("")
    
    sendFile(filepath)


  post "/users/photo/upload":
    ## Uploads a new profile image for a user

    createTFD()
    restrictTestuser(c.req.reqMethod)

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
    restrictAccessTo(c, [Admin, Moderator])
     
    resp genMainAdmin(c, genNewBlog(c), "edit")


  post "/blogpagenew/save":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    
    let url = urlEncoderCustom(@"url")
    discard insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords")
    
    redirect("/blog/" & url)


  post "/blogpage/update":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    
    let url = urlEncoderCustom(@"url")
    discard execAffectedRows(db, sql"UPDATE blog SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, title = ?, metadescription = ?, metakeywords = ? WHERE id = ?", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"blogid")

    if @"inbackground" == "true":
      resp("OK")
    redirect("/editpage/blog/" & @"blogid")


  get "/blogpage/delete":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    exec(db, sql"DELETE FROM blog WHERE id = ?", @"blogid")
    redirect("/")


  get "/editpage/blogallpages":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genAllBlogPagesEdit(c))


  get "/editpage/blog/@blogid":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genEditBlog(c, @"blogid"), "edit")


  get "/blog":
    createTFD()
    resp genMain(c, genBlogAllPages(c))
  

  get re"/blog//*.":
    createTFD()
    let blogid = getValue(db, sql"SELECT id FROM blog WHERE url = ?", c.req.path.replace("/blog/", ""))
    resp genPageBlog(c, blogid)




  #[

      Pages

  ]#

  get "/editpage/allpages":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    
    resp genMainAdmin(c, genAllPagesEdit(c))


  get "/editpage/page/@pageid":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genEditPage(c, @"pageid"), "edit")


  get "/pagenew":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    
    resp genMainAdmin(c, genNewPage(c), "edit")


  post "/pagenew/save":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    let url = urlEncoderCustom(@"url")
    discard insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords")
    if url == "frontpage":
      redirect("/")
    else:
      redirect("/p/" & url)


  post "/page/update":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    let url = urlEncoderCustom(@"url")
    discard execAffectedRows(db, sql"UPDATE pages SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, title = ?, metadescription = ?, metakeywords = ? WHERE id = ?", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"pageid")

    if @"inbackground" == "true":
      resp("OK")
    redirect("/editpage/page/" & @"pageid")


  get "/page/delete":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    exec(db, sql"DELETE FROM pages WHERE id = ?", @"pageid")
    redirect("/")
  

  get re"/p//*.":
    createTFD()
    let pageid = getValue(db, sql"SELECT id FROM pages WHERE url = ?", c.req.path.replace("/p/", ""))
    resp genPage(c, pageid)

  
  #[

      Sitemap

  ]#
  get "/sitemap.xml":
    writeFile("public/sitemap.xml", genSitemap())
    sendFile("public/sitemap.xml")