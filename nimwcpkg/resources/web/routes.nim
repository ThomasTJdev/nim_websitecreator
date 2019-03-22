
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
    if @"password2" != "": # DONT TOUCH, HoneyPot: https://github.com/ThomasTJdev/nim_websitecreator/issues/43#issue-403507393
      when not defined(release): echo "HONEYPOT: " & @"password2"
      redirect("/login?msg=" & encodeUrl("Error: You need to verify, that you are not a robot!"))
    when not defined(dev):
      if useCaptcha:
        if not await checkReCaptcha(@"g-recaptcha-response", c.req.ip):
          redirect("/login?msg=" & encodeUrl("Error: You need to verify, that you are not a robot!"))

    let (loginB, loginS) = login(c, replace(toLowerAscii(@"email"), " ", ""), replace(@"password", " ", ""), @"totp")
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
    resp genMain(c, "<h3 style=\"text-align: center; color: red; margin-top: 100px;\">" & decodeUrl(@"errorMsg") & "</h3>")


#
# Plugins
#


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


#
# Settings
#


  get "/settings":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genSettings(c))

  get "/settings/edit":
    createTFD()
    restrictAccessTo(c, [Admin])

    resp genMainAdmin(c, genSettingsEdit(c), "edithtml")

  post "/settings/update":
    createTFD()
    if @"inbackground" == "true":
      restrictTestuser(c.req.reqMethod)
    else:
      restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])

    discard execAffectedRows(db, sql"UPDATE settings SET title = ?, head = ?, navbar = ?, footer = ? WHERE id = ?", @"title", @"head", @"navbar", @"footer", "1")
    if @"inbackground" == "true":
      resp("OK")
    redirect("/settings/edit")

  get "/settings/editjs":
    createTFD()
    restrictAccessTo(c, [Admin])

    resp genMainAdmin(c, genSettingsEditJs(c, false), "editjs")

  get "/settings/editjscustom":
    createTFD()
    restrictAccessTo(c, [Admin])

    resp genMainAdmin(c, genSettingsEditJs(c, true), "editjs")

  post "/settings/updatejs":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])

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
    restrictAccessTo(c, [Admin])

    resp genMainAdmin(c, genSettingsEditCss(c, false), "editcss")

  get "/settings/editcsscustom":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])

    resp genMainAdmin(c, genSettingsEditCss(c, true), "editcss")

  post "/settings/updatecss":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])

    let cssFile = if @"customCss" == "true": "public/css/style_custom.css" else: "public/css/style.css"

    try:
      writeFile(cssFile, @"css")
      if @"inbackground" == "true":
        resp("OK")

      if @"customCss" == "true":
        redirect("/settings/editcsscustom")
      else:
        redirect("/settings/editcss")
    except:
      resp "Error"

  get "/settings/blog":
    createTFD()
    restrictAccessTo(c, [Admin])

    resp genMainAdmin(c, genSettingsBlog(c))

  post "/settings/updateblogsettings":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])

    var blogorder: string
    case @"blogorder"
    of "url":
      blogorder = "url"
    of "published":
      blogorder = "creation"
    of "modified":
      blogorder = "modified"
    of "name":
      blogorder = "name"
    else:
      redirect("/settings/blog")

    if @"blogsort" notin ["ASC", "DESC"]:
      redirect("/settings/blog")

    exec(db, sql"UPDATE settings SET blogorder = ?, blogsort = ?", blogorder, @"blogsort")
    redirect("/settings/blog")

  get "/settings/logs":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])
    resp genMainAdmin(c, genViewLogs(logcontent=readFile(logfile)))

  get "/settings/forcerestart":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])
    quit()

  get "/settings/serverinfo":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])
    resp genMainAdmin(c, genServerInfo())

  get "/settings/termsofservice":
    createTFD()
    let tos = readFile(getAppDir() & "/tmpl/tos.html")
    resp tos

  get "/users/profile/avatar":
    createTFD()
    resp genMainAdmin(c, genAvatar(c))

  post "/users/profile/avatar/save":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    if len(@"avatar") > 0:
      exec(db, sql"UPDATE person SET avatar = ? WHERE id = ?", @"avatar", c.userid)
    redirect("/users/profile")

  get "/settings/firejail":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])

    when not defined(firejail):
      redirect("/")
    else:
      let dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
      resp genMainAdmin(c, genFirejail(
        dict.getSectionValue("firejail", "noDvd").parseBool,
        dict.getSectionValue("firejail", "noSound").parseBool,
        dict.getSectionValue("firejail", "noAutoPulse").parseBool,
        dict.getSectionValue("firejail", "no3d").parseBool,
        dict.getSectionValue("firejail", "noX").parseBool,
        dict.getSectionValue("firejail", "noVideo").parseBool,
        dict.getSectionValue("firejail", "noDbus").parseBool,
        dict.getSectionValue("firejail", "noShell").parseBool,
        dict.getSectionValue("firejail", "noDebuggers").parseBool,
        dict.getSectionValue("firejail", "noMachineId").parseBool,
        dict.getSectionValue("firejail", "noRoot").parseBool,
        dict.getSectionValue("firejail", "noAllusers").parseBool,
        dict.getSectionValue("firejail", "noU2f").parseBool,
        dict.getSectionValue("firejail", "privateTmp").parseBool,
        dict.getSectionValue("firejail", "privateCache").parseBool,
        dict.getSectionValue("firejail", "privateDev").parseBool,
        dict.getSectionValue("firejail", "forceEnUsUtf8").parseBool,
        dict.getSectionValue("firejail", "caps").parseBool,
        dict.getSectionValue("firejail", "seccomp").parseBool,
        dict.getSectionValue("firejail", "noTv").parseBool,
        dict.getSectionValue("firejail", "writables").parseBool,
        dict.getSectionValue("firejail", "noMnt").parseBool,
        dict.getSectionValue("firejail", "maxSubProcesses").parseInt,
        dict.getSectionValue("firejail", "maxOpenFiles").parseInt,
        dict.getSectionValue("firejail", "maxFileSize").parseInt,
        dict.getSectionValue("firejail", "maxPendingSignals").parseInt,
        dict.getSectionValue("firejail", "timeout").parseInt,
        dict.getSectionValue("firejail", "maxCpu").parseInt,
        dict.getSectionValue("firejail", "maxRam").parseInt,
        dict.getSectionValue("firejail", "cpuCoresByNumber").parseInt,
        dict.getSectionValue("firejail", "hostsFile"),
        dict.getSectionValue("firejail", "dns0"),
        dict.getSectionValue("firejail", "dns1"),
        dict.getSectionValue("firejail", "dns2"),
        dict.getSectionValue("firejail", "dns3"),
      ))

  post "/settings/firejail/save":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])

    when not defined(firejail):
      redirect("/")
    else:
      let konfig = replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg"
      var dict = loadConfig(konfig)
      try:  # HTML Checkbox returns empty string for false and "on" for true.
        dict.setSectionKey("firejail", "noDvd",         $(len(@"noDvd") > 0))
        dict.setSectionKey("firejail", "noSound",       $(len(@"noSound") > 0))
        dict.setSectionKey("firejail", "noAutoPulse",   $(len(@"noAutoPulse") > 0))
        dict.setSectionKey("firejail", "no3d",          $(len(@"no3d") > 0))
        dict.setSectionKey("firejail", "noX",           $(len(@"noX") > 0))
        dict.setSectionKey("firejail", "noVideo",       $(len(@"noVideo") > 0))
        dict.setSectionKey("firejail", "noDbus",        $(len(@"noDbus") > 0))
        dict.setSectionKey("firejail", "noShell",       $(len(@"noShell") > 0))
        dict.setSectionKey("firejail", "noDebuggers",   $(len(@"noDebuggers") > 0))
        dict.setSectionKey("firejail", "noMachineId",   $(len(@"noMachineId") > 0))
        dict.setSectionKey("firejail", "noRoot",        $(len(@"noRoot") > 0))
        dict.setSectionKey("firejail", "noAllusers",    $(len(@"noAllusers") > 0))
        dict.setSectionKey("firejail", "noU2f",         $(len(@"noU2f") > 0))
        dict.setSectionKey("firejail", "privateTmp",    $(len(@"privateTmp") > 0))
        dict.setSectionKey("firejail", "privateCache",  $(len(@"privateCache") > 0))
        dict.setSectionKey("firejail", "privateDev",    $(len(@"privateDev") > 0))
        dict.setSectionKey("firejail", "forceEnUsUtf8", $(len(@"forceEnUsUtf8") > 0))
        dict.setSectionKey("firejail", "caps",          $(len(@"caps") > 0))
        dict.setSectionKey("firejail", "seccomp",       $(len(@"seccomp") > 0))
        dict.setSectionKey("firejail", "noTv",          $(len(@"noTv") > 0))
        dict.setSectionKey("firejail", "writables",     $(len(@"writables") > 0))
        dict.setSectionKey("firejail", "noMnt",         $(len(@"noMnt") > 0))
        dict.setSectionKey("firejail", "maxSubProcesses",   @"maxSubProcesses")
        dict.setSectionKey("firejail", "maxOpenFiles",      @"maxOpenFiles")
        dict.setSectionKey("firejail", "maxFileSize",       @"maxFileSize")
        dict.setSectionKey("firejail", "maxPendingSignals", @"maxPendingSignals")
        dict.setSectionKey("firejail", "timeout",           @"timeout")
        dict.setSectionKey("firejail", "maxCpu",            @"maxCpu")
        dict.setSectionKey("firejail", "maxRam",            @"maxRam")
        dict.setSectionKey("firejail", "cpuCoresByNumber",  @"cpuCoresByNumber")
        dict.setSectionKey("firejail", "hostsFile", @"hostsFile")
        dict.setSectionKey("firejail", "dns0",      @"dns0")
        dict.setSectionKey("firejail", "dns1",      @"dns1")
        dict.setSectionKey("firejail", "dns2",      @"dns2")
        dict.setSectionKey("firejail", "dns3",      @"dns3")
        dict.writeConfig(konfig)
      except:
        resp $getCurrentExceptionMsg()
      redirect("/settings")

  get "/settings/config":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])
    let konfig = replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg"
    resp genMainAdmin(c, genEditConfig(readFile(konfig)))

  post "/settings/config/save":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])
    try:
      discard loadConfig(newStringStream(@"config")) # Not a strong Validation.
    except:
      resp $getCurrentExceptionMsg()
    let konfig = replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg"
    writeFile(konfig, strip(@"config"))
    redirect("/settings")


