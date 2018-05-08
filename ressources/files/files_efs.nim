import parsecfg, os, strutils, osproc, os


# Using config.ini
let dict = loadConfig(getAppDir() & "/config/config.cfg")
let appDir = getAppDir()

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
  
  discard execCmd("ln -sf " & appDir & "/" & temp & "/* " & appDir & "/files/efs/")


when not defined(dev):
  var temp = dict.getSectionValue("Storage","storage")

  discard existsOrCreateDir(temp)
  discard existsOrCreateDir(temp & "/tmp")
  discard existsOrCreateDir(temp & "/files")
  discard existsOrCreateDir(temp & "/files/private")
  discard existsOrCreateDir(temp & "/files/public")
  discard existsOrCreateDir(temp & "/users")

  discard execCmd("ln -sf " & temp & "/* " & appDir & "/files/efs/")
  
  echo "ln -sf " & temp & "/* " & appDir & "/files/efs/"


let storageEFS* = "files/efs"

