  get "/themes/settings":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      resp genMain(c, genThemesSettings(c, @"msg"))

  get "/themes/apply":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      let sheetName = @"stylesheetname"
      let currentStylesheet = currentStylesheet()

      # Copy stylesheet to public folder
      discard execCmd("cp plugins/themes/stylesheets/" & sheetName & " public/css/style.css")

      redirect("/themes/settings")

  get "/themes/newsheet":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      if @"stylesheetname" == "":
        redirect("/themes/settings?msg=" & encodeUrl("Missing new name"))

      if @"stylesheetname" == "style.css":
        redirect("/themes/settings?msg=" & encodeUrl("You can not name the new sheet style.css"))

      discard execCmd("cp public/css/style.css plugins/themes/stylesheets/" & @"stylesheetname")
      redirect("/themes/settings")

  get "/themes/update":
    createTFD()
    if c.loggedIn and c.rank in [Admin, Moderator]:
      let sheetName = @"stylesheetname"
      let currentStylesheet = currentStylesheet()

      if sheetName != currentStylesheet:
        redirect("/themes/settings?msg=" & encodeUrl("Stylesheet names does not match"))

      discard execCmd("cp public/css/" & sheetName & " plugins/themes/stylesheets/" & sheetName)
      redirect("/themes/settings")