#
# Files
#


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

    var downloadCount =
      try: parseInt(getValue(db, sql"SELECT downloadCount FROM files where url = ?", filepath))
      except: 0
    inc downloadCount
    exec(db, sql"UPDATE files SET downloadCount = ? where url = ?", downloadCount, filepath)
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
      when defined(webp):
        if path.endsWith(".png") or path.endsWith(".jpg") or path.endsWith(".jpeg"):
          discard cwebp(path, path, "drawing", quality=25)  # This sets quality of WEBP
      if fileExists(path):
        # Do not insert into DB due to being a public image file
        #exec(db, sql"INSERT INTO files(url, downloadCount) VALUES (?, 0)", path)
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

    const
      efspublic = storageEFS & "/files/public/"
      efsprivate = storageEFS & "/files/private/"
    var
      path: string
      filename  = request.formData["file"].fields["filename"]
    let
      filedata = request.formData.getOrDefault("file").body
      fileexts = filename.splitFile.ext
      usesWebp = @"webpstatus" == "true" and fileexts in [".png", ".jpg", ".jpeg"]

    if not usesWebp and @"checksum" == "true":
      filename = getMD5(filedata) & fileexts

    if @"normalize" == "true":
      filename = filename.normalize

    if @"access" == "publicimage":
      path = "public/images/" & filename
    elif @"access" == "public":
      assert existsDir(efspublic), "storageEFS Public Folder not found: " & efspublic
      path = efspublic & filename
    else:
      assert existsDir(efsprivate), "storageEFS Private Folder not found: " & efsprivate
      path = efsprivate & filename

    if fileExists(path):
      resp("Error: A file with the same name exists")

    writeFile(path, filedata)
    when defined(webp):
      if usesWebp:
        discard cwebp(path, path, "drawing", quality=25)  # This sets quality of WEBP
    if fileExists(path) and @"access" != "publicimage":
      # TODO: There should not be a row with the file. But if the user manually
      # deletes the file and reuploads it, it will still be present in th DB.
      # This query fails due to UNIQUE requirement in the DB. To prevent error and
      # try-except, it uses tryExec(). We could solve this by doing a sweep with walkDir().
      discard tryExec(db, sql"INSERT INTO files(url, downloadCount) VALUES (?, 0)", path)

    redirect("/files")


  get "/files/delete/@access/@filename":
    ## Delete a file

    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    var fileDeleted = false

    if @"access" == "publicimage":
      fileDeleted = tryRemoveFile("public/images/" & decodeUrl(@"filename"))

    else:
      let path = storageEFS & "/files/" & @"access" & "/" & decodeUrl(@"filename")
      fileDeleted = tryRemoveFile(path)
      exec(db, sql"DELETE FROM files WHERE url = ?", path)

    if fileDeleted:
      redirect("/files")

    else:
      resp("Error: File not found")


