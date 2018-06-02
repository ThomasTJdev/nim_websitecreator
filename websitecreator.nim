import osproc, os, sequtils


var runInLoop = true

proc handler() {.noconv.} =
  ## Catch ctrl+c from user

  runInLoop = false
  discard execCmd("pkill websitecreator")
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
    if fileExists(getAppDir() & "/websitecreator_main_new"):
      moveFile(getAppDir() & "/websitecreator_main_new", getAppDir() & "/websitecreator_main")
    echo "Starting program"
    echo addArgs(true)
    discard execCmd(getAppDir() & "/websitecreator_main" & addArgs(true))
    echo "Program exited. In 1.5 seconds, the program starts again."
    echo "To fully exit pres ctrl+c"
    sleep(1500)
  echo "Nim Website Creator: Quitted"
  quit()


# Checking if the main-program file exists. If not it will
# be compiled with args and compiler options (compiler
# options should be specified in the *.nim.pkg)
if not fileExists(getAppDir() & "/websitecreator_main") or compileOptions != "":
  echo "Compiling"
  echo " - Using params:" & addArgs()
  echo " - Using compile options in *.nim.cfg"
  echo " "
  echo " .. please wait while compiling"
  let output = execCmd("nim c " & compileOptions & " " & getAppDir() & "/websitecreator_main.nim")
  if output == 1:
    echo "\nAn error occured"
  else:
    echo "\n"
    echo """Compiling done. 
    
  - To start Nim Website Creator and access at 127.0.0.1:<port>
    ./websitecreator
    
  - To add an admin user, append args:
    ./websitecreator newuser -u:name -p:password -e:email
    
  - To insert standard data in the database, append args:
    ./websitecreator insertdata

    """

else:
  launcherActivated()