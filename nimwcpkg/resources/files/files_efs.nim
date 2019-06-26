import parsecfg, os, strutils, logging, ../utils/logging_nimwc


setCurrentDir(getAppDir().replace("/nimwcpkg", ""))

const section = when defined(dev): "storagedev" else: "storage"

var storageEFS*: string


proc setFolderPath(): string =
  ## Sets the global folder path
  let dict = loadConfig("config/config.cfg")
  result = dict.getSectionValue("Storage", section)

  if result == "fileslocal" or result == "":
    result = replace(getAppDir(), "/nimwcpkg", "") / result

  info("Storage path set to: " & result)
  return result


proc createFolders() =
  ## Create folders
  info("Checking that required folders exists.")
  let paths2create = [
    storageEFS,
    storageEFS & "/tmp",
    storageEFS & "/files",
    storageEFS & "/files/private",
    storageEFS & "/files/public",
    storageEFS & "/users"
  ]
  for folder in paths2create:
    discard existsOrCreateDir(folder)
    assert fpUserWrite in getFilePermissions(folder), "Wrong folder permissions:\n" & $getFilePermissions(folder) & folder


storageEFS = setFolderPath()
createFolders()