#
# Users
#


  get "/users":
    createTFD()
    if not c.loggedIn:
      redirect("/")
    resp genMainAdmin(c, genUsers(c))


  get "/users/profile":
    createTFD()
    if not c.loggedIn:
      redirect("/")
    resp genMainAdmin(c, genUsersProfile(c), "users")


  post "/users/profile/update":
    createTFD()
    restrictTestuser(HttpGet)

    if not c.loggedIn:
      redirect("/")

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


  post "/users/profile/update/test2fa":
    createTFD()
    restrictTestuser(HttpGet)

    if not c.loggedIn:
      redirect("/")

    try:
      if $newTotp(@"twofakey").now() == @"testcode":
        resp("Success, the code matched")
      else:
        resp("Error, code did not match")
    except:
      resp("Error generating 2FA")


  post "/users/profile/update/save2fa":
    createTFD()
    restrictTestuser(HttpGet)

    if not c.loggedIn:
      redirect("/")

    if tryExec(db, sql"UPDATE person SET twofa = ? WHERE id = ?", @"twofakey", c.userid):
      resp("Saved 2FA key")
    else:
      resp("Error saving 2FA key")


  post "/users/profile/update/disable2fa":
    createTFD()
    restrictTestuser(HttpGet)

    if not c.loggedIn:
      redirect("/")

    if tryExec(db, sql"UPDATE person SET twofa = ? WHERE id = ?", "", c.userid):
      resp("Disabled 2FA key")
    else:
      resp("Error disabling 2FA key")


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

    let emailReady = toLowerAscii(@"email")
    let emailExist = getValue(db, sql"SELECT id FROM person WHERE email = ?", emailReady)
    if emailExist != "":
      redirect("/error/" & encodeUrl("Error: A user with that email does already exists"))

    let
      salt = makeSalt()
      passwordOriginal = $rand(10_00_00_00_00_01.int..89_99_99_99_99_98.int) # User Must change it anyways.
      password = makePassword(passwordOriginal, salt)
      secretUrl = repeat($rand(10_00_00_00_00_00_00_00_00.int..int.high), 5).center(99, rand(toSeq('a'..'z')))

    let userID = insertID(db, sql"INSERT INTO person (name, email, status, password, salt, secretUrl) VALUES (?, ?, ?, ?, ?, ?)", @"name", emailReady, @"status", password, salt, secretUrl)

    asyncCheck sendEmailActivationManual(emailReady, @"name", passwordOriginal, "/users/activate?id=" & $userID & "&ident=" & secretUrl, c.username)

    redirect("/users")


  post "/users/reset":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])
    discard tryExec(db, sql"DELETE FROM session WHERE userid = ?", @"userid")
    discard tryExec(db, sql"UPDATE person SET name = ?, avatar = NULL, twofa = NULL, timezone = NULL WHERE id = ?", @"userid", @"userid")
    if @"cleanout" == "true":
      discard tryExec(db, sql"DELETE FROM pages WHERE author_id = ?", @"userid")
      discard tryExec(db, sql"DELETE FROM blog WHERE author_id = ?", @"userid")
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
    if not fileExists(filepath): resp("")
    sendFile(filepath)


  post "/users/photo/upload":
    ## Uploads a new profile image for a user
    createTFD()
    restrictTestuser(c.req.reqMethod)

    if not c.loggedIn: redirect("/")

    let path = storageEFS & "/users/" & c.userid
    let base64 = split(c.req.body, ",")[1]

    try:
      discard existsOrCreateDir(storageEFS & "/users")
      writeFile(path & ".txt", base64)
      discard execProcess("base64 -d > " & path & ".png < " & path & ".txt")
      removeFile(path & ".txt")
      if fileExists(path & ".png"): resp("File saved")
    except:
      resp("Error")

    resp("Error: Something went wrong")


