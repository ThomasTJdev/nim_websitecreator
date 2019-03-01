import os, parsecfg, times, logging, strutils
import ../email/email_admin

setCurrentDir(getAppDir().replace("/nimwcpkg", "") & "/")
discard existsOrCreateDir("log")

let
  dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
  fileDebug = dict.getSectionValue("Logging", "logfiledev")
  fileProd =  dict.getSectionValue("Logging", "logfile")

var
  console_logger = newConsoleLogger(fmtStr = verboseFmtStr) # Logs to terminal.
  rolling_file_logger = newRollingFileLogger( # Logs to rotating files.
    when defined(release): fileProd else: fileDebug, fmtStr = verboseFmtStr)

addHandler(console_logger)
addHandler(rolling_file_logger)

template log2admin*(msg: string) =
  ## Logs the error messages to Admin via mail if ``adminnotify`` is defined.
  if "adminnotify" in commandLineParams() or  defined(adminnotify):
    discard sendEmailAdminError($now() & " - " & msg)
  else:
    error(msg)

debug("Rolling File Logger logs at: " & defaultFilename())
