## Do NOT import this file directly, instead import ``database.nim``

proc backupDb*(dbname: string,
    filename = "backup" / fileBackup & replace($now(), ":", "_") & ".sql",
    host = "localhost", port = Port(5432), username = getEnv("USER", "root"),
    dataOnly = false, inserts = false, checksum = true, sign = true, targz = true): tuple[output: TaintedString, exitCode: int] =
  ## Backup the whole Database to a plain-text Raw SQL Query human-readable file.
  assert dbname.len > 0 and host.len > 0 and username.len > 0
  const optionsx = {poStdErrToStdOut, poUsePath, poEchoCmd} # poEchoCmd does echo cmd
  setCurrentDir(nimwcpkgDir)
  once: discard existsOrCreateDir(nimwcpkgDir / "backup")

  when defined(postgres):
    var cmd = cmdBackup.format(host, $port, username, filename, dbname,
    (if dataOnly: " --data-only " else: "") & (if inserts: " --inserts " else: ""))
  else:  # TODO: SQLite .dump is Not working, Docs says it should.
    var cmd = cmdBackup.format(dbname, filename)
  result = execCmdEx(cmd, options = optionsx)

  if checksum and result.exitCode == 0 and findExe("sha512sum").len > 0:
    result = execCmdEx(cmdChecksum & filename & " > " & filename & ".sha512", options = optionsx)

    if sign and result.exitCode == 0 and findExe("gpg").len > 0:
      result = execCmdEx(cmdSign & filename, options = optionsx)

      if targz and result.exitCode == 0 and findExe("tar").len > 0:
        result = execCmdEx(
          cmdTar & filename & ".tar.gz " & filename & " " & filename & ".sha512 " & filename & ".asc",
          options = optionsx
        )

        if result.exitCode == 0:
          removeFile(filename)
          removeFile(filename & ".sha512")
          removeFile(filename & ".asc")

  if result.exitCode == 0:
    info("Database backup: Done - " & filename)
  else:
    info("Database backup: Fail - " & filename)
