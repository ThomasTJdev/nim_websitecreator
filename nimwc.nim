import os, osproc, rdstdin, sequtils, strutils, terminal, times, json

when defined(noFirejail): {.warning: "Firejail is Disabled, Running Unsecure.".}
else:                     import firejail, parsecfg

when defined(windows):
  {.fatal: "Cannot run on Windows, but you can try Docker for Windows: http://docs.docker.com/docker-for-windows".}
when defined(release): {.passL: "-s".}  # Force strip all on the resulting Binary.

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

  compile_start_msg =  """⏰ Compiling, Please wait ⏰
    ☑️ Using compile options from *.nim.cfg
    ☑️ Using params: """  ## Message to show when started Compiling.

  compile_ok_msg =  """👑 Nim Website Creator Compiled Ok! 👑

  ☑️️ To start Nim Website Creator and access at http://127.0.0.1:<port>
      # Manually compiled
      ./nimwc

      # Through nimble, then just run with symlink
      nimwc

  ☑️ To add an admin user, append args:
      ./nimwc newuser -u:name -p:password -e:email

  ☑️ To insert standard data in the database, append args:
      ./nimwc insertdata

  ☑️ To insert standard data in the database:
      ./nimwc --insertdata

  ☑️ Access Settings page at http://127.0.0.1:<port>/settings
  """  ## Message to show when finished Compiling OK.

  compile_fail_msg = """🐛 Compile Error 🐛

  ⚠️ Compile-time or Configuration or Plugin error occurred.
  ➡️ You can check your source code with: nim check YourFile.nim
  ➡️ Check the Configuration of NimWC and its Plugins.
  ➡️ Remove new Plugins, restore previous Configuration.
  💡 Check that you have the latest Version. Check the Documentation.
  """  ## Message to show when Compiling Failed.

  doc = """👑 Nim Website Creator 👑 https://NimWC.org
  Self-Firejailing 2-Factor-Auth Nim Web Framework thats simple to use.
  Run it, access your web, customize, add plugins, deploy today anywhere.

  Usage:
    nimwc <optional params>

  Options:
    -h --help             Show this output.
    --newuser             Add an admin user. Combine with -u, -p and -e.
      -u:<admin username>
      -p:<admin password>
      -e:<admin email>`
    --insertdata          Insert standard data (override existing data).
        bulma               - standard data based on Bulma
        bootstrap           - standard data based on Bootstrap
        clean               - standard data without a CSS/JS framework
    --newdb               Generates the database with standard tables
                          (does NOT override or delete tables).
                          newdb will be initialized automatic, if no database exists.
    --gitupdate           Updates and force a hard reset.
    --initplugin          Create plugin skeleton inside tmp/

  Compile options:
    -d:sqlite             SQLite Dabatase is Enabled. Postgres Dabatase is Disabled.
    -d:noFirejail         Firejail is Disabled. Runs unsecure. Not recommended.
    -d:noWebp             WebP is Disabled, no image optimizations. Not recommended.
    -d:noUnsplash         Unsplash is Disabled, No background images on pages.
    -d:rc                 Force Recompile (good for Troubleshooting).
    -d:adminnotify        Send error logs (ERROR) to the specified Admin email.
    -d:dev                Development (ignore reCaptcha, no emails, more Verbose).
    -d:devemailon         Send email when -d:dev is activated.
    -d:demo               Public Demo mode. Enable Test user. 2FA ignored.
                          Force database reset every 1 hour. Some options Disabled.
    -d:gitupdate          Force Update from Git and force a hard reset.

  Tips:
    Always Compile with -d:release for Production. We recommend Firejail too.
    Learn more at http://nim-lang.org/learn.html http://nim-lang.github.io/Nim/lib.html
  """

  compileOptions = ["",
    when defined(adminnotify): " -d:adminnotify",
    when defined(dev):         " -d:dev",
    when defined(devemailon):  " -d:devemailon",
    when defined(demo):        " -d:demo",
    when defined(ssl):         " -d:ssl",
    when defined(sqlite):      " -d:sqlite",
    when defined(noFields):    " -d:noFields",
    when defined(noWebp):      " -d:noWebp",
    when defined(noFirejail):  " -d:noFirejail",
    when defined(noUnsplash):  " -d:noUnsplash",
  ].join  ## Checking for known compile options and returning them as a space separated string at Compile-Time. See README.md for explanation of the options.

  nimwc_version =
    try:
      filter_it("nimwc.nimble".readFile.splitLines, it.substr(0, 6) == "version")[0].split("=")[1].normalize ## Get NimWC Version at Compile-Time.
    except:
      "4.5.0"  ## Set NimWC Version at Compile-Time, if ready from file failed.


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
  styledEcho(fgYellow, bgBlack, "CTRL+C Pressed, NimWC is shutting down, Bye.")
  quit()

