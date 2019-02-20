# Package
version       = "5.0.0"
author        = "Thomas T. Jarløv (https://github.com/ThomasTJdev) & Juan Carlos (https://github.com/juancarlospaco)"
description   = "Generate and host a website. Run the package and access your new webpage."
license       = "GPLv3"
bin           = @["nimwc"]
skipDirs      = @["private", "tmp", "devops"]
installDirs   = @["config", "nimwcpkg", "plugins", "public"]



# Dependencies
requires "nim >= 0.19.4"
requires "jester >= 0.4.1"
requires "recaptcha >= 1.0.2"
requires "bcrypt >= 0.2.1"
requires "gatabase >= 0.2.2"
requires "datetime2human >= 0.2.2"
requires "otp >= 0.1.1"
requires "firejail >= 0.4.0"
requires "webp >= 0.1.0"
requires "unsplash >= 0.1.0"


import distros

task setup, "Generating executable":
  if detectOs(Windows):
    quit("Cannot run on Windows, but you can try Docker for Windows: http://docs.docker.com/docker-for-windows")

  if not fileExists("config/config.cfg"):
    exec "cp -v config/config_default.cfg config/config.cfg"

  exec "nim c -r -d:release -d:ssl nimwc.nim"

before install:
    setupTask()
