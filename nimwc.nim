import os, osproc, parsecfg, rdstdin, sequtils, strutils, terminal, times, json, parseopt, contra

import
  nimwcpkg/resources/administration/createdb,
  nimwcpkg/resources/files/files_efs,
  nimwcpkg/resources/administration/create_adminuser

when defined(release): {.passL: "-s".}
when defined(danger):  {.passC: "-flto -ffast-math -march=native".}
when defined(glibc):   {.passC: "-include force_link_glibc_25.h" .}
when defined(hardened):
  when not defined(ssl): {.fatal: "-d:hardened requires -d:ssl".}
  when defined(danger):  {.fatal: "-d:hardened is incompatible with -d:danger".}
  when not defined(contracts): {.fatal: "-d:hardened requires -d:contracts".}
  when not defined(firejail):  {.hint: "-d:hardened recommends -d:firejail".}
  {.hint: "Security Hardened mode is enabled. Running Hardened.".}
  const hardenedFlags = "-fstack-protector-all -Wstack-protector --param ssp-buffer-size=4 -pie -fPIE -Wformat -Wformat-security -D_FORTIFY_SOURCE=2 -Wall -Wextra -Wconversion -Wsign-conversion -mindirect-branch=thunk -mfunction-return=thunk -fstack-clash-protection -Wl,-z,relro,-z,now -Wl,-z,noexecstack -fsanitize=signed-integer-overflow -fsanitize-undefined-trap-on-error -Wl,-z,noexecheap -fno-common"
  {.passC: hardenedFlags, passL: hardenedFlags, assertions: on.}
  # http:wiki.debian.org/Hardening http:wiki.gentoo.org/wiki/Hardened_Gentoo http:security.stackexchange.com/questions/24444/what-is-the-most-hardened-set-of-options-for-gcc-compiling-c-c
when defined(windows): {.fatal: "Cannot run on Windows, but you can try Docker for Windows: http://docs.docker.com/docker-for-windows".}
when not defined(contracts): {.warning: "Design by Contract is Disabled, Running Unassertive.".}
when not defined(ssl):       {.warning: "SSL is Disabled, Running Unsecure.".}
when not defined(firejail):  {.warning: "Firejail is Disabled, Running Unsecure.".}
else: import firejail

