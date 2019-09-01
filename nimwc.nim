import os, osproc, parsecfg, rdstdin, sequtils, strutils, terminal, times, json, parseopt, contra

import
  nimwcpkg/resources/administration/createdb,
  nimwcpkg/resources/administration/create_standarddata,
  nimwcpkg/resources/administration/connectdb,
  nimwcpkg/resources/files/files_efs,
  nimwcpkg/resources/administration/create_adminuser

when defined(postgres): import db_postgres
else:                   import db_sqlite

hardenedBuild()

when defined(windows):        {.fatal: "Cannot run on Windows, but you can try Docker for Windows: http://docs.docker.com/docker-for-windows".}
when not defined(contracts):  {.warning: "Design by Contract is Disabled, Running Unassertive.".}
when not defined(ssl):        {.warning: "SSL is Disabled, Running Unsecure.".}
when not defined(firejail):   {.warning: "Firejail is Disabled, Running Unsecure.".}
else: import firejail

const
  cmdStrip = "strip --strip-all --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag "
  compile_start_msg =  """⏰ Compiling, Please wait ⏰
  ☑️ Using compile options from *.nim.cfg. Using params: """  ## Message to show when started Compiling.

  compile_ok_msg =  """ Nim Website Creator compiling OK!

  ☑️️ Start Nim Website Creator and access it at http://127.0.0.1:<port>
      # Manually compiled
      ./nimwc

      # Through nimble: Run binary or use symlink
      nimwc

  ☑️ To add an admin user, append args:
      ./nimwc --newadmin

  ☑️ To insert standard data in the database, append args:
      ./nimwc --insertdata

  ☑️ Access the Settings page at http://127.0.0.1:<port>/settings
  """  ## Message to show when compiling has finished and was OK.

  compile_fail_msg = """Compile Error
  ⚠️ Compile-time or Configuration or Plugin error occurred.
  ➡️ Check the configuration file of NimWC and enabled plugins. Recompile with -d:contracts.
  ➡️ Remove new plugins, restore previous configuration.
  ➡️ ️️Check that you have the latest NimWC version and check the documentation.
  ➡️ Check your source code: nim check YourFile.nim; nimpretty YourFile.nim
  """  ## Message to show when an error occurred during compiling.

  skeletonMsg = """NimWC: Creating plugin skeleton.
  New plugin template will be created inside the folder:  tmp/
  (The files will have useful comments with help & links). """

  reqRoutes = """# https://github.com/dom96/jester#routes
  get "/$1/settings":
    resp "<center><h1> $1 Plugin Settings."  ## Code your plugins settings logic here.
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
    when defined(recaptcha):       " -d:recaptcha",

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
      "5.5.1"  ## Set NimWC Version at Compile-Time, if reading from file fails.

const reqCode = """# Code your plugins backend logic in this file.
proc $1Start*(db: DbConn): auto =
  ## Code your plugins start-up backend logic here, db is the database, see $1
  discard
""".format(when defined(postgres): "https://nim-lang.org/docs/db_postgres.html"
           else: "https://nim-lang.org/docs/db_sqlite.html")

const doc = """Nim Website Creator - https://NimWC.org
Nim open-source website framework that is simple to use.
Run it, access your web, customize, add plugins, deploy today anywhere.

Usage:            nimwc <compile options> <options>

Options:
 -h --help        Show this help.
 --version        Show Version and exit.
 -f, --forcebuild Force Recompile.
 --showconfig     Show parsed INI configuration and compile options and continue
 --newadmin       Add 1 new Admin or Moderator user (asks name, mail & password)
 --gitupdate      Update from Git origin master then force a hard reset and exit
 --initplugin     Create 1 new empty plugin skeleton inside the folder ./tmp/
 --vacuumdb       Vacuum database and continue (database maintenance).
 --backupdb       Compressed signed full backup of database and continue.
 --newdb          Generates a database with standard tables (Wont override data)
                  If no database exists, new db will be initialized automatically
 --insertdata:bulma     Insert Bulma standard data into the database (default, overrides data)
 --insertdata:bootstrap Insert Bootstrap standard data into the database (overrides data)
 --insertdata:clean     Insert clean (no framework) standard data into the database (overrides data)

