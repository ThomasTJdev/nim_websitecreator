## Static string constants, do NOT put any run-time logic here, only consts.
## Ignore line lenght on this file.
## Do NOT import this file directly, instead import ``constants.nim``


const
  NimblePkgVersion* {.strdefine.} = "6.0.3"  ## NimWC Version (SemVer)

  commitHash* = staticExec"git rev-parse --short HEAD" & "" ## NimWC Version (Git Hash)

  termsOfServices* = staticRead"../nimfs/tos.html"

  compileOptions* = (
    (when defined(adminnotify):       " -d:adminnotify"       else: "") &
    (when defined(dev):               " -d:dev"               else: "") &
    (when defined(devemailon):        " -d:devemailon"        else: "") &
    (when defined(demo):              " -d:demo"              else: "") &
    (when defined(postgres):          " -d:postgres"          else: "") &
    (when defined(webp):              " -d:webp"              else: "") &
    (when defined(firejail):          " -d:firejail"          else: "") &
    (when defined(recaptcha):         " -d:recaptcha"         else: "") &
    (when defined(packedjson):        " -d:packedjson"        else: "") &

    (when defined(ssl):               " -d:ssl"               else: "") &  # SSL
    (when defined(release):           " -d:release --listFullPaths:off" else: "") &  # Build for Production
    (when defined(danger):            " -d:danger"            else: "") &  # Build for Production
    (when defined(quick):             " -d:quick"             else: "") &  # Tiny file but slow
    (when defined(memProfiler):       " -d:memProfiler"       else: "") &  # RAM Profiler debug
    (when defined(nimTypeNames):      " -d:nimTypeNames"      else: "") &  # Debug names
    (when defined(useRealtimeGC):     " -d:useRealtimeGC"     else: "") &  # Real Time GC
    (when defined(tinyc):             " -d:tinyc"             else: "") &  # TinyC compiler
    (when defined(useNimRtl):         " -d:useNimRtl"         else: "") &  # NimRTL.dll
    (when defined(useFork):           " -d:useFork"           else: "") &  # Fork instead of Spawn
    (when defined(useMalloc):         " -d:useMalloc"         else: "") &  # Use Malloc for gc:none
    (when defined(uClibc):            " -d:uClibc"            else: "") &  # uClibc instead of glibC
    (when defined(checkAbi):          " -d:checkAbi"          else: "") &  # Check C ABI compatibility
    (when defined(noSignalHandler):   " -d:noSignalHandler"   else: "") &  # No convert crash to signal
    (when defined(useStdoutAsStdmsg): " -d:useStdoutAsStdmsg" else: "") &  # Use Std Out as Std Msg
    (when defined(nimOldShiftRight):  " -d:nimOldShiftRight"  else: "") &  # http://forum.nim-lang.org/t/4891#30600
    (when defined(nimOldCaseObjects): " -d:nimOldCaseObjects" else: "")    # old case switch
  )  ## Checking for known compile options and returning them as a space separated string at Compile-Time. See README.md for explanation of the options.

  fileBackup* =
    when defined(db_postgres): "nimwc_postgres_"
    else: "nimwc_sqlite_"

  title* = "Nim Website Creator"

  compile_start_msg* = """

  ⏰ Compiling, Please wait ⏰
  ☑️ Using compile options from *.nim.cfg.
  ☑️ Using params:
  """

  compile_ok_msg* = """

  Nim Website Creator compiling OK!

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

  """

  compile_fail_msg* = """

  Compile Error
  ⚠️ Compile-time or Configuration or Plugin error occurred.
  ➡️ Check the configuration file of NimWC and enabled plugins.
  ➡️ Remove new plugins, restore previous configuration.
  ➡️ ️️Check that you have the latest NimWC version and check the documentation.
  ➡️ Check your source code: nim check YourFile.nim; nimpretty YourFile.nim

  """

  config_not_found_msg* = """

  🐛 WARNING: Config file (config.cfg) could not be found. 🐛
  A template (config_default.cfg) is copied to "config/config.cfg".
  Please configure it and restart Nim Website Creator.

  """

  skeletonMsg* = """

  NimWC: Creating plugin skeleton.
  New plugin template will be created inside the folder:  plugins/
  (The files will have useful comments with help & links).

  """

  reqRoutes* = """

  # https://github.com/dom96/jester#routes
  get "/$1/settings":  # This is your Plugins URL route, can be Regex/string, can be GET/POST.
    resp "<center><h1> $1 Plugin Settings. </h1></center>"  # Code your plugins settings logic here.

  """

  pluginJson* = """
  [
    {
      "name": "$1",
      "foldername": "$2",
      "version": "0.1",
      "requires": "$6",
      "url": "https://github.com/$3/$2",
      "method": "git",
      "description": "$2 plugin for Nim Website Creator.",
      "license": "MIT",
      "web": "$5",
      "email": "$4",
      "sustainability": ""
    }
  ]
  """

  startup_msg* = """

  Package:     Nim Website Creator https://NimWC.org
  Description: Nim open-source website framework that is simple to use.
  Author name: Thomas Toftgaard Jarløv (https://ttj.dk) & Juan Carlos (http://github.com/juancarlospaco)

  """

  createAdminUserMsg* = """

  Checking if any Admin exists in the database...
  $1 Admins already exists. Adding 1 new Admin.
  Requirements:
    - Username > 3 characters long.
    - Email    > 5 characters long.
    - Password > 9 characters long.

  """

  createTestUserMsg* = """

  Checking if any test@test.com exists in the database...
  $1 Test user already exists.

  """

  pluginRepo* = "https://github.com/ThomasTJdev/nimwc_plugins.git"

  pluginRepoName* = "nimwc_plugins"