const
  compile_start_msg =  """⏰ Compiling, Please wait ⏰
    ☑️ Using compile options from *.nim.cfg
    ☑️ Using params: """  ## Message to show when started Compiling.

  compile_ok_msg =  """ Nim Website Creator Compiled Ok!

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

  compile_fail_msg = """Compile Error
  ⚠️ Compile-time or Configuration or Plugin error occurred.
  ➡️ You can check your source code with: nim check YourFile.nim
  ➡️ Check the Configuration of NimWC and its Plugins.
  ➡️ Remove new Plugins, restore previous Configuration.
  Check that you have the latest Version. Check the Documentation.
  """  ## Message to show when Compiling Failed.

  doc = """ Nim Website Creator - https://NimWC.org
  Self-Firejailing 2-Factor-Auth Hardened Nim Web Framework with Design by Contract.
  Run it, access your web, customize, add plugins, deploy today anywhere.

  Usage:             nimwc <compile options> <options>

  Options:
    -h --help        Show this output.
    --version        Show Version and exit.
    --showConfig     Show configuration and compile options and continue.
    --newuser        Add 1 new Admin user (asks name, mail and password).
    --insertdata     Insert the standard data (override existing data).
        bulma         - standard data based on Bulma (Default)
        bootstrap     - standard data based on Bootstrap
        clean         - standard data without a CSS/JS framework
    --newdb          Generates the database with standard tables
                      (does NOT override or delete tables).
                      newdb will be initialized automatic, if no database exists.
    --gitupdate      Update from Git and force a hard reset.
    --initplugin     Create plugin skeleton inside tmp/
    --putenv:key=val Set an environment variable.
    -f, --forceBuild Force Recompile, rebuild all modules.
    --backupdb       Compressed signed full backup of database and continue.

  Compile options:
    -d:postgres      Enable Postgres database (SQLite is default)
    -d:firejail      Firejail is enabled. Runs secure.
    -d:hardened      Security Hardened mode is enabled. Runs hardened.
    -d:webp          WebP is enabled. Optimize images.
    -d:adminnotify   Send error logs (ERROR) to the specified Admin email.
    -d:dev           Development (ignore reCaptcha, no emails, more Verbose).
    -d:devemailon    Send email when -d:dev is activated.
    -d:demo          Public demo mode. Enable Test user. 2FA ignored.
                      Force database reset every 1 hour. Some options Disabled.
    -d:contracts     Force Design by Contract enabled. Runs assertive.
    -d:glibc         Compatibility with GlibC 2.5, x86_64, year ~2000, for old Linuxes

  Tips:
    Use -d:release for Production. Use -d:contracts for Debug. We recommend Firejail.
    Learn more: http://nim-lang.org/learn.html http://nim-lang.github.io/Nim/lib.html
  """

  skeletonMsg = """NimWC: Creating plugin skeleton.
  New plugin template will be created inside the folder:  tmp/
  (the files will have useful comments with help & links) """

  reqRoutes = """# https://github.com/dom96/jester#routes
  get "/$1/settings":
    resp "<center><h1> $1 Plugin Settings."  ## Code your plugins Settings logic here.
  """

  pluginJson = """
  [
    {
      "name": "$1",
      "foldername": "$2",
      "version": "0.1",
      "requires": "$4",
      "url": "https://github.com/$3/$2",
      "method": "git",
      "description": "$2 plugin for Nim Website Creator.",
      "license": "MIT",
      "web": "",
      "email": "",
      "sustainability": ""
    }
  ]
  """

  compileOptions = ["",
    when defined(adminnotify):     " -d:adminnotify",
    when defined(dev):             " -d:dev",
    when defined(devemailon):      " -d:devemailon",
    when defined(demo):            " -d:demo",
    when defined(postgres):        " -d:postgres",
    when defined(webp):            " -d:webp",
    when defined(firejail):        " -d:firejail",
    when defined(contracts):       " -d:contracts",
    when defined(glibc):           " -d:glibc",

    when defined(ssl):               " -d:ssl",               # SSL
    when defined(release):           " -d:release --listFullPaths:off --excessiveStackTrace:off",  # Build for Production
    when defined(danger):            " -d:danger",            # Build for Production
    when defined(quick):             " -d:quick",             # Tiny file but slow
    when defined(memProfiler):       " -d:memProfiler",       # RAM Profiler debug
    when defined(nimTypeNames):      " -d:nimTypeNames",      # Debug names
    when defined(useRealtimeGC):     " -d:useRealtimeGC",     # Real Time GC
    when defined(tinyc):             " -d:tinyc",             # TinyC compiler
    when defined(useNimRtl):         " -d:useNimRtl",         # NimRTL.dll
    when defined(useFork):           " -d:useFork",           # Fork instead of Spawn
    when defined(useMalloc):         " -d:useMalloc",         # Use Malloc for gc:none
    when defined(uClibc):            " -d:uClibc",            # uClibc instead of glibC
    when defined(checkAbi):          " -d:checkAbi",          # Check C ABI compatibility
    when defined(noSignalHandler):   " -d:noSignalHandler",   # No convert crash to signal
    when defined(useStdoutAsStdmsg): " -d:useStdoutAsStdmsg", # Use Std Out as Std Msg
    when defined(nimOldShiftRight):  " -d:nimOldShiftRight",  # http://forum.nim-lang.org/t/4891#30600
    when defined(nimOldCaseObjects): " -d:nimOldCaseObjects", # old case switch
    when defined(nimBinaryStdFiles): " -d:d:nimBinaryStdFiles", # stdin/stdout old binary open
  ].join  ## Checking for known compile options and returning them as a space separated string at Compile-Time. See README.md for explanation of the options.

  nimwc_version =
    try:
      filterIt("nimwc.nimble".readFile.splitLines, it.substr(0, 6) == "version")[0].split("= ")[1].normalize.replace("\"", "") ## Get NimWC Version at Compile-Time.
    except:
      "5.0.1"  ## Set NimWC Version at Compile-Time, if ready from file failed.


const reqCode = """# Code your plugins Backend logic on this file.
proc $1Start*(db: DbConn): auto =
  ## Code your Plugins start-up Backend logic here, db is the Database, see $1
  discard
