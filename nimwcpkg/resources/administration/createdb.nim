import os, strutils, contra, osproc, logging, times, nativesockets

when defined(postgres): import db_postgres
else:                   import db_sqlite

import ../../constants/constants


let nimwcpkgDir = getAppDir().replace("/nimwcpkg", "")
const configFile = "config/config.cfg"
assert existsDir(nimwcpkgDir), "nimwcpkg directory not found: " & nimwcpkgDir
assert existsFile(configFile), "config/config.cfg file not found: " & configFile
setCurrentDir(nimwcpkgDir)


proc generateDB*(db: DbConn) =
  info("Database: Generating database tables")

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


proc backupDb*(dbname: string,
    filename = "backup" / fileBackup & replace($now(), ":", "_") & ".sql",
    host = "localhost", port = Port(5432), username = getEnv("USER", "root"),
    dataOnly = false, inserts = false, checksum = true, sign = true, targz = true): tuple[output: TaintedString, exitCode: int] =
  ## Backup the whole Database to a plain-text Raw SQL Query human-readable file.
  preconditions(dbname.len > 0, host.len > 0, username.len > 0,
    when defined(postgres): findExe("pg_dump").len > 0 else: findExe("sqlite3").len > 0)

  discard existsOrCreateDir(nimwcpkgDir / "backup")

  when defined(postgres):
    var cmd = cmdBackup.format(host, $port, username, filename, dbname,
    (if dataOnly: " --data-only " else: "") & (if inserts: " --inserts " else: ""))
  else:  # TODO: SQLite .dump is Not working, Docs says it should.
    var cmd = cmdBackup.format(dbname, filename)

  when not defined(release): info("Database backup: " & cmd)
  result = execCmdEx(cmd)

  if checksum and result.exitCode == 0 and findExe("sha512sum").len > 0:
    cmd = cmdChecksum & filename & " > " & filename & ".sha512"
    when not defined(release): info("Database backup (sha512sum): " & cmd)
    result = execCmdEx(cmd)

    if sign and result.exitCode == 0 and findExe("gpg").len > 0:
      cmd = cmdSign & filename
      when not defined(release): info("Database backup (gpg): " & cmd)
      result = execCmdEx(cmd)

      if targz and result.exitCode == 0 and findExe("tar").len > 0:
        cmd = cmdTar & filename & ".tar.gz " & filename & " " & filename & ".sha512 " & filename & ".asc"

        when not defined(release): info("Database backup (tar): " & cmd)
        result = execCmdEx(cmd)

        if result.exitCode == 0:
          removeFile(filename)
          removeFile(filename & ".sha512")
          removeFile(filename & ".asc")

  if result.exitCode == 0:
    info("Database backup: Done - " & filename)
  else:
    info("Database backup: Fail - " & filename)


template vacuumDb*(db: DbConn): bool =
  echo "Vacuum database (database maintenance)"
  db.tryExec(sqlVacuum)
