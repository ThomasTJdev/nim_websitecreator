import parsecfg, os, strutils, osproc, os


import ../utils/logging


let appDir = replace(getAppDir(), "/nimwcpkg", "")

let dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")


# Create folders
dbg("INFO", "Checking that required 'files' folders exists")
discard existsOrCreateDir("files")
discard existsOrCreateDir("files/efs")
discard existsOrCreateDir("fileslocal")



# Storage settings
when defined(dev):
  var temp = dict.getSectionValue("Storage","storagedev")

  discard existsOrCreateDir(temp)
  discard existsOrCreateDir(temp & "/tmp")
  discard existsOrCreateDir(temp & "/files")
  discard existsOrCreateDir(temp & "/files/private")
  discard existsOrCreateDir(temp & "/files/public")
  discard existsOrCreateDir(temp & "/users")
  
  dbg("INFO", "Symlinking " & temp & " to files/efs")
  discard execCmd("ln -sf " & appDir & "/" & temp & "/* " & appDir & "/files/efs/")


when not defined(dev):
  var temp = dict.getSectionValue("Storage","storage")

  discard existsOrCreateDir(temp)
  discard existsOrCreateDir(temp & "/tmp")
  discard existsOrCreateDir(temp & "/files")
  discard existsOrCreateDir(temp & "/files/private")
  discard existsOrCreateDir(temp & "/files/public")
  discard existsOrCreateDir(temp & "/users")

  dbg("INFO", "Symlinking " & temp & " to files/efs")
  discard execCmd("ln -sf " & temp & "/* " & appDir & "/files/efs/")
  

let storageEFS* = "files/efs"