Compile options (features when compiling source code):
 -d:postgres      Postgres database is enabled (SQLite is default)
 -d:firejail      Firejail is enabled. Runs secure.
 -d:hardened      Security Hardened mode is enabled. Runs Hardened. Performance cost at ~20%.
 -d:webp          WebP is enabled. Optimize images and photos.
 -d:recaptcha     Recaptcha AntiSpamm is enabled (Google API,wont work over Tor)
 -d:adminnotify   Send error logs (ERROR) to the specified Admin email.
 -d:dev           Development (ignore reCaptcha, no emails, more Verbose).
 -d:devemailon    Send error logs email when -d:dev is activated.
 -d:demo          Public demo mode. Enable Test user. 2FA ignored. Pages Reset.
                  Force database reset every 1 hour. Some options Disabled.
 -d:contracts     Force Design by Contract enabled. Runs assertive.

Compile options quick tip (release builds are automatically stripped/optimized):
 Fastest       -d:release -d:danger
 Balanced      -d:release -d:firejail --styleCheck:hint
 Safest        -d:release -d:contracts -d:hardened -d:firejail --styleCheck:hint

Learn more http://nim-lang.org/learn.html http://nim-lang.org/documentation.html
http://nim-lang.github.io/Nim/lib.html http://nim-lang.org/docs/theindex.html"""

var
  runInLoop = true
  nimwcMain: Process


proc updateNimwc() =
  ## GIT hard update
  preconditions(existsDir"plugins/", existsDir"public/css/", existsDir"public/js/",
    existsFile"plugins/plugin_import.txt", existsFile"public/css/style_custom.css",
    existsFile"public/js/js_custom.js", findExe"git".len > 0)
  # No postconditions because we directly quit anyways.
  const cmd = "git fetch --all ; git reset --hard origin/master"
  let
    pluginImport = readFile"plugins/plugin_import.txt"  # Save contents
    styleCustom = readFile"public/css/style_custom.css"
    jsCustom = readFile"public/js/js_custom.js"
  when not defined(release): echo cmd
  discard execCmd(cmd)
  writeFile("plugins/plugin_import.txt", pluginImport)  # Write contents back
  writeFile("public/css/style_custom.css", styleCustom)
  writeFile("public/js/js_custom.js", jsCustom)
  echo "\n\n\nTo finish the update:\n - Compile NimWC\n - Run with the arg `--newdb`\n"
  quit("Git fetch done\n", 0)


proc pluginSkeleton() =
  ## Creates the skeleton (folders and files) for a plugin
  styledEcho(fgCyan, bgBlack, skeletonMsg)
  let pluginName = normalize(readLineFromStdin("Plugin name: "))
  assert pluginName.len > 1, "Plugin name must not be empty string: " & pluginName

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
    "/* https://bulma.io/documentation OR https://getbootstrap.com OR clean CSS */\n")

  if readLineFromStdin("\nInclude optional files (y/N): ").string.strip.toLowerAscii == "y":
    writeFile("tmp/" & pluginName & "/public/js_private.js", "")
    writeFile("tmp/" & pluginName & "/public/style_private.css", "")
    writeFile("tmp/" & pluginName & "/.gitattributes", "*.* linguist-language=Nim\n")
    writeFile("tmp/" & pluginName & "/.gitignore", "*.c\n*.h\n*.o\n*.sql\n*.sha512\n*.asc")
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
  kill(nimwcMain)
  styledEcho(fgYellow, bgBlack, "CTRL+C Pressed, NimWC is shutting down, bye.")
  quit()

setControlCHook(handler)


proc launcherActivated(cfg: Config) =
  ## 1) Executing the main-program in a loop.
  ## 2) Each time a new compiled file is available,
  ##    the program exits the running process and starts a new
  styledEcho(fgGreen, bgBlack, $now() & ": Nim Website Creator: Launcher starting.")
  var nimwcCommand: string
  let
    args = replace(commandLineParams().join(" "), "-", "")
    userArgsRun = if args == "": "" else: " --run " & args
    appPath = getAppDir() / "nimwcpkg" / cfg.getSectionValue("Server", "appname")
  when not defined(firejail):
    nimwcCommand = appPath & userArgsRun
  else:
    let
      cpuCores = cfg.getSectionValue("firejail", "cpuCoresByNumber").parseInt
      corez = if cpuCores != 0: toSeq(0..cpuCores) else: @[]
      hostz = cfg.getSectionValue("firejail", "hostsFile").strip
      dnsz = [cfg.getSectionValue("firejail", "dns0").strip, cfg.getSectionValue("firejail", "dns1").strip,
              cfg.getSectionValue("firejail", "dns2").strip, cfg.getSectionValue("firejail", "dns3").strip]
    assert countProcessors() > cpuCores, "Dedicated CPU Cores must be less or equal to the actual CPU Cores: " & $cpuCores
    assert hostz.existsFile, "Hosts file not found: " & hostz
    let myjail = Firejail(
      noDvd:         cfg.getSectionValue("firejail", "noDvd").parseBool,
      noSound:       cfg.getSectionValue("firejail", "noSound").parseBool,
      noAutoPulse:   cfg.getSectionValue("firejail", "noAutoPulse").parseBool,
      no3d:          cfg.getSectionValue("firejail", "no3d").parseBool,
      noX:           cfg.getSectionValue("firejail", "noX").parseBool,
      noVideo:       cfg.getSectionValue("firejail", "noVideo").parseBool,
      noDbus:        cfg.getSectionValue("firejail", "noDbus").parseBool,
      noShell:       cfg.getSectionValue("firejail", "noShell").parseBool,
      noDebuggers:   cfg.getSectionValue("firejail", "noDebuggers").parseBool,
      noMachineId:   cfg.getSectionValue("firejail", "noMachineId").parseBool,
      noRoot:        cfg.getSectionValue("firejail", "noRoot").parseBool,
      noAllusers:    cfg.getSectionValue("firejail", "noAllusers").parseBool,
      noU2f:         cfg.getSectionValue("firejail", "noU2f").parseBool,
      privateTmp:    cfg.getSectionValue("firejail", "privateTmp").parseBool,
      privateCache:  cfg.getSectionValue("firejail", "privateCache").parseBool,
      privateDev:    cfg.getSectionValue("firejail", "privateDev").parseBool,
      forceEnUsUtf8: cfg.getSectionValue("firejail", "forceEnUsUtf8").parseBool,
      caps:          cfg.getSectionValue("firejail", "caps").parseBool,
      seccomp:       cfg.getSectionValue("firejail", "seccomp").parseBool,
      noTv:          cfg.getSectionValue("firejail", "noTv").parseBool,
      writables:     cfg.getSectionValue("firejail", "writables").parseBool,
      noMnt:         cfg.getSectionValue("firejail", "noMnt").parseBool,
    )
    nimwcCommand = myjail.makeCommand(
      command=appPath & userArgsRun,
      name = cfg.getSectionValue("Server", "appname"), # whitelist= @[getAppDir(), getCurrentDir()],
      maxSubProcesses = cfg.getSectionValue("firejail", "maxSubProcesses").parseInt * 1_000_000,  # 1 is Ok, 0 is Disabled, int.high max.
      maxOpenFiles = cfg.getSectionValue("firejail", "maxOpenFiles").parseInt * 1_000,        # Below 1000 NimWC may not start.
      maxFileSize = cfg.getSectionValue("firejail", "maxFileSize").parseInt * 1_000_000_000,  # Below 1Mb NimWC may not start.
      maxPendingSignals = cfg.getSectionValue("firejail", "maxPendingSignals").parseInt * 10, # 1 is Ok, 0 is Disabled, int.high max.
      timeout = cfg.getSectionValue("firejail", "timeout").parseInt,                          # 1 is Ok, 0 is Disabled, 255 max. It will actually Restart instead of Stopping.
      maxRam = cfg.getSectionValue("firejail", "maxRam").parseInt * 1_000_000_000,            # Below 1Gb NimWC may fail.
      maxCpu = cfg.getSectionValue("firejail", "maxCpu").parseInt,                            # 1 is Ok, 0 is Disabled, 255 max.
      cpuCoresByNumber = corez,                                                                # 0 is Disabled, else toSeq(0..corez)
      hostsFile = hostz,        # Optional Alternative/Fake /etc/hosts
      dnsServers = dnsz,        # Optional Alternative/Fake DNS, 4 Servers must be provided
    )

  const processOpts =
    when defined(release): {poParentStreams, poEvalCommand}
    else:                  {poParentStreams, poEvalCommand, poEchoCmd}
  nimwcMain = startProcess(nimwcCommand, options = processOpts)

  while runInLoop:
    # If nimha_main has been recompile, check for a new version
    if fileExists(appPath & "_new"):
      kill(nimwcMain)
      moveFile(appPath & "_new", appPath)

    # Loop to check if nimwc_main is running
    if not running(nimwcMain):
      # Quit if user has provided arguments
      if args.len != 0:
        styledEcho(fgYellow, bgBlack, $now() & ": User provided arguments: " & args)
        styledEcho(fgYellow, bgBlack, $now() & ": Run again without arguments, exiting.")
        quit()

      styledEcho(fgYellow, bgBlack, $now() & ": Restarting in 1 second.")
      sleep(1000)

      # Start nimha_main as process
      nimwcMain = startProcess(nimwcCommand, options = processOpts)

    sleep(2000)

  styledEcho(fgYellow, bgBlack, $now() & ": Nim Website Creator: Stopping.")
  quit()


