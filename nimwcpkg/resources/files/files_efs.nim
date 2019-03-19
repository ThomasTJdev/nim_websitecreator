import parsecfg, os, strutils, logging, ../utils/logging_nimwc


setCurrentDir(getAppDir().replace("/nimwcpkg", ""))

const
  section = when defined(dev): "storagedev" else: "storage"
  storageEFS* = "files/efs"

let
  appDir = replace(getAppDir(), "/nimwcpkg", "")
  dict = loadConfig("config/config.cfg")
  tempDir = dict.getSectionValue("Storage", section)
  paths2create = [
    "files", "files/efs", "fileslocal", tempDir & "/tmp",
    tempDir & "/files", tempDir & "/files/private",
    tempDir & "/files/public", tempDir & "/users",
  ]

# Create folders
info("Checking that required 'files' folders exists.")
for folder in paths2create:
  discard existsOrCreateDir(folder)
  assert fpUserWrite in getFilePermissions(folder), "Wrong folder permissions:\n" & $getFilePermissions(folder) & folder

# Storage settings
if tempDir == "fileslocal" or defined(dev):
  info("Symlinking " & tempDir & " to files/efs")
  try:
    createSymlink(src= appDir & "/" & tempDir & "/*",
                  dest=appDir & "/files/efs/")
  except: discard
else:
  info("Symlinking " & tempDir & " to files/efs")
  try:
    createSymlink(src= tempDir & "/*",
                  dest=appDir & "/files/efs/")
  except: discard
