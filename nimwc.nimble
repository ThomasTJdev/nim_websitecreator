# Package
version       = "6.0.6"
author        = "Thomas T. Jarløv (https://github.com/ThomasTJdev) & Juan Carlos (https://github.com/juancarlospaco)"
description   = "Generate and host a website. Run the package and access your new webpage."
license       = "PPL"
bin           = @["nimwc"]
skipDirs      = @["private", "tmp", "devops", "docs"]
installDirs   = @["config", "nimwcpkg", "plugins", "public"]



# Dependencies
requires "nim >= 1.2.4"
requires "jester >= 0.4.3"
requires "otp >= 0.1.1"
requires "recaptcha >= 1.0.3"
requires "packedjson >= 0.1.0"
requires "gatabase >= 0.9.9"


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

  if not defined(ssl):
    echo "SSL not defined: SSL is disabled, running unsecure."

  if not defined(firejail):
    echo "Firejail not defined: Firejail is disabled, running unsecure."


before install:
  setupTask()
