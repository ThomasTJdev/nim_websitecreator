import os, parsecfg, strutils, times

import ../email/email_admin


setCurrentDir(getAppDir().replace("/nimwcpkg", "") & "/")

let dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")

let fileDebug = dict.getSectionValue("Logging","logfiledev")
let fileProd =  dict.getSectionValue("Logging","logfile")

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
    debugEcho $getTime() & " - " & logLevel & ": " & msg
    when not defined(nolog) and logLevel in ["DEBUG", "INFO", "WARNING", "ERROR"]:
      logFile(fileDebug, $getTime() & " - " & logLevel &  ": " & msg)


  when defined release:
    if logLevel == "ERROR":
      debugEcho $getTime() & " - " & logLevel &  ": " & msg

    when not defined(nolog):
      when defined(logleveldebug) and logLevel in ["DEBUG", "INFO", "WARNING", "ERROR"]:
        logFile(fileProd, $getTime() & " - " & logLevel &  ": " & msg)
      
      when defined(loglevelinfo) and logLevel in ["INFO", "WARNING", "ERROR"]:
        logFile(fileProd, $getTime() & " - " & logLevel &  ": " & msg)
        
      elif loglevel in ["ERROR", "WARNING"]:
        logFile(fileProd, $getTime() & " - " & logLevel &  ": " & msg)

        if "adminnotify" in commandLineParams() or  defined(adminnotify):
          discard sendEmailAdminError($getTime() & " - " & logLevel &  ": " & msg)


template logFile*(filename, msg: string, mode = fmAppend): typed =
  ## Append data to file
  ## Use logFile("filename.txt", "message to append")

  let fn = filename
  var f: File
  if open(f, fn, mode):
    try:
      f.writeLine(msg)
    finally:
      close(f)
  else:
    quit("cannot open: " & fn)


dbg("DEBUG", "Checking that required 'log' folder exists")
discard existsOrCreateDir("log")