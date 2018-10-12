import osproc, os, sequtils, times, strutils, terminal

const
  update_cmds = [
    "mv plugins/plugin_import.txt tmp/plugin_import.txt",
    "mv plugins/css/style_custom.css tmp/style_custom.css",
    "mv plugins/js/js_custom.js tmp/js_custom.js",

    "git fetch --all",
    "git reset --hard origin/master",

    "mv tmp/plugin_import.txt plugins/plugin_import.txt",
    "mv tmp/style_custom.css plugins/css/style_custom.css",
    "mv tmp/js_custom.js plugins/js/js_custom.js",
  ]  ## Bash Commands to Update NimWC.

  compile_start_msg =  """Compiling, Please wait...
  - Using compile options from *.nim.cfg
  - Using params: """  ## Message to show when started Compiling.

  compile_ok_msg =  """Compiling done!.

  - To start Nim Website Creator and access at http://127.0.0.1:<port>
    # Manually compiled
    ./nimwc

    # Through nimble, then just run with symlink
    nimwc

  - To add an admin user, append args:
    ./nimwc newuser -u:name -p:password -e:email

  - To insert standard data in the database, append args:
    ./nimwc insertdata

  - Access Settings page at http://127.0.0.1:<port>/settings
  """  ## Message to show when finished Compiling OK.

  compile_fail_msg = """Compiling Failed.
  - A Compile-time or Configuration error occurred.
    You can check your source code with: nim check
    Check the Configuration of NimWC and its Plugins.
  """  ## Message to show when Compiling Failed.

var
  runInLoop = true
  nimhaMain: Process

proc handler() {.noconv.} =
  ## Catch ctrl+c from user

  runInLoop = false
  kill(nimhaMain)
  styledEcho(fgYellow, bgBlack, "CTRL+C Pressed, NimWC is shutting down.")
  quit()

setControlCHook(handler)


proc checkCompileOptions(): string =
  ## Checking for known compile options
  ## and returning them as a space separated string.
  ## See README.md for explanation of the options.

  result = ""

  when defined(adminnotify):
    result.add(" -d:adminnotify")
  when defined(dev):
    result.add(" -d:dev")
  when defined(devemailon):
    result.add(" -d:devemailon")
  when defined(demo):
    result.add(" -d:demo")
  when defined(demoloadbackup):
    result.add(" -d:demoloadbackup")
  when defined(ssl):
    result.add(" -d:ssl")

  return result

let compileOptions = checkCompileOptions()


template addArgs(inExec = false): string =
  ## User specified args

  #var args = foldl(commandLineParams(), a & (b & ""), "")
  var args = commandLineParams().join(" ")

  if args == "":
    ""

  elif inExec:
    " --run " & args

  else:
    " " & args


proc launcherActivated() =
  ## 1) Executing the main-program in a loop.
  ## 2) Each time a new compiled file is available,
  ##    the program exits the running process and starts a new
  styledEcho(fgGreen, bgBlack, $now() & ": Nim Website Creator: Launcher initialized")

  nimhaMain = startProcess(getAppDir() & "/nimwcpkg/nimwc_main" & addArgs(true), options = {poParentStreams, poEvalCommand})

  while runInLoop:
    if fileExists(getAppDir() & "/nimwcpkg/nimwc_main_new"):
      kill(nimhaMain)
      moveFile(getAppDir() & "/nimwcpkg/nimwc_main_new", getAppDir() & "/nimwcpkg/nimwc_main")

    if not running(nimhaMain):
      styledEcho(fgYellow, bgBlack, $now() & ": Restarting program in 1 second")

      discard execCmd("pkill nimwc_main")
      sleep(1000)

      let args = addArgs(true)
      if args != "":
        echo " Using args: " & args

      nimhaMain = startProcess(getAppDir() & "/nimwcpkg/nimwc_main" & addArgs(true), options = {poParentStreams, poEvalCommand})

    sleep(2000)

  styledEcho(fgYellow, bgBlack, $now() & ": Nim Website Creator: Quitted")
  quit()


proc startupCheck() =
  ## Checking if the main-program file exists. If not it will
  ## be compiled with args and compiler options (compiler
  ## options should be specified in the *.nim.pkg)
  if not fileExists(getAppDir() & "/nimwcpkg/nimwc_main") or defined(rc):
    styledEcho(fgGreen, bgBlack, compile_start_msg & addArgs())
    let output = execCmd("nim c " & compileOptions & " " & getAppDir() & "/nimwcpkg/nimwc_main.nim")
    if output == 1:
      styledEcho(fgRed, bgBlack, compile_fail_msg)
      quit()
    else:
      styledEcho(fgGreen, bgBlack,  compile_ok_msg)


proc updateNimwc() =
  ## GIT hard update
  if "gitupdate" in commandLineParams() or defined(gitupdate):
    discard existsOrCreateDir("tmp")
    for comand in update_cmds:
       discard execCmd(comand)
    styledEcho(fgGreen, bgBlack, "\n\nNimWC has been updated\n\n")
    quit()


updateNimwc()
startupCheck()
launcherActivated()
