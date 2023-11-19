# Package
version       = "6.1.4"
author        = "Thomas T. Jarløv (https://github.com/ThomasTJdev) & Juan Carlos (https://github.com/juancarlospaco)"
description   = "Generate and host a website. Run the package and access your new webpage."
license       = "MIT"
bin           = @["nimwc"]
skipDirs      = @["private", "tmp", "devops", "docs"]
installDirs   = @["config", "nimwcpkg", "plugins", "public"]


# Nim v2
when NimMajor >= 2:
  requires "db_connector >= 0.1.0"
  requires "smtp >= 0.1.0"


# Dependencies
requires "nim >= 1.6.0"
requires "jester >= 0.4.3"
requires "bcrypt >= 0.2.1"
requires "datetime2human >= 0.2.5"
requires "firejail >= 0.5.0"
requires "otp >= 0.1.1"
requires "recaptcha >= 1.0.3"
requires "webp >= 0.2.5"
requires "packedjson >= 0.1.0"


import distros

task setup, "Generating executable":
  if detectOs(Windows):
    quit("Cannot run on Windows, but you can try Docker for Windows: http://docs.docker.com/docker-for-windows")

  if not fileExists("config/config.cfg"):
    cpFile("config/config_default.cfg", "config/config.cfg")
    echo "Config file created. Please update the file: config/config.cfg."

  if defined(webp):
    foreignDep "libwebp"

  if defined(firejail):
    foreignDep "firejail"

  if defined(demo):
    echo "Demo Mode: Database will reset each hour with the standard data."

before install:
  setupTask()
