# Package

version       = "0.1.0"
author        = "Thomas T. Jarløv (https://github.com/ThomasTJdev)"
description   = "Generate and host a website. Run the package and access your new webpage."
license       = "GPLv3"
bin           = @["websitecreator"]
skipDirs      = @["data", "files", "fileslocal", "log", "private", "src", "tmp"]
skipExt       = @["nim"]


# Dependencies

requires "nim >= 0.18.0"
requires "jester >= 0.2.0"
requires "recaptcha >= 1.0.2"
requires "bcrypt >= 0.2.1"
