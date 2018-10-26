import os, parsecfg, strutils, times, logging
import ../email/email_admin


setCurrentDir(getAppDir().replace("/nimwcpkg", "") & "/")

let
  dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
  fileDebug = dict.getSectionValue("Logging","logfiledev")
  fileProd =  dict.getSectionValue("Logging","logfile")

var
  console_logger = newConsoleLogger(fmtStr = verboseFmtStr) # Logs to terminal.
  rolling_file_logger = newRollingFileLogger( # Logs to rotating files.
    when defined(release): fileProd else: fileDebug, fmtStr = verboseFmtStr)

addHandler(console_logger)
addHandler(rolling_file_logger)

template dbg*(logLevel, msg: string) =
  ## Echo debug
  ## Removed when compiling with -d:release
  ##
  ## LogLevels:
  ## 1) INFO,
  ## 2) DEBUG,
  ## 3) WARNING,
  ## 4) ERROR

  when not defined(release):
    when not defined(nolog) and logLevel in ["DEBUG", "INFO", "WARNING", "ERROR"]:
      debug msg


  when defined release:
    if logLevel == "ERROR":
      error msg

    when not defined(nolog):
      when defined(logleveldebug) and logLevel in ["DEBUG", "INFO", "WARNING", "ERROR"]:
        debug msg

      when defined(loglevelinfo) and logLevel in ["INFO", "WARNING", "ERROR"]:
        info msg

      elif loglevel in ["ERROR", "WARNING"]:
        error msg

        if "adminnotify" in commandLineParams() or  defined(adminnotify):
          discard sendEmailAdminError($getTime() & " - " & logLevel & ": " & msg)


discard existsOrCreateDir("log")
dbg("DEBUG", "Checking that required 'log' folder exists")
dbg("DEBUG", "Rolling File Logger logs at: " & defaultFilename())
