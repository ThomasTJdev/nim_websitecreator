import os, osproc, parsecfg, times, logging, strutils
import ../constants/constants, ../emails/emails


let nimwcpkgDir = getAppDir().replace("/nimwcpkg", "")
let configFile = nimwcpkgDir / "config/config.cfg"
assert dirExists(nimwcpkgDir), "nimwcpkg directory not found: " & nimwcpkgDir
assert fileExists(configFile), "config/config.cfg file not found"

setCurrentDir(nimwcpkgDir)
once: discard existsOrCreateDir("log")

addHandler(newConsoleLogger(fmtStr = verboseFmtStr))
addHandler(newRollingFileLogger( # Logs to rotating files.
  when defined(release): loadConfig(configFile).getSectionValue("Logging", "logfile")
  else: loadConfig(configFile).getSectionValue("Logging", "logfiledev"),
  fmtStr = verboseFmtStr))
debug("Rolling File Logger logs at: " & defaultFilename())


template log2admin*(msg: string) =
  ## Logs the error messages to Admin via mail if ``adminnotify`` is defined.
  assert msg.len > 0, "msg must not be empty string"
  when defined(adminnotify): discard sendEmailAdminError($now() & " - " & msg)
  else: error(msg)


proc backupOldLogs*(logFilePath: string): tuple[output: string, exitCode: int] =
  ## Compress all old rotated Logs.
  assert dirExists(logFilePath), "logFilePath File not found"
  assert findExe("tar").len > 0, "Tar not found"
  var files2tar: seq[string]
  for logfile in walkFiles(logFilePath / "*.log"): files2tar.add logfile
  if files2tar.len > 1:
    let cmd = cmdTar & logFilePath / "logs-" & replace($now(), ":", "_") & ".tar.gz " & files2tar.join" "
    result = execCmdEx(cmd)
    if result.exitCode == 0:
      for filename in files2tar: discard tryRemoveFile(filename)
