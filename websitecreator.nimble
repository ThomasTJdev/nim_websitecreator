# Package
version       = "0.1.1"
author        = "Thomas T. Jarløv (https://github.com/ThomasTJdev)"
description   = "Generate and host a website. Run the package and access your new webpage."
license       = "GPLv3"
bin           = @["websitecreator"]
skipDirs      = @["files", "fileslocal", "log", "private", "src", "tmp"]
skipExt       = @["nim"]


# Dependencies
requires "nim >= 0.18.0"
requires "jester >= 0.2.0"
requires "recaptcha >= 1.0.2"
requires "bcrypt >= 0.2.1"


import distros

task setup, "Generating executable":
  if detectOs(Windows):
    echo "Cannot run on Windows"
    quit()

  if not fileExists("config/config.cfg"):
    exec "cp config/config_default.cfg config/config.cfg"
  
  exec "nim c -d:release -d:ssl websitecreator.nim"

before install:
    setupTask()