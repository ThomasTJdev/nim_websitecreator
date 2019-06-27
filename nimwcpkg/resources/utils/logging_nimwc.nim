import os, parsecfg, times, logging
from strutils import replace
import ../email/email_admin


let nimwcpkgDir = getAppDir().replace("/nimwcpkg", "")
let configFile = nimwcpkgDir / "config/config.cfg"
assert existsDir(nimwcpkgDir), "nimwcpkg directory not found"
assert existsFile(configFile), "config/config.cfg file not found"

setCurrentDir(nimwcpkgDir)
discard existsOrCreateDir("log")

let
  dict = loadConfig(configFile)
  fileDebug = dict.getSectionValue("Logging", "logfiledev")
  fileProd =  dict.getSectionValue("Logging", "logfile")

var
  consoleLogger = newConsoleLogger(fmtStr = verboseFmtStr) # Logs to terminal.
  rollingFileLogger = newRollingFileLogger( # Logs to rotating files.
    when defined(release): fileProd else: fileDebug, fmtStr = verboseFmtStr)

addHandler(consoleLogger)
addHandler(rollingFileLogger)

template log2admin*(msg: string) =
  ## Logs the error messages to Admin via mail if ``adminnotify`` is defined.
  assert msg.len > 0, "msg must not be empty string"
  if "adminnotify" in commandLineParams() or defined(adminnotify):
    discard sendEmailAdminError($now() & " - " & msg)
  else:
    error(msg)

debug("Rolling File Logger logs at: " & defaultFilename())