const reqCode* = """
when defined(postgres): import db_postgres
else: import db_sqlite
include "html.nimf"


# Code your plugins backend logic in this file.
proc $1Start*(db: DbConn): auto =
  ## Code your plugins start-up backend logic here, db is the database.
  ## - Postgres Documentation: https://nim-lang.org/docs/db_postgres.html
  ## - SQLite 3 Documentation: https://nim-lang.org/docs/db_sqlite.html
  ## - proc names must have public export star "*" to be seen from outside this file.
  discard  # Your code here...

"""


const doc* = """Nim Website Creator 👑 https://NimWC.org 👑 Nim open-source web framework that is simple to use.
Usage:            nimwc <compile options> <options>

Options:
  -h --help      Show this help and exit.
  --version      Show Version (SemVer).
  --version-hash Show Version (Git Short Hash).
  --forcebuild   Force Recompile.
  --newadmin     Add 1 new Admin or Moderator user (asks name, mail & password).
  --gitupdate    Update from Git origin master then force a hard reset and exit.
  --initplugin   Create 1 new empty plugin skeleton inside the folder ./plugins/
  --vacuumdb     Vacuum database and continue (automatic database maintenance).
  --backupdb     Full backup of database (Raw SQL plain text file).
  --backupdb-gpg Compressed signed full backup of database (GPG+SHA512+TarGz).
  --backuplogs   Compressed full backup of all old unused rotated Logs (TarGz).
  --insertdata bulma     Insert https://bulma.io data to database (No JS, Default, overrides data)
  --insertdata bootstrap Insert https://getbootstrap.com data to database (jQuery, overrides data)
  --insertdata water     Insert Water CSS data to database (No JS, HTML Classless, overrides data)
  --insertdata official  Insert official nimwc.org data to database (overrides data, CSS, JS)
  --newdb        Generates a database with standard tables (Wont override data).
                  If no database exists, new db will be initialized automatically.

Compile options (features when compiling source code):
  -d:postgres    Postgres replaces SQLite (SQLite is default) https://u.nu/b1c8
  -d:firejail    Firejail is enabled. Runs secure and isolated. https://u.nu/teb6
  -d:webp        WebP is enabled. Optimize images and photos. https://u.nu/0o5t
  -d:recaptcha   Recaptcha AntiSpamm enabled (wont work on Tor) https://u.nu/hbc7
  -d:packedjson  PackedJSON replaces JSON. Performance optimization. https://u.nu/byf-
  -d:adminnotify Send error logs (ERROR) to the specified Admin email.
  -d:dev         Development (ignore reCaptcha, no emails, more Verbose).
  -d:devemailon  Send error logs email when -d:dev is activated.
  -d:demo        Public demo mode. Enable Test user. 2FA ignored. Pages Reset.
                  Force database reset every 1 hour. Some options Disabled.

Docs:
  - https://nim-lang.org/learn.html
  - https://nim-lang.org/documentation.html
  - https://nim-lang.org/docs/lib.html
  - https://nim-lang.org/docs/theindex.html
  - https://nimble.directory
  - https://github.com/niv/nim-docset/releases """
