import parsecfg, os, strutils, osproc, os, logging


import ../utils/logging_nimwc


setCurrentDir(getAppDir().replace("/nimwcpkg", ""))

const
  section = when defined(dev): "storagedev" else: "storage"
  storageEFS* = "files/efs"

let
  appDir = replace(getAppDir(), "/nimwcpkg", "")
  dict = loadConfig("config/config.cfg")
  tempDir = dict.getSectionValue("Storage", section)
  paths2create = [
    "files", "files/efs", "fileslocal", tempDir, tempDir & "/tmp", tempDir & "/files",
    tempDir & "/files/private", tempDir & "/files/public", tempDir & "/users",
  ]

# Create folders
info("Checking that required 'files' folders exists.")
for folder in paths2create:
  discard existsOrCreateDir(folder)

# Storage settings
if tempDir == "fileslocal" or defined(dev):
  info("Symlinking " & tempDir & " to files/efs")
  discard execCmd("ln -sf " & appDir & "/" & tempDir & "/* " & appDir & "/files/efs/")

else:
  info("Symlinking " & tempDir & " to files/efs")
  discard execCmd("ln -sf " & tempDir & "/* " & appDir & "/files/efs/")
