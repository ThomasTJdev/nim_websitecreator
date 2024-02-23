
routes:
  get "/":
    createTFD()
    let data = getValue(db, sql"SELECT id FROM pages WHERE url = 'frontpage'")
    resp genPage(c, data)


  get "/login":
    createTFD()
    resp genFormLogin(c, decodeUrl(@"msg"))


  post "/dologin":
    createTFD()
    if @"password2" != "": # DONT TOUCH, HoneyPot: https://github.com/ThomasTJdev/nim_websitecreator/issues/43#issue-403507393
      when defined(dev): echo "Honeypot: " & @"password2"
      redirect("/login?msg=" & errNeedToVerifyRecaptcha)
    when not defined(dev):
      when defined(recaptcha):
        if useCaptcha:
          let isRecaptchaOk = not(await checkReCaptcha(@"g-recaptcha-response", c.req.ip))
          when defined(dev): echo "Recaptcha: " & $isRecaptchaOk
          if isRecaptchaOk:
            redirect("/login?msg=" & errNeedToVerifyRecaptcha)
    let (loginB, loginS) = login(c, replace(toLowerAscii(@"email"), " ", ""), replace(@"password", " ", ""), replace(@"totp", " ", ""))
    when defined(dev): echo("\nMail: ", @"email", "\nPassword2 (HoneyPot): ",  @"password2", "\n(loginB, loginS): ", (loginB, loginS))
    if loginB:
      when NimMajor > 2:
        jester_fork.setCookie("sid", loginS, daysForward(7))
      else:
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
    resp genMain(c, "<h3 style='text-align:center;color:red;margin-top:99px'>" & decodeUrl(@"errorMsg") & "</h3>")


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
      redirect("/plugins/updating?status=" & @"status" & "&pluginname=" & @"pluginname" & "&pluginActivity=" & msgInstallingPlugin)
    else:
      redirect("/plugins/updating?status=" & @"status" & "&pluginname=" & @"pluginname" & "&pluginActivity=" & msgUninstallingPlugin)


  get "/plugins/updating":
    ## Enable or disable a plugin
    ##
    ## This will re-compile the program due to plugins are loaded at compiletime.
    ## The newly compile filename will be named ..._new.
    ## After compiling the launcher identify the newly compiled file within 1,5 sec and restart the process.
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])
    when defined(dev): echo((if @"status" == "false": "" else: (@"pluginname")), @"pluginname", @"status")
    pluginEnableDisable((if @"status" == "false": "" else: (@"pluginname")), @"pluginname", @"status")
    when defined(dev): echo recompile() else: discard recompile()
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
    if unlikely(not pluginRepoClone()): redirect("/error/" & errGitClonError)
    redirect("/plugins/repo")


  get "/plugins/repo/update":
    ## Updates the plugins repo
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])
    if unlikely(not pluginRepoUpdate()): redirect("/error/" & errGitClonError)
    redirect("/plugins/repo")


  get "/plugins/repo/updateplugin":
    ## Updates an installed plugin
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])
    if likely(pluginUpdate(@"pluginfolder")):
      redirect("/plugins/updating?status=false&pluginname=" & @"pluginname" & "&pluginActivity=" & msgInstallingPlugin)
    else:
      redirect("/error/" & errGitPullError)


  get "/plugins/repo/deleteplugin":
    ## Updates an installed plugin
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])
    if pluginDelete(@"pluginfolder"):
      var isInstalled = false
      for line in lines("plugins/plugin_import.txt"):
        if ("plugins" / @"pluginfolder") == line:
          isInstalled = true
          break
      if isInstalled:
        pluginEnableDisable(("plugins/" & @"pluginfolder"), @"pluginfolder", "true")
        redirect("/plugins/updating?pluginActivity=" & msgUninstallingPlugin)
      redirect("/plugins/repo")
    else:
      redirect("/error/" & errPluginDeleteError)


  get "/plugins/repo/downloadplugin":
    ## Download a plugin
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])
    if pluginDownload(@"pluginrepo", @"pluginfolder"):
      redirect("/plugins")
    else:
      redirect("/error/" & errGitClonError)


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
    if @"inbackground" == "true": resp("OK")
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
    try:
      writeFile((if @"customJs" == "true": "public/js/js_custom.js" else: "public/js/js.js"), @"js".strip())
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
    try:
      writeFile((if @"customCss" == "true": "public/css/style_custom.css" else: "public/css/style.css"), @"css".strip())
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
    of "url": blogorder = "url"
    of "published": blogorder = "creation"
    of "modified": blogorder = "modified"
    of "name": blogorder = "name"
    else: redirect("/settings/blog")
    if @"blogsort" notin ["ASC", "DESC"]:
      redirect("/settings/blog")
    exec(db, sql"UPDATE settings SET blogorder = ?, blogsort = ?", blogorder, @"blogsort")
    redirect("/settings/blog")


  get "/settings/logs":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])
    resp genMainAdmin(c, genViewLogs(logcontent = readFile(logfile)))


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

  get "/settings/logsbackup":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])
    echo backupOldLogs(splitPath(dict.getSectionValue("Logging", when defined(release): "logfile" else: "logfiledev")).head)
    redirect("/settings")

  get "/settings/databasebackup":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])
    echo backupDb(dict.getSectionValue("Database", when defined(postgres): "name" else: "host"), checksum=false, sign=false, targz=false)
    redirect("/settings")

  get "/settings/termsofservice":
    createTFD()
    resp termsOfServices



  get "/settings/firejail":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])
    when not defined(firejail):
      redirect("/")
    else:
      let cFire = getConfig(replace(getAppDir(), "/nimwcpkg", "") / "config/config.cfg", cfgFirejail)
      resp genMainAdmin(c, genFirejail(
        cFire["noDvd"].parseBool, cFire["noSound"].parseBool, cFire["noAutoPulse"].parseBool,
        cFire["no3d"].parseBool, cFire["noX"].parseBool, cFire["noVideo"].parseBool,
        cFire["noDbus"].parseBool, cFire["noShell"].parseBool, cFire["noDebuggers"].parseBool,
        cFire["noMachineId"].parseBool, cFire["noRoot"].parseBool, cFire["noAllusers"].parseBool,
        cFire["noU2f"].parseBool, cFire["privateTmp"].parseBool, cFire["privateCache"].parseBool,
        cFire["privateDev"].parseBool, cFire["forceEnUsUtf8"].parseBool, cFire["caps"].parseBool,
        cFire["seccomp"].parseBool, cFire["noTv"].parseBool, cFire["writables"].parseBool,
        cFire["noMnt"].parseBool, cFire["maxSubProcesses"].parseInt, cFire["maxOpenFiles"].parseInt,
        cFire["maxFileSize"].parseInt, cFire["maxPendingSignals"].parseInt, cFire["timeout"].parseInt,
        cFire["maxCpu"].parseInt, cFire["maxRam"].parseInt, cFire["cpuCoresByNumber"].parseInt, cFire["hostsFile"],
        cFire["dns0"], cFire["dns1"], cFire["dns2"], cFire["dns3"],
      ))


  post "/settings/firejail/save":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin])
    when not defined(firejail):
      redirect("/")
    else:
      let konfig = replace(getAppDir(), "/nimwcpkg", "") / "config/config.cfg"
      var dict = loadConfig(konfig)
      try: # HTML Checkbox returns empty string for false and "on" for true.
        dict.setSectionKey("firejail", "noDvd", $(len(@"noDvd") > 0))
        dict.setSectionKey("firejail", "noSound", $(len(@"noSound") > 0))
        dict.setSectionKey("firejail", "noAutoPulse", $(len(@"noAutoPulse") > 0))
        dict.setSectionKey("firejail", "no3d", $(len(@"no3d") > 0))
        dict.setSectionKey("firejail", "noX", $(len(@"noX") > 0))
        dict.setSectionKey("firejail", "noVideo", $(len(@"noVideo") > 0))
        dict.setSectionKey("firejail", "noDbus", $(len(@"noDbus") > 0))
        dict.setSectionKey("firejail", "noShell", $(len(@"noShell") > 0))
        dict.setSectionKey("firejail", "noDebuggers", $(len(@"noDebuggers") > 0))
        dict.setSectionKey("firejail", "noMachineId", $(len(@"noMachineId") > 0))
        dict.setSectionKey("firejail", "noRoot", $(len(@"noRoot") > 0))
        dict.setSectionKey("firejail", "noAllusers", $(len(@"noAllusers") > 0))
        dict.setSectionKey("firejail", "noU2f", $(len(@"noU2f") > 0))
        dict.setSectionKey("firejail", "privateTmp", $(len(@"privateTmp") > 0))
        dict.setSectionKey("firejail", "privateCache", $(len(@"privateCache") > 0))
        dict.setSectionKey("firejail", "privateDev", $(len(@"privateDev") > 0))
        dict.setSectionKey("firejail", "forceEnUsUtf8", $(len(@"forceEnUsUtf8") > 0))
        dict.setSectionKey("firejail", "caps", $(len(@"caps") > 0))
        dict.setSectionKey("firejail", "seccomp", $(len(@"seccomp") > 0))
        dict.setSectionKey("firejail", "noTv", $(len(@"noTv") > 0))
        dict.setSectionKey("firejail", "writables", $(len(@"writables") > 0))
        dict.setSectionKey("firejail", "noMnt", $(len(@"noMnt") > 0))
        dict.setSectionKey("firejail", "maxSubProcesses", @"maxSubProcesses")
        dict.setSectionKey("firejail", "maxOpenFiles", @"maxOpenFiles")
        dict.setSectionKey("firejail", "maxFileSize", @"maxFileSize")
        dict.setSectionKey("firejail", "maxPendingSignals", @"maxPendingSignals")
        dict.setSectionKey("firejail", "timeout", @"timeout")
        dict.setSectionKey("firejail", "maxCpu", @"maxCpu")
        dict.setSectionKey("firejail", "maxRam", @"maxRam")
        dict.setSectionKey("firejail", "cpuCoresByNumber", @"cpuCoresByNumber")
        dict.setSectionKey("firejail", "hostsFile", @"hostsFile")
        dict.setSectionKey("firejail", "dns0", @"dns0")
        dict.setSectionKey("firejail", "dns1", @"dns1")
        dict.setSectionKey("firejail", "dns2", @"dns2")
        dict.setSectionKey("firejail", "dns3", @"dns3")
        dict.writeConfig(konfig)
      except:
        resp $getCurrentExceptionMsg()
      redirect("/settings")


  get "/settings/config":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])
    resp genMainAdmin(c, genEditConfig(readFile(replace(getAppDir(), "/nimwcpkg", "") / "config/config.cfg")))


  post "/settings/config/save":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])
    try:
      discard loadConfig(newStringStream(@"config")) # Not a strong Validation.
    except:
      resp $getCurrentExceptionMsg()
    writeFile(replace(getAppDir(), "/nimwcpkg", "") / "config/config.cfg", strip(@"config"))
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
    createTFD()
    let filename = decodeUrl(@"filename")
    var filepath = ""
    if @"access" == "private":
      if not c.loggedIn:
        resp("Error: You are not authorized")
      filepath = storageEFS / "files/private" / filename
    else:
      filepath = storageEFS / "files/public" / filename
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
    let path = "public/images" / filename
    if fileExists(path):
      resp("ERROR")
    try:
      writeFile(path, request.formData.getOrDefault("file[]").body)
      when defined(webp):
        if path.endsWith(".png") or path.endsWith(".jpg") or path.endsWith(".jpeg"):
          discard cwebp(path, path, "drawing", quality = 50) # This sets quality of WEBP
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
    let
      efspublic = storageEFS / "files/public"
      efsprivate = storageEFS / "files/private"
    var
      path: string
      filename = request.formData["file"].fields["filename"]
    let
      filedata = request.formData.getOrDefault("file").body
      fileexts = filename.splitFile.ext
      usesWebp = @"webpstatus" == "true" and fileexts in [".png", ".jpg", ".jpeg"]
    if not usesWebp and @"checksum" == "true":
      filename = getMD5(filedata) & fileexts
    if @"lowercase" == "true":
      filename = filename.toLowerAscii()
    if @"access" == "publicimage":
      path = "public/images" / filename
    elif @"access" == "public":
      assert dirExists(efspublic), "storageEFS Public Folder not found: " & efspublic
      path = efspublic / filename
    else:
      assert dirExists(efsprivate), "storageEFS Private Folder not found: " & efsprivate
      path = efsprivate / filename
    if fileExists(path):
      resp("Error: A file with the same name exists")
    writeFile(path, filedata)
    when defined(webp):
      if usesWebp:
        discard cwebp(path, path, "drawing", quality = 50) # This sets quality of WEBP
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
      let path = storageEFS / "files" / @"access" / decodeUrl(@"filename")
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
    if unlikely(not c.loggedIn): redirect("/")
    resp genMainAdmin(c, genUsers(c))


  get "/users/profile":
    createTFD()
    if unlikely(not c.loggedIn): redirect("/")
    resp genMainAdmin(c, genUsersProfile(c), "users")


  post "/users/profile/update":
    createTFD()
    restrictTestuser(HttpGet)
    if unlikely(not c.loggedIn): redirect("/")
    if @"name" == "" or @"email" == "":
      redirect("/error/" & errUserAndEmailRequired)
    if "@" notin @"email":
      redirect("/error/" & errEmailWrongFormat)
    if @"password" != @"passwordConfirm":
      redirect("/error/" & errPasswordsDontMatch)
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
    if unlikely(not c.loggedIn): redirect("/")
    try:
      when NimMajor >= 2:
        if $(Totp.init(@"twofakey").now()) == @"testcode":
          resp("Success, the code matched")
        else:
          resp("Error, code did not match")
      else:
        if $(newTotp(@"twofakey").now()) == @"testcode":
          resp("Success, the code matched")
        else:
          resp("Error, code did not match")
    except:
      resp("Error generating 2FA")


  post "/users/profile/update/save2fa":
    createTFD()
    restrictTestuser(HttpGet)
    if unlikely(not c.loggedIn): redirect("/")
    if tryExec(db, sql"UPDATE person SET twofa = ? WHERE id = ?", @"twofakey", c.userid):
      resp("Saved 2FA key")
    else:
      resp("Error saving 2FA key")


  post "/users/profile/update/disable2fa":
    createTFD()
    restrictTestuser(HttpGet)
    if unlikely(not c.loggedIn): redirect("/")
    if tryExec(db, sql"UPDATE person SET twofa = ? WHERE id = ?", "", c.userid):
      resp("Disabled 2FA key")
    else:
      resp("Error disabling 2FA key")


  get "/users/delete/@userID":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])
    if c.userid == @"userID":
      redirect("/error/" & errCantDeleteSelf)
    let userStatus = getValue(db, sql"SELECT status FROM person WHERE id = ?", @"userID")
    if userStatus == "":
      redirect("/error/" & errUnkownStatusUser)
    if userStatus == "Admin" and c.rank != Admin:
      redirect("/error/" & errCantDeleteAdmin)
    if tryExec(db, sql"DELETE FROM person WHERE id = ?", @"userID"):
      exec(db, sql"DELETE FROM session WHERE userid = ?", @"userID")
      redirect("/users")
    else:
      redirect("/error/" & errCantDeleteUser)


  post "/users/add":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin, Moderator])
    cond(@"status" in ["User", "Moderator", "Admin", "Deactivated"])
    if (c.rank != Admin and @"status" == "Admin") or c.rank == User:
      redirect("/error/" & errCantAddUserWithStat)

    if @"name" == "" or @"email" == "" or @"status" == "":
      redirect("/error/" & errNameEmailStatusRequired)

    if @"email" == "test@test.com":
      redirect("/error/" & errTestuserReserved)

    if not ("@" in @"email" and "." in @"email"):
      redirect("/error/" & errEmailWrongFormat)

    let
      emailReady = toLowerAscii(@"email")
      emailExist = getValue(db, sql"SELECT id FROM person WHERE email = ?", emailReady)

    if emailExist != "":
      redirect("/error/" & errUserAlreadyExists)

    let
      salt             = makeSalt()
      passwordOriginal = $rand(10_00_00_00_00_01.int..89_99_99_99_99_98.int) # User Must change it anyways.
      password         = makePassword(passwordOriginal, salt)
      secretUrl        = repeat($rand(10_00_00_00_00_00_00_00_00.int..int.high), 5) #.center(99, rand(toSeq('a'..'z')))

    let userID = insertID(db, sql"INSERT INTO person (name, email, status, password, salt, secretUrl) VALUES (?, ?, ?, ?, ?, ?)", @"name", emailReady, @"status", password, salt, secretUrl)

    asyncCheck sendEmailActivationManual(emailReady, @"name", passwordOriginal, "/users/activate?id=" & $userID & "&ident=" & secretUrl, c.username)

    redirect("/users")


  post "/users/reset":
    createTFD()
    restrictTestuser(HttpGet)
    restrictAccessTo(c, [Admin])
    exec(db, sql"DELETE FROM session WHERE userid = ?", @"userid")
    exec(db, sql"UPDATE person SET avatar = NULL, twofa = NULL, timezone = NULL WHERE id = ?", @"userid")
    if @"cleanout" == "true":
      exec(db, sql"DELETE FROM pages WHERE author_id = ?", @"userid")
      exec(db, sql"DELETE FROM blog WHERE author_id = ?", @"userid")
    redirect("/users")


  get "/users/activate":
    createTFD()
    if @"id" == "" or @"ident" == "":
      redirect("/error/" & errBadLink)
    let secretUrlConfirm = getValue(db, sql"SELECT id FROM person WHERE id = ? AND secretUrl = ?", @"id", @"ident")
    if secretUrlConfirm != "":
      exec(db, sql"UPDATE person SET secretUrl = NULL WHERE id = ? AND secretUrl = ?", @"id", @"ident")
      redirect("/login?msg=" & msgAccountActivated)
    else:
      redirect("/error/" & msgPleaseLogin)


  get "/users/photo/stream/@filename":
    ## Get a file
    createTFD()
    let filepath = storageEFS / "users" / decodeUrl(@"filename")
    if unlikely(not fileExists(filepath)): resp("")
    sendFile(filepath)


  post "/users/photo/upload":
    ## Uploads a new profile image for a user
    createTFD()
    restrictTestuser(c.req.reqMethod)
    if unlikely(not c.loggedIn): redirect("/")
    let path = storageEFS / "users" / c.userid
    let base64 = split(c.req.body, ",")[1]
    once: discard existsOrCreateDir(storageEFS / "users")
    try:
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
      redirect("/error/" & errBlogpostAlreadyExists)
    let status = if @"status" == "": "0" else: @"status"
    let blogID = insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords, category, tags, pubDate, viewCount) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", c.userid, status, url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"category", @"tags", @"pubdate", @"viewcount")
    redirect("/editpage/blog/" & $blogID & "?newpage=true")


  post "/blogpage/update":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    let url = encodeUrl(@"url", true).replace("%2F", "/")
    if url == getValue(db, sql"SELECT url FROM blog WHERE url = ? AND id <> ?", url, @"blogid"):
      if @"inbackground" == "true":
        resp("Error: A page with same URL already exists")
      redirect("/error/" & errBlogpostAlreadyExists)
    discard execAffectedRows(db, sql"UPDATE blog SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, title = ?, metadescription = ?, metakeywords = ?, category = ?, tags = ?, pubDate = ?, viewCount = ?, modified = ? WHERE id = ?", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"category", @"tags", @"pubdate", @"viewcount", $toInt(epochTime()), @"blogid")
    if @"inbackground" == "true": resp("OK")
    redirect("/editpage/blog/" & @"blogid")


  get "/blogpage/delete":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    exec(db, sql"DELETE FROM blog WHERE id = ?", @"blogid")
    redirect("/editpage/blogallpages")


  get "/editpage/blogallpages":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    resp genMainAdmin(c, genBlogAllPages(c, edit = true))


  get "/editpage/blog/@blogid":
    createTFD()
    restrictAccessTo(c, [Admin, Moderator])
    resp genMainAdmin(c, genEditBlog(c, @"blogid", @"newpage"), "edit")


  get "/blog":
    createTFD()
    resp genMain(c, genBlogAllPages(c, false, @"name", @"category", @"tags"))


  get re"/blog//*.":
    createTFD()
    let access = if c.loggedIn: "(0,1,2)" else: "(2)"
    let blogid = getValue(db, sql("SELECT id FROM blog WHERE url = ? AND status IN " & access), c.req.path.replace("/blog/", ""))
    if unlikely(blogid == ""): redirect("/")
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
      redirect("/error/" & errBlogpostAlreadyExists)
    let status = if @"status" == "": "0" else: @"status"
    let pageID = insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords, category, tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", c.userid, status, url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"category", @"tags")
    redirect("/editpage/page/" & $pageID & "?newpage=true")


  post "/page/update":
    createTFD()
    restrictTestuser(c.req.reqMethod)
    restrictAccessTo(c, [Admin, Moderator])
    let url = encodeUrl(@"url", true).replace("%2F", "/")
    if url == getValue(db, sql"SELECT url FROM pages WHERE url = ? AND id <> ?", url, @"pageid"):
      if  @"inbackground" == "true":
        resp("Error: A page with same URL already exists")
      redirect("/error/" & errBlogpostAlreadyExists)
    discard execAffectedRows(db, sql"UPDATE pages SET author_id = ?, status = ?, url = ?, name = ?, description = ?, standardhead = ?, standardnavbar = ?, standardfooter = ?, title = ?, metadescription = ?, metakeywords = ?, category = ?, tags = ?, modified = ? WHERE id = ?", c.userid, @"status", url, @"name", @"editordata", checkboxToInt(@"standardhead"), checkboxToInt(@"standardnavbar"), checkboxToInt(@"standardfooter"), @"title", @"metadescription", @"metakeywords", @"category", @"tags", $toInt(epochTime()), @"pageid")
    if  @"inbackground" == "true": resp("OK")
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
    resp genMainAdmin(c, genEditPage(c, @"pageid", @"newpage"), "edit")


  get re"/p//*.":
    createTFD()
    let access = if c.loggedIn: "(0,1,2)" else: "(2)"
    let pageid = getValue(db, sql("SELECT id FROM pages WHERE url = ? AND status IN " & access), c.req.path.replace("/p/", ""))
    if unlikely(pageid == ""): redirect("/")
    resp genPage(c, pageid)


#
# Sitemap
#

  get "/sitemap.xml":
    writeFile("public/sitemap.xml", genSitemap())
    sendFile("public/sitemap.xml")


#
# Other
#

  error {Http401 .. Http408}:
    createTFD()
    if error.data.code in [Http401, Http403]: pass
    resp error.data.code, "<h1>Page not found</h1><p>You should go back.</p>"
