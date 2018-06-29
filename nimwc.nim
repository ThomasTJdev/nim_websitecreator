import osproc, os, sequtils


var runInLoop = true

proc handler() {.noconv.} =
  ## Catch ctrl+c from user

  runInLoop = false
  discard execCmd("pkill nimwc")
  echo "Program quitted."

setControlCHook(handler)


proc checkCompileOptions(): string =
  # Checking for known compile options
  # and returning them as a space separated string.
  # See README.md for explation of the options.
  
  result = ""

  when defined(nginx):
    result.add(" -d:nginx")
  when defined(adminnotify):
    result.add(" -d:adminnotify")
  when defined(dev):
    result.add(" -d:dev")
  when defined(devemailon):
    result.add(" -d:devemailon")
  when defined(demo):
    result.add(" -d:demo")
  when defined(ssl):
    result.add(" -d:ssl")

  return result
  
let compileOptions = checkCompileOptions()


# User specified args
template addArgs(inExec = false): string =
  let args = foldl(commandLineParams(), a & (b & " "), "")

  if inExec:
    " --run " & args
  else:
    " " & args


proc launcherActivated() =
  # 1) Executing the main-program in a loop.
  # 2) Each time the main-program quits, there's a check
  # for a new version
  echo "Nim Website Creator: Launcher initialized"
  while runInLoop:
    if fileExists(getAppDir() & "/nimwcpkg/nimwc_main_new"):
      moveFile(getAppDir() & "/nimwcpkg/nimwc_main_new", getAppDir() & "/nimwc_main")
    echo "Starting program"
    echo addArgs(true)
    discard execCmd(getAppDir() & "/nimwcpkg/nimwc_main" & addArgs(true))
    echo "Program exited. In 1.5 seconds, the program starts again."
    echo "To fully exit pres ctrl+c"
    sleep(1500)
  echo "Nim Website Creator: Quitted"
  quit()


# Checking if the main-program file exists. If not it will
# be compiled with args and compiler options (compiler
# options should be specified in the *.nim.pkg)
if not fileExists(getAppDir() & "/nimwcpkg/nimwc_main") or defined(rc):
  echo "Compiling"
  echo " - Using params:" & addArgs()
  echo " - Using compile options in *.nim.cfg"
  echo " "
  echo " .. please wait while compiling"
  let output = execCmd("nim c " & compileOptions & " " & getAppDir() & "/nimwcpkg/nimwc_main.nim")
  if output == 1:
    echo "\nAn error occured"
  else:
    echo "\n"
    echo """Compiling done. 
    
  - To start Nim Website Creator and access at 127.0.0.1:<port>
    # Manually compiled
    ./nimwc

    # Through nimble, then just run with symlink
    nimwc
    
  - To add an admin user, append args:
    ./nimwc newuser -u:name -p:password -e:email
    
  - To insert standard data in the database, append args:
    ./nimwc insertdata



    """

else:
  launcherActivated()