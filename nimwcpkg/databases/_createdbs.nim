
## Do NOT import this file directly, instead import ``database.nim``

proc generateDB*(db: DbConn) =
  info("Database: Generating database tables")
  setCurrentDir(nimwcpkgDir)
  # User
  if not db.tryExec(personTable):
    info("Database: Could not create table person")

  # Session
  if not db.tryExec(sessionTable):
    info("Database: Could not create table session")

  # History
  if not db.tryExec(historyTable):
    info("Database: Could not create table history")

  # Settings
  if not db.tryExec(settingsTable):
    info("Database: Could not create table settings")

  # Pages
  if not db.tryExec(pagesTable):
    info("Database: Could not create table pages")

  # Blog
  if not db.tryExec(blogTable):
    info("Database: Could not create table blog")

  # Files
  if not db.tryExec(filesTable):
    info("Database: Could not create table files")