""".format(when defined(postgres): "https://nim-lang.org/docs/db_postgres.html"
           else: "https://nim-lang.org/docs/db_sqlite.html")

var
  runInLoop = true
  nimhaMain: Process


## Parse commandline params
let
  args = replace(commandLineParams().join(" "), "-", "")
  userArgs = if args == "": "" else: " " & args
  userArgsRun = if args == "": "" else: " --run " & args
  dict = loadConfig(getAppDir() & "/config/config.cfg")
  appName = dict.getSectionValue("Server", "appname")
  appPath = getAppDir() & "/nimwcpkg/" & appName
assert appName.len > 1, "Config error: appname must not be empty string: " & appName


proc updateNimwc() =
  ## GIT hard update
  preconditions(existsDir"plugins/", existsDir"public/css/", existsDir"public/js/",
    existsFile"plugins/plugin_import.txt", existsFile"public/css/style_custom.css",
    existsFile"public/js/js_custom.js", findExe"git".len > 0)
  # No postconditions because we directly quit anyways.
  const cmd = "git fetch --all ; git reset --hard origin/master"
  let
    pluginImport = readFile"plugins/plugin_import.txt"  # Save Contents
    styleCustom = readFile"public/css/style_custom.css"
    jsCustom = readFile"public/js/js_custom.js"
  echo cmd
  discard execCmd(cmd)
  writeFile("plugins/plugin_import.txt", pluginImport)  # Write Content again
  writeFile("public/css/style_custom.css", styleCustom)
  writeFile("public/js/js_custom.js", jsCustom)
  quit("\n\nNimWC has been updated.\n", 0)


proc pluginSkeleton() =
  ## Creates the skeleton (folders and files) for a plugin
  styledEcho(fgCyan, bgBlack, skeletonMsg)
  let pluginName = normalize(readLineFromStdin("Plugin name: "))
  assert pluginName.len > 1, "Plugin Name must not be empty string: " & pluginName

  # Create dirs
  discard existsOrCreateDir("tmp")
  discard existsOrCreateDir("tmp/" & pluginName)
  discard existsOrCreateDir("tmp/" & pluginName & "/public")

  # Create files
  writeFile("tmp/" & pluginName & "/" & pluginName & ".nim", reqCode.format(pluginName))
  writeFile("tmp/" & pluginName & "/routes.nim", reqRoutes.format(pluginName))
  writeFile("tmp/" & pluginName & "/public/js.js",
    "/* https://github.com/pragmagic/karax OR Vanilla JavaScript */\n")
  writeFile("tmp/" & pluginName & "/public/style.css",
    "/* https://bulma.io/documentation OR https://picturepan2.github.io/spectre OR https://getbootstrap.com */\n")

  if readLineFromStdin("\nInclude optional files (y/N): ").string.strip.toLowerAscii == "y":
    writeFile("tmp/" & pluginName & "/public/js_private.js", "")
    writeFile("tmp/" & pluginName & "/public/style_private.css", "")
    writeFile("tmp/" & pluginName & "/.gitattributes", "*.* linguist-language=Nim\n")
    writeFile("tmp/" & pluginName & "/.gitignore", "*.c\n*.h\n*.o\n")
    writeFile("tmp/" & pluginName & "/html.nimf",
      "<!-- https://nim-lang.org/docs/filters.html -->\n")
    writeFile("tmp/" & pluginName & "/changelog.md",
      "# 0.0.1\n\n- First initial version created at " & $now())
    writeFile("tmp/" & pluginName & "/" & pluginName & ".nim.cfg",
      "# https://nim-lang.org/docs/parsecfg.html\n")

  writeFile("tmp/" & pluginName & "/plugin.json",
    pluginJson.format(capitalizeAscii(pluginName), pluginName,
    getEnv("USER", "YourUser"), nimwc_version.substr(0, 2)))
  quit("\n\nNimWC created a new Plugin skeleton, happy hacking, bye.\n\n", 0)


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

  when not defined(firejail):
    nimwcCommand = appPath & userArgsRun
  else:
    let
      cpuCores = dict.getSectionValue("firejail", "cpuCoresByNumber").parseInt
      corez = if cpuCores != 0: toSeq(0..cpuCores) else: @[]
      hostz = dict.getSectionValue("firejail", "hostsFile").strip
      dnsz = [dict.getSectionValue("firejail", "dns0").strip, dict.getSectionValue("firejail", "dns1").strip,
              dict.getSectionValue("firejail", "dns2").strip, dict.getSectionValue("firejail", "dns3").strip]
    assert countProcessors() > cpuCores, "Dedicated CPU Cores must be less or equal than the actual CPU Cores: " & $cpuCores
    assert hostz.existsFile, "Hosts file not found: " & hostz
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
      command=appPath & userArgsRun,
      name = appName, # whitelist= @[getAppDir(), getCurrentDir()],
      maxSubProcesses = dict.getSectionValue("firejail", "maxSubProcesses").parseInt * 1_000_000,  # 1 is Ok, 0 is Disabled, int.high max.
      maxOpenFiles = dict.getSectionValue("firejail", "maxOpenFiles").parseInt * 1_000,        # Below 1000 NimWC may not start.
      maxFileSize = dict.getSectionValue("firejail", "maxFileSize").parseInt * 1_000_000_000,  # Below 1Mb NimWC may not start.
      maxPendingSignals = dict.getSectionValue("firejail", "maxPendingSignals").parseInt * 10, # 1 is Ok, 0 is Disabled, int.high max.
      timeout = dict.getSectionValue("firejail", "timeout").parseInt,                          # 1 is Ok, 0 is Disabled, 255 max. It will actually Restart instead of Stopping.
      maxRam = dict.getSectionValue("firejail", "maxRam").parseInt * 1_000_000_000,            # Below 1Gb NimWC may fail.
      maxCpu = dict.getSectionValue("firejail", "maxCpu").parseInt,                            # 1 is Ok, 0 is Disabled, 255 max.
      cpuCoresByNumber = corez,                                                                # 0 is Disabled, else toSeq(0..corez)
      hostsFile = hostz,        # Optional Alternative/Fake /etc/hosts
      dnsServers = dnsz,        # Optional Alternative/Fake DNS, 4 Servers must be provided
    )

  const processOpts =
    when defined(release): {poParentStreams, poEvalCommand}
    else:                  {poParentStreams, poEvalCommand, poEchoCmd}
  nimhaMain = startProcess(nimwcCommand, options = processOpts)

  while runInLoop:
    # If nimha_main has been recompile, check for a new version
    if fileExists(appPath & "_new"):
      kill(nimhaMain)
      moveFile(appPath & "_new", appPath)

    # Loop to check if nimwc_main is running
    if not running(nimhaMain):
      # Quit if user has provided arguments
      if args.len != 0:
        styledEcho(fgYellow, bgBlack, $now() & ": User provided arguments: " & args)
        styledEcho(fgYellow, bgBlack, $now() & ": Run again without arguments, exiting.")
        quit()

      styledEcho(fgYellow, bgBlack, $now() & ": Restarting in 1 second.")
      sleep(1000)

      # Start nimha_main as process
      nimhaMain = startProcess(nimwcCommand, options = processOpts)

    sleep(2000)

  styledEcho(fgYellow, bgBlack, $now() & ": Nim Website Creator: Stopping.")
  quit()


proc startupCheck() =
  ## Checking if the main-program file exists. If not it will
  ## be compiled with args and compiler options (compiler
  ## options should be specified in the *.nim.pkg)
  preconditions compileOptions.len > 0, appPath.len > 0, storageEFS.len > 0, existsFile(getAppDir() & "/nimwcpkg/nimwc_main.nim")
  # Storage location. Folders are created in the module files_efs.nim
  when not defined(ignoreefs) and defined(release):
    if not existsDir(storageEFS):  # Check access to EFS file system.
      quit("No access to storage in release mode. Critical.")

  if not fileExists(appPath):
    styledEcho(fgGreen, bgBlack, compile_start_msg & userArgs)
    let (output, exitCode) = execCmdEx("nim c --out:" & appPath & " " & compileOptions & " " & getAppDir() & "/nimwcpkg/nimwc_main.nim")
    if exitCode != 0:
      styledEcho(fgRed, bgBlack, compile_fail_msg & output)
      quit(exitCode)
    else:
      styledEcho(fgGreen, bgBlack, compile_ok_msg)


#
# Argument parsing and function calling.
#


when isMainModule:
  for keysType, keys, values in getopt():
    case keysType
    of cmdShortOption, cmdLongOption:
      case keys
      of "version": quit(nimwc_version, 0)
      of "help":
        styledEcho(fgGreen, bgBlack, doc)
        quit(0)
      of "debugConfig":
        styledEcho(fgMagenta, bgBlack, $compileOptions)
        styledEcho(fgMagenta, bgBlack, $dict)
      of "putenv":
        let envy = values.split"="
        styledEcho(fgBlue, bgBlack, $envy)
        putEnv(envy[0], envy[1])
      of "initplugin": pluginSkeleton() # Interactive (Asks to user).
      of "gitupdate": updateNimwc()
      of "forceBuild", "f": removeFile(appPath)
      of "newdb": generateDB()
      of "newuser": createAdminUser()
      of "backupdb": echo backupDb(dbname = "website")
    of cmdArgument:
      startupCheck()
      launcherActivated()
    of cmdEnd: quit("Wrong Arguments, please see Help with: --help", 1)
