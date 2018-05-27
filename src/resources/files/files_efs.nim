import parsecfg, os, strutils, osproc, os
import ../utils/logging


let appDir = getAppDir()
let dict = loadConfig("config/config.cfg")

const section = when defined(dev): "storagedev" else: "storage"
let tempDir = dict.getSectionValue("Storage", section)

# Create folders
dbg("INFO", "Checking that required 'files' folders exists")
createDir("files")
createDir("files/efs")
createDir("fileslocal")

createDir(tempDir)
createDir(tempDir & "/tmp")
createDir(tempDir & "/files")
createDir(tempDir & "/files/private")
createDir(tempDir & "/files/public")
createDir(tempDir & "/users")

# Storage settings
when defined(dev):
  dbg("INFO", "Symlinking " & tempDir & " to files/efs")
  discard execCmd("ln -sf " & appDir & "/" & tempDir & "/* " & appDir & "/files/efs/")
else:
  dbg("INFO", "Symlinking " & tempDir & " to files/efs")
  discard execCmd("ln -sf " & tempDir & "/* " & appDir & "/files/efs/")

const storageEFS* = "files/efs"
