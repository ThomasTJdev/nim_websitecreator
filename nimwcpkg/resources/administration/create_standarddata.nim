import logging, strutils

from rdstdin import readLineFromStdin

when defined(postgres): import db_postgres
else:                   import db_sqlite

import ../../constants/constants, ../../enums/enums
export head, navbar, footer, title  # HTML template fragments


proc standardDataSettings*(db: DbConn, dataStyle = cssBulma) =
  ## Settings
  info("Standard data: Inserting settings-data.")
  exec(db, sql"DELETE FROM settings")
  const sqlDataSettings = sql"INSERT INTO settings (title, head, navbar, footer) VALUES (?, ?, ?, ?)"
  case dataStyle
  of cssBootstrap:
    discard insertID(db, sqlDataSettings, title, headBootstrap, navbarBootstrap, footer)
  of cssClean:
    discard insertID(db, sqlDataSettings, title, headClean, navbarClean, footerClean)
  else:
    discard insertID(db, sqlDataSettings, title, head, navbar, footer)


proc standardDataFrontpage*(db: DbConn, dataStyle = cssBulma) =
  ## Frontpage
  info("Standard data: Inserting frontpage-data.")
  const sqlFrontpageExist = sql"SELECT id FROM pages WHERE url = 'frontpage'"
  let frontpageExists = getValue(db, sqlFrontpageExist)
  if frontpageExists != "":
    exec(db, sql"DELETE FROM pages WHERE id = ?", frontpageExists)
  const sqlFrontpageData = sql"""
    INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"""
  if dataStyle == cssClean:
    discard insertID(db, sqlFrontpageData, "1", "2", "frontpage", "Frontpage", frontpageClean, "1", "1", "1", "", "", "")
  else:
      discard insertID(db, sqlFrontpageData, "1", "2", "frontpage", "Frontpage", frontpage, "1", "1", "1", "NimWC Nim Website Creator", "NimWC is an online webpage editor for users with little HTML knowledge, but it also offers experienced users a freedom to customize everything.", "website,blog,nim,nimwc")


proc standardDataAbout*(db: DbConn) =
  ## About
  info("Standard data: Inserting about-data.")
  const sqlAboutExists = sql"SELECT id FROM pages WHERE url = 'about'"
  let aboutExists = getValue(db, sqlAboutExists)
  if aboutExists != "":
    exec(db, sql"DELETE FROM pages WHERE id = ?", aboutExists)

  discard insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "about", "About", about, "1", "1", "1", "About Nim Website Creator", "NimWC is an online webpage editor for users with little HTML knowledge, but it also offers experienced users a freedom to customize everything.", "website,blog,nim,nimwc")


proc standardDataBlogpost1*(db: DbConn) =
  ## Blog post
  info("Standard data: Inserting blog post-data (1).")
  const sqlBlogExists = sql"SELECT id FROM blog WHERE url = 'standardpost'"
  let blogExists = getValue(db, sqlBlogExists)
  if blogExists != "":
    exec(db, sql"DELETE FROM blog WHERE id = ?", blogExists)

  discard insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "standardpost", "Standard blogpost", blogpost1, "1", "1", "1", "NimWC Example blogpost", "This is an example blogpost using the default styling.", "website,blog,nim,nimwc")


proc standardDataBlogpost2*(db: DbConn) =
  ## Blog post
  info("Standard data: Inserting blog post-data (2).")
  const sqlBlog2Exists = sql"SELECT id FROM blog WHERE url = 'standardpostv2'"
  let blogExists = getValue(db, sqlBlog2Exists)
  if blogExists != "":
    exec(db, sql"DELETE FROM blog WHERE id = ?", blogExists)

  discard insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "standardpostv2", "Parallax post v2", blogpost2, "1", "1", "1", "NimWC Example blogpost parallax", "This is an example blogpost using parallax created with NimWC.", "website,blog,nim,nimwc,parallax")


proc standardDataBlogpost3*(db: DbConn) =
  ## Blog post
  info("Standard data: Inserting blog post-data (3).")
  const sqlBlog3Exists = sql"SELECT id FROM blog WHERE url = 'standardpostv3'"
  let blogExists = getValue(db, sqlBlog3Exists)
  if blogExists != "":
    exec(db, sql"DELETE FROM blog WHERE id = ?", blogExists)

  discard insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter, title, metadescription, metakeywords) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "standardpostv3", "Custom styling", blogpost3, "1", "1", "1", "NimWC Example blogpost custom", "This is an example blogpost using custom styling.", "website,blog,nim,nimwc")


proc createStandardData*(db: DbConn, dataStyle = cssBulma, confirm = false) {.discardable.} =
  ## Insert basic data
  if confirm and readLineFromStdin("Insert (overwrite) with standard " & $dataStyle & " data? (y/n): ").normalize != "y":
    info("Standard data: Exited by user")
    return

  info("Standard data: Inserting standard data.")
  standardDataSettings(db, dataStyle)
  standardDataFrontpage(db, dataStyle)
  if dataStyle != cssClean:
    standardDataAbout(db)
    standardDataBlogpost1(db)
    standardDataBlogpost2(db)
    standardDataBlogpost3(db)