#
# Blog
#


  get "/blogpagenew":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genNewBlog(c), "edit")


  post "/blogpagenew/save":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    let url = encodeUrl(@"url", true).replace("%2F", "/")
    if url == getValue(db, sql"SELECT url FROM blog WHERE url = ?", url):
      redirect("/error/" & encodeUrl("Error, a blogpost with the same URL already exists"))

    let blogID = insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords, category, tags, pubDate, viewCount) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"category", @"tags", @"pubdate", @"viewcount")

    resp genMainAdmin(c, genEditBlog(c, $blogID, true), "edit")


  post "/blogpage/update":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    let url = encodeUrl(@"url", true).replace("%2F", "/")
    if url == getValue(db, sql"SELECT url FROM blog WHERE url = ? AND id <> ?", url, @"blogid"):
      if @"inbackground" == "true":
        resp("Error: A page with same URL already exists")
      redirect("/error/" & encodeUrl("Error, a blogpost with the same URL already exists"))

    discard execAffectedRows(db, sql"UPDATE blog SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, title = ?, metadescription = ?, metakeywords = ?, category = ?, tags = ?, pubDate = ?, viewCount = ? WHERE id = ?", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"category", @"tags", @"pubdate", @"viewcount", @"blogid")

    if @"inbackground" == "true":
      resp("OK")
    redirect("/editpage/blog/" & @"blogid")


  get "/blogpage/delete":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    exec(db, sql"DELETE FROM blog WHERE id = ?", @"blogid")
    redirect("/editpage/blogallpages")


  get "/editpage/blogallpages":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genBlogAllPages(c, edit=true))


  get "/editpage/blog/@blogid":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genEditBlog(c, @"blogid"), "edit")


  get "/blog":
    createTFD()
    resp genMain(c, genBlogAllPages(c, false, @"name", @"category", @"tags"))


  get re"/blog//*.":
    createTFD()
    let blogid = getValue(db, sql"SELECT id FROM blog WHERE url = ?", c.req.path.replace("/blog/", ""))

    if blogid == "":
      redirect("/")

    resp genPageBlog(c, blogid)


