import parsecfg, os, strutils, logging

const section = when defined(dev): "storagedev" else: "storage"

let
  appDir = getAppDir().replace("/nimwcpkg", "")
  storageEFS* = block:
    var path = loadConfig(appDir / "config/config.cfg").getSectionValue("Storage", section)
    if path.len == 0 or path == "fileslocal": path = appDir / path
    info("Storage path set to: " & path)
    path  # storageEFS = path


once:  # https://nim-lang.github.io/Nim/system.html#once.t%2Cuntyped
  info("Checking that required folders exists. This will only be done once.")
  let paths2create = [
    storageEFS,
    storageEFS / "tmp",
    storageEFS / "files",
    storageEFS / "files/private",
    storageEFS / "files/public",
    storageEFS / "users"
  ]
  for folder in paths2create:
    discard existsOrCreateDir(folder)
    assert fpUserWrite in getFilePermissions(folder), "Wrong folder permissions:\n" & $getFilePermissions(folder) & folder


include "_walkers"