setControlCHook(handler)


proc launcherActivated() =
  ## 1) Executing the main-program in a loop.
  ## 2) Each time a new compiled file is available,
  ##    the program exits the running process and starts a new
  styledEcho(fgGreen, bgBlack, $now() & ": Nim Website Creator: Launcher starting.")
  var nimwcCommand: string

  when defined(noFirejail):
    nimwcCommand = getAppDir() & "/nimwcpkg/nimwc_main" & userArgsRun
  else:
    let dict = loadConfig(getAppDir() & "/config/config.cfg")
    let myjail = Firejail(
      noDvd:         dict.getSectionValue("firejail", "noDvd").parseBool,
      noSound:       dict.getSectionValue("firejail", "noSound").parseBool,
      noAutoPulse:   dict.getSectionValue("firejail", "noAutoPulse").parseBool,
      no3d:          dict.getSectionValue("firejail", "no3d").parseBool,
      noX:           dict.getSectionValue("firejail", "noX").parseBool,
      noVideo:       dict.getSectionValue("firejail", "noVideo").parseBool,
      noDbus:        dict.getSectionValue("firejail", "noDbus").parseBool,
      noShell:       dict.getSectionValue("firejail", "noShell").parseBool,
      noDebuggers:   dict.getSectionValue("firejail", "noDebuggers").parseBool,
      noMachineId:   dict.getSectionValue("firejail", "noMachineId").parseBool,
      noRoot:        dict.getSectionValue("firejail", "noRoot").parseBool,
      noAllusers:    dict.getSectionValue("firejail", "noAllusers").parseBool,
      noU2f:         dict.getSectionValue("firejail", "noU2f").parseBool,
      privateTmp:    dict.getSectionValue("firejail", "privateTmp").parseBool,
      privateCache:  dict.getSectionValue("firejail", "privateCache").parseBool,
      privateDev:    dict.getSectionValue("firejail", "privateDev").parseBool,
      forceEnUsUtf8: dict.getSectionValue("firejail", "forceEnUsUtf8").parseBool,
      caps:          dict.getSectionValue("firejail", "caps").parseBool,
      seccomp:       dict.getSectionValue("firejail", "seccomp").parseBool,
      noTv:          dict.getSectionValue("firejail", "noTv").parseBool,
      writables:     dict.getSectionValue("firejail", "writables").parseBool,
      noMnt:         dict.getSectionValue("firejail", "noMnt").parseBool,
    )
    nimwcCommand = myjail.makeCommand(
      command=getAppDir() & "/nimwcpkg/nimwc_main" & userArgsRun,
      name="nimwc_main", hostsFile="/etc/hosts", # whitelist= @[getAppDir(), getCurrentDir()],
    ) #TODO: Add more support for more features.

  const processOpts =
    when defined(release): {poParentStreams, poEvalCommand}
    else:                  {poParentStreams, poEvalCommand, poEchoCmd}
  nimhaMain = startProcess(nimwcCommand, options = processOpts)

  while runInLoop:
    if fileExists(getAppDir() & "/nimwcpkg/nimwc_main_new"):
      kill(nimhaMain)
      moveFile(getAppDir() & "/nimwcpkg/nimwc_main_new", getAppDir() & "/nimwcpkg/nimwc_main")

    if not running(nimhaMain):
      styledEcho(fgYellow, bgBlack, $now() & ": Restarting in 1 second.")

      discard execCmd("pkill nimwc_main")
      sleep(1000)

      if userArgsRun != "":
        styledEcho(fgGreen, bgBlack, " Using args: " & userArgsRun)

      nimhaMain = startProcess(nimwcCommand, options = processOpts)

    sleep(2000)

  styledEcho(fgYellow, bgBlack, $now() & ": Nim Website Creator: Stopping.")
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
    quit()

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
      "description": "$3 plugin for Nim Website Creator.",
      "license": "MIT",
      "web": ""
    }
  ]
  """.format(capitalizeAscii(pluginName), pluginName, pluginName)

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