#
# Pages
#


  get "/pagenew":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genNewPage(c), "edit")


  post "/pagenew/save":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    let url = encodeUrl(@"url", true).replace("%2F", "/")
    if url == getValue(db, sql"SELECT url FROM pages WHERE url = ?", url):
      redirect("/error/" & encodeUrl("Error, a blogpost with the same URL already exists"))

    let pageID = insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords, category, tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"category", @"tags")

    resp genMainAdmin(c, genEditPage(c, $pageID, true), "edit")


  post "/page/update":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    let url = encodeUrl(@"url", true).replace("%2F", "/")
    if url == getValue(db, sql"SELECT url FROM pages WHERE url = ? AND id <> ?", url, @"pageid"):
      if @"inbackground" == "true":
        resp("Error: A page with same URL already exists")
      redirect("/error/" & encodeUrl("Error, a blogpost with the same URL already exists"))

    discard execAffectedRows(db, sql"UPDATE pages SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, title = ?, metadescription = ?, metakeywords = ?, category = ?, tags = ? WHERE id = ?", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"category", @"tags", @"pageid")

    if @"inbackground" == "true":
      resp("OK")
    redirect("/editpage/page/" & @"pageid")


  get "/page/delete":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])

    exec(db, sql"DELETE FROM pages WHERE id = ?", @"pageid")
    redirect("/editpage/allpages")


  get "/editpage/allpages":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genAllPagesEdit(c))


  get "/editpage/page/@pageid":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])

    resp genMainAdmin(c, genEditPage(c, @"pageid"), "edit")


#
# Sitemap
#


  get "/sitemap.xml":
    writeFile("public/sitemap.xml", genSitemap())
    sendFile("public/sitemap.xml")


#
# Pages
#


  get re"/*.":
    createTFD()
    const sql_page = sql"SELECT id FROM pages WHERE url = ?"
    resp genPage(c, getValue(db, sql_page, c.req.path))
