import os, parsecfg, strutils, times

import ../email/email_admin


let fileDebug = getAppDir() & "/log/debug.log"
let fileProd = getAppDir() & "/log/log.log"

discard existsOrCreateDir("log")

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

        when defined adminnotify:
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
