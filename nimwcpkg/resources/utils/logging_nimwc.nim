import os, parsecfg, times, logging
from strutils import replace
import ../email/email_admin


let nimwcpkgDir = getAppDir().replace("/nimwcpkg", "")
let configFile = nimwcpkgDir / "config/config.cfg"
assert existsDir(nimwcpkgDir), "nimwcpkg directory not found: " & nimwcpkgDir
assert existsFile(configFile), "config/config.cfg file not found"

setCurrentDir(nimwcpkgDir)
discard existsOrCreateDir("log")

addHandler(newConsoleLogger(fmtStr = verboseFmtStr))
addHandler(newRollingFileLogger( # Logs to rotating files.
  when defined(release): loadConfig(configFile).getSectionValue("Logging", "logfile")
  else: loadConfig(configFile).getSectionValue("Logging", "logfiledev"),
  fmtStr = verboseFmtStr))


template log2admin*(msg: string) =
  ## Logs the error messages to Admin via mail if ``adminnotify`` is defined.
  assert msg.len > 0, "msg must not be empty string"
  when defined(adminnotify): discard sendEmailAdminError($now() & " - " & msg)
  else: error(msg)

debug("Rolling File Logger logs at: " & defaultFilename())
