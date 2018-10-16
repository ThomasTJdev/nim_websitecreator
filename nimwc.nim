import json, os, osproc, rdstdin, sequtils, strutils, times, terminal

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

  - To insert standard data in the database:
    ./nimwc --insertdata

  - Access Settings page at http://127.0.0.1:<port>/settings
  """  ## Message to show when finished Compiling OK.

  compile_fail_msg = """Compiling Failed.

  - A Compile-time or Configuration error occurred.
    You can check your source code with: nim check
    Check the Configuration of NimWC and its Plugins.
  """  ## Message to show when Compiling Failed.

  doc = """
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
    --initplugin          Create plugin skeleton inside tmp/

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

  nimwc_version = filter_it(readFile("nimwc.nimble").splitLines, it.substr(0, 6) == "version")[0]  ## Get NimWC Version at Compile-Time.


var
  runInLoop = true
  nimhaMain: Process


## Parse commandline params
let
  args = replace(commandLineParams().join(" "), "-", "")
  userArgs = if args == "": "" else: " " & args
  userArgsRun = if args == "": "" else: " --run " & args


proc handler() {.noconv.} =
  ## Catch ctrl+c from user

  runInLoop = false
  kill(nimhaMain)
  styledEcho(fgYellow, bgBlack, "CTRL+C Pressed, NimWC is shutting down.")
  quit()

setControlCHook(handler)


func checkCompileOptions(): string =
  ## Checking for known compile options
  ## and returning them as a space separated string.
  ## See README.md for explanation of the options.
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

let compileOptions = checkCompileOptions()


proc launcherActivated() =
  ## 1) Executing the main-program in a loop.
  ## 2) Each time a new compiled file is available,
  ##    the program exits the running process and starts a new
  styledEcho(fgGreen, bgBlack, $now() & ": Nim Website Creator: Launcher initialized")

  nimhaMain = startProcess(getAppDir() & "/nimwcpkg/nimwc_main" & userArgsRun, options = {poParentStreams, poEvalCommand})

  while runInLoop:
    if fileExists(getAppDir() & "/nimwcpkg/nimwc_main_new"):
      kill(nimhaMain)
      moveFile(getAppDir() & "/nimwcpkg/nimwc_main_new", getAppDir() & "/nimwcpkg/nimwc_main")

    if not running(nimhaMain):
      styledEcho(fgYellow, bgBlack, $now() & ": Restarting program in 1 second")

      discard execCmd("pkill nimwc_main")
      sleep(1000)

      if userArgsRun != "":
        styledEcho(fgGreen, bgBlack, " Using args: " & userArgsRun)

      nimhaMain = startProcess(getAppDir() & "/nimwcpkg/nimwc_main" & userArgsRun, options = {poParentStreams, poEvalCommand})

    sleep(2000)

  styledEcho(fgYellow, bgBlack, $now() & ": Nim Website Creator: Quitted")
  quit()


proc startupCheck() =
  ## Checking if the main-program file exists. If not it will
  ## be compiled with args and compiler options (compiler
  ## options should be specified in the *.nim.pkg)
  if not fileExists(getAppDir() & "/nimwcpkg/nimwc_main") or defined(rc):
    styledEcho(fgGreen, bgBlack, compile_start_msg & userArgs)
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


proc pluginSkeleton() =
  ## Creates the skeleton (folders and files) for a plugin

  styledEcho(fgCyan, bgBlack,
    "NimWC: Creating plugin skeleton\nThe plugin will be created inside tmp/")
  let pluginName = normalize(readLineFromStdin("Plugin name: "))
  echo ""

  # Create dirs
  discard existsOrCreateDir("tmp")
  discard existsOrCreateDir("tmp/" & pluginName)
  discard existsOrCreateDir("tmp/" & pluginName & "/public")

  # Create files
  writeFile("tmp/" & pluginName & "/" & pluginName & ".nim", "")
  writeFile("tmp/" & pluginName & "/routes.nim", "")
  writeFile("tmp/" & pluginName & "/public/js.js", "")
  writeFile("tmp/" & pluginName & "/public/style.css", "")

  if readLineFromStdin("Include optional files (y/N): ").string.strip.toLowerAscii == "y":
    writeFile("tmp/" & pluginName & "/html.tmpl", "")
    writeFile("tmp/" & pluginName & "/public/js_private.js", "")
    writeFile("tmp/" & pluginName & "/public/style_private.css", "")

  let pluginJson = """
  [
    {
      "name": "$1",
      "foldername": "$2",
      "version": "0.0.1",
      "url": "",
      "method": "git",
      "description": "",
      "license": "MIT",
      "web": ""
    }
  ]
  """.format(capitalizeAscii(pluginName), pluginName)

  writeFile("tmp/" & pluginName & "/plugin.json", pluginJson)
  styledEcho(fgGreen, bgBlack, "NimWC: Created plugin skeleton.")

if "help" in args:
  styledEcho(fgGreen, bgBlack, doc)
  quit(0)

if "version" in args:
  styledEcho(fgCyan, bgBlack, nimwc_version)
  quit(0)

if "initplugin" in args:
  pluginSkeleton()
  quit(0)

updateNimwc()
startupCheck()
launcherActivated()
