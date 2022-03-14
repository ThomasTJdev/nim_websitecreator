## Do NOT import this file directly, instead import ``database.nim``

proc backupDb*(dbname: string,
    filename = "backup" / fileBackup & replace($now(), ":", "_") & ".sql",
    host = "localhost", port = Port(5432), username = getEnv("USER", "root"),
    dataOnly = false, inserts = false, checksum = true, sign = true, targz = true): tuple[output: string, exitCode: int] =
  ## Backup the whole Database to a plain-text Raw SQL Query human-readable file.
  if dbname.len == 0 or host.len == 0 or username.len == 0:
    return ("Error #1", 1)

  if (when defined(postgres): findExe("pg_dump").len == 0 else: findExe("sqlite3").len == 0):
    return ("Error #2", 2)

  setCurrentDir(nimwcpkgDir)
  once: discard existsOrCreateDir(nimwcpkgDir / "backup")

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
