import osproc, os, sequtils, times, strutils


let doc = """
nimwc: Nim Website Creator.
A quick website tool. Run the nim file and access your webpage.

Usage:
  nimwc <optional params>

Options:
  -h --help             Show this output.
  --newuser             Add an admin user. Combine with -u, -p and -e.
    -u:<admin username>
    -p:<admin password>
    -e:<admin email>`
  --insertdata          Insert standard data (this will override existing data).
  --newdb               Generates the database with standard tables (does **not**
                        override or delete tables). `newdb` will be initialized
                        automatic, if no database exists.
  --gitupdate           Updates and force a hard reset.

Compile options:
  -d:rc                 Recompile. NinmWC is using a launcher, it is therefore
                        needed to force a recompile.
  -d:adminnotify        Send error logs (ERROR) to the specified admin email
  -d:dev                Development (ignore reCaptcha)
  -d:devemailon         Send email when `-d:dev` is activated
  -d:demo               Used on public test site. Enables a test user.
  -d:demoloadbackup     Used with -d:demo. This option will override the
                        database each hour with the file named `website.bak.db`.
                        You can customize the page and make a copy of the
                        database and name it `website.bak.db`, then it will be
                        used by this feature.
  -d:gitupdate          Updates and force a hard reset
"""


## Vars
var runInLoop = true
var nimhaMain: Process


## Parse commandline params
let args = replace(commandLineParams().join(" "), "-", "")
let userArgs = if args == "": "" else: " " & args
let userArgsRun = if args == "": "" else: " --run " & args


proc handler() {.noconv.} =
  ## Catch ctrl+c from user

  runInLoop = false
  kill(nimhaMain)
  echo "Program quitted."
  quit()

setControlCHook(handler)


proc checkCompileOptions(): string =
  ## Checking for known compile options
  ## and returning them as a space separated string.
  ## See README.md for explation of the options.
  
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



proc launcherActivated() =
  ## 1) Executing the main-program in a loop.
  ## 2) Each time a new compiled file is available,
  ##    the program exits the running process and starts a new
  echo $getTime() & ": Nim Website Creator: Launcher initialized"

  nimhaMain = startProcess(getAppDir() & "/nimwcpkg/nimwc_main" & userArgsRun, options = {poParentStreams, poEvalCommand})

  while runInLoop:
    if fileExists(getAppDir() & "/nimwcpkg/nimwc_main_new"):
      kill(nimhaMain)
      moveFile(getAppDir() & "/nimwcpkg/nimwc_main_new", getAppDir() & "/nimwcpkg/nimwc_main")
    
    if not running(nimhaMain):
      echo $getTime() & ": Restarting program in 1 second"

      discard execCmd("pkill nimwc_main")
      sleep(1000)
      
      if userArgsRun != "":
        echo " Using args: " & userArgsRun

      nimhaMain = startProcess(getAppDir() & "/nimwcpkg/nimwc_main" & userArgsRun, options = {poParentStreams, poEvalCommand})
   
    sleep(2000)

  echo $getTime() & ": Nim Website Creator: Quitted"
  quit()


proc startupCheck() =
  ## Checking if the main-program file exists. If not it will
  ## be compiled with args and compiler options (compiler
  ## options should be specified in the *.nim.pkg)
  if not fileExists(getAppDir() & "/nimwcpkg/nimwc_main") or defined(rc):
    echo "Compiling"
    echo " - Using params:" & userArgs
    echo " - Using compile options in *.nim.cfg"
    echo " "
    echo " .. please wait while compiling"
    let output = execCmd("nim c " & compileOptions & " " & getAppDir() & "/nimwcpkg/nimwc_main.nim")
    if output == 1:
      echo "\nAn error occurred\n"
      quit()
    else:
      echo "\n"
      echo """Compiling done. 
      
    - To start Nim Website Creator and access at 127.0.0.1:<port>
      # Manually compiled
      ./nimwc

      # Through nimble
      nimwc
      
    - To add an admin user, append args:
      ./nimwc --newuser -u:name -p:password -e:email
      
    - To insert standard data in the database:
      ./nimwc --insertdata

      """


proc updateNimwc() =
  ## GIT hard update

  if "gitupdate" in commandLineParams() or defined(gitupdate):
    discard existsOrCreateDir("tmp")
    discard execCmd("mv plugins/plugin_import.txt tmp/plugin_import.txt")
    discard execCmd("mv plugins/css/style_custom.css tmp/style_custom.css")
    discard execCmd("mv plugins/js/js_custom.js tmp/js_custom.js")

    discard execCmd("git fetch --all")
    discard execCmd("git reset --hard origin/master")

    discard execCmd("mv tmp/plugin_import.txt plugins/plugin_import.txt")
    discard execCmd("mv tmp/style_custom.css plugins/css/style_custom.css")
    discard execCmd("mv tmp/js_custom.js plugins/js/js_custom.js")

    echo "\n\nNimWC has been updated\n\n"
    quit()


if "help" in args:
  echo doc
  quit(0)

if "version" in args:
  for line in lines("nimwc.nimble"):
    if line.substr(0, 6) == "version":
      echo "nimwc: Nim Website Creator."
      echo line
      quit(0)

updateNimwc()
startupCheck()
launcherActivated()