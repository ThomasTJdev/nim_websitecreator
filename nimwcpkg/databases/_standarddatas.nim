## Do NOT import this file directly, instead import ``database.nim``

proc standardDataSettings*(db: DbConn, dataStyle = cssBulma) =
  ## Settings
  info("Standard data: Inserting settings-data.")

  exec []:
    delete "settings"

  case dataStyle
  of cssWater:
    discard insertID(db, standarddatas_standardDataSettings0, title, headClean, navbarClean, footerClean)
  of cssOfficial:
    discard insertID(db, standarddatas_standardDataSettings0, title, headOfficial, navbarOfficial, footerOfficial)
    writeFile("public/js/js_custom.js", officialJs)
    writeFile("public/css/style_custom.css", officialCss)
  else:
    discard insertID(db, standarddatas_standardDataSettings0, title, head, navbar, footer)


proc standardDataFrontpage*(db: DbConn, dataStyle = cssBulma) =
  ## Frontpage
  info("Standard data: Inserting frontpage-data.")

  let frontpageExists: string = getValue []:
    select "id"
    `from` "pages"
    where  "url = 'frontpage'"

  if frontpageExists != "":
    exec @[frontpageExists]:
      delete "pages"
      where  "id = ?"

  if dataStyle == cssWater:
    discard insertID(db, standarddatas_standardDataFrontpage0, "1", "2", "frontpage", "Frontpage", frontpageClean, "1", "1", "1", "", "", "")
  elif dataStyle == cssOfficial:
    discard insertID(db, standarddatas_standardDataFrontpage0, "1", "2", "frontpage", "Frontpage", frontpageOfficial, "1", "1", "1", "", "", "")
  else:
    discard insertID(db, standarddatas_standardDataFrontpage0, "1", "2", "frontpage", "Frontpage", frontpage, "1", "1", "1", "NimWC Nim Website Creator", "NimWC is an online webpage editor for users with little HTML knowledge, but it also offers experienced users a freedom to customize everything.", "website,blog,nim,nimwc")


proc standardDataAbout*(db: DbConn) =
  ## About
  info("Standard data: Inserting about-data.")

  let aboutExists: string = getValue []:
    select "id"
    `from` "pages"
    where  "url = 'about'"

  if aboutExists != "":
    exec @[aboutExists]:
      delete "pages"
      where  "id = ?"

  discard insertID(db, standarddatas_standardDataFrontpage0,
    "1", "2", "about", "About", about, "1", "1", "1", "About Nim Website Creator", "NimWC is an online webpage editor for users with little HTML knowledge, but it also offers experienced users a freedom to customize everything.", "website,blog,nim,nimwc")


proc standardDataBlogpost1*(db: DbConn) =
  ## Blog post
  info("Standard data: Inserting blog post-data (1).")

  let blogExists: string = getValue []:
    select "id"
    `from` "blog"
    where  "url = 'standardpost'"

  if blogExists != "":
    exec @[blogExists]:
      delete "blog"
      where  "id = ?"

  discard insertID(db, standarddatas_standardDataBlogpost0,
    "1", "2", "standardpost", "Standard blogpost", blogpost1, "1", "1", "1", "NimWC Example blogpost", "This is an example blogpost using the default styling.", "website,blog,nim,nimwc")


proc standardDataBlogpost2*(db: DbConn) =
  ## Blog post
  info("Standard data: Inserting blog post-data (2).")

  let blogExists: string = getValue []:
    select "id"
    `from` "blog"
    where  "url = 'standardpostv2'"

  if blogExists != "":
    exec @[blogExists]:
      delete "blog"
      where  "id = ?"

  discard insertID(db, standarddatas_standardDataBlogpost0,
    "1", "2", "standardpostv2", "Parallax post v2", blogpost2, "1", "1", "1", "NimWC Example blogpost parallax", "This is an example blogpost using parallax created with NimWC.", "website,blog,nim,nimwc,parallax")


proc standardDataBlogpost3*(db: DbConn) =
  ## Blog post
  info("Standard data: Inserting blog post-data (3).")

  let blogExists: string = getValue []:
    select "id"
    `from` "blog"
    where  "url = 'standardpostv3'"

  if blogExists != "":
    exec @[blogExists]:
      delete "blog"
      where  "id = ?"

  discard insertID(db, standarddatas_standardDataBlogpost0,
    "1", "2", "standardpostv3", "Custom styling", blogpost3, "1", "1", "1", "NimWC Example blogpost custom", "This is an example blogpost using custom styling.", "website,blog,nim,nimwc")


proc createStandardData*(db: DbConn, dataStyle = cssBulma, confirm = false) {.discardable.} =
  ## Insert basic data
  if confirm and readLineFromStdin("Insert (overwrite) with standard " & $dataStyle & " data? (y/n): ").normalize != "y":
    info("Standard data: Exited by user")
    return

  info("Standard data: Inserting standard data.")
  standardDataSettings(db, dataStyle)
  standardDataFrontpage(db, dataStyle)
  if dataStyle != cssWater:
    standardDataAbout(db)
    standardDataBlogpost1(db)
    standardDataBlogpost2(db)
    standardDataBlogpost3(db)
