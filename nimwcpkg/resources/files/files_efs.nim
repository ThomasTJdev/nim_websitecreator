import parsecfg, os, strutils, logging, contra, ../utils/logging_nimwc


let nimwcpkgDir = getAppDir().replace("/nimwcpkg", "")
let configFile = "config/config.cfg"
assert existsDir(nimwcpkgDir), "nimwcpkg directory not found: " & nimwcpkgDir
assert existsFile(configFile), "config/config.cfg file not found"

setCurrentDir(nimwcpkgDir)

const section = when defined(dev): "storagedev" else: "storage"

var storageEFS*: string


proc setFolderPath(): string =
  ## Sets the global folder path
  preconditions existsFile(configFile)
  postconditions result.len > 0, existsDir(result)
  let dict = loadConfig(configFile)
  result = dict.getSectionValue("Storage", section)

  if result == "fileslocal" or result == "":
    result = nimwcpkgDir / result

  info("Storage path set to: " & result)


proc createFolders() =
  ## Create folders
  info("Checking that required folders exists.")
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


storageEFS = setFolderPath()
createFolders()