proc startupCheck(cfg: Config) =
  ## Checking if the main-program file exists. If not it will
  ## be compiled with args and compiler options (compiler
  ## options should be specified in the *.nim.pkg)
  preconditions compileOptions.len > 0, storageEFS.len > 0, existsFile(getAppDir() & "/nimwcpkg/nimwc_main.nim")
  # Storage location. Folders are created in the module files_efs.nim
  let
    args = replace(commandLineParams().join(" "), "-", "")
    userArgs = if args == "": "" else: " " & args
    appPath = getAppDir() / "nimwcpkg" / cfg.getSectionValue("Server", "appname")
  when not defined(ignoreefs):
    if not existsDir(storageEFS):  # Check access to EFS file system.
      quit("No access to storage in release mode. Critical.")

  # Ensure that the tables are present in the DB
  connectDb()
  generateDB(db)

  if not fileExists(appPath):
    # Ensure that the DB tables are created
    styledEcho(fgGreen, bgBlack, compile_start_msg & userArgs)
    let (output, exitCode) = execCmdEx("nim c --out:" & appPath & " " & compileOptions & " " & getAppDir() & "/nimwcpkg/nimwc_main.nim")
    if exitCode != 0:
      styledEcho(fgRed, bgBlack, compile_fail_msg & output)
      quit(exitCode)
    else:
      styledEcho(fgGreen, bgBlack, compile_ok_msg)
      when defined(release):
        if findExe"strip".len > 0: discard execCmd(cmdStrip & appPath)


#
# Argument parsing and main function calling.
#


when isMainModule:
  let cfg = loadConfig(getAppDir() / "config/config.cfg") # cfg is Config.
  connectDb() # Read config, connect database, inject it as "db" variable.
  for keysType, keys, values in getopt():
    case keysType
    of cmdShortOption, cmdLongOption:
      case keys
      of "version": quit(nimwc_version, 0)
      of "help": styledEcho(fgGreen, bgBlack, doc)
      of "showconfig":
        styledEcho(fgMagenta, bgBlack, $compileOptions)
        styledEcho(fgMagenta, bgBlack, $cfg)
      of "initplugin": pluginSkeleton() # Interactive (Asks to user).
      of "gitupdate": updateNimwc()
      of "forcebuild", "f": removeFile(getAppDir() / "nimwcpkg" / cfg.getSectionValue("Server", "appname"))
      of "newdb": generateDB(db)
      of "newadmin": createAdminUser(db)
      of "insertdata":
        const styles = @["bulma", "bootstrap", "clean"]
        var styleExist = false
        for data in commandLineParams():
          if $data in styles:
            createStandardData(db, $data, confirm=true)
            styleExist = true
        if not styleExist:
          echo("\nStandard data: Please specify data style:\n  1) bulma\n  2) bootstrap\n  3) clean\n!! Data not inserted !!")
      of "vacuumdb": echo vacuumDb(db)
      of "backupdb": echo backupDb(cfg.getSectionValue("Database", when defined(postgres): "name" else: "host"))
    of cmdArgument:
      discard
    of cmdEnd: quit("Wrong Arguments, please see Help with: --help", 1)

    if keys.len() != 0:
      quit(0)

  startupCheck(cfg)
  launcherActivated(cfg)
