# Copyright 2018 - Thomas T. Jarløv

import strutils, osproc, os, json


const pluginRepo = "https://github.com/ThomasTJdev/nimwc_plugins.git"
const pluginRepoName = "nimwc_plugins"


proc pluginCheckGit*(): bool =
  ## Checks if git exists

  if execCmd("git > /dev/null") == 1:
    true
  else:
    false


proc pluginRepoExists(): bool =
  ## Check if plugin repo exists
  
  if fileExists("plugins/nimwc_plugins/plugins.json"):
    true
  else:
    false


proc pluginRepoClone*(): bool =
  ## Clones (updates) the plugin repo

  if not pluginCheckGit():
    return false

  let output = execCmd("git clone " & pluginRepo & " " & getAppDir() & "/plugins/" & pluginRepoName)

  if output != 0:
    return false

  return pluginRepoExists()


proc pluginRepoUpdate*(): bool =
  ## Clones (updates) the plugin repo

  if not pluginCheckGit():
    return false

  let output = execCmd("git -C plugins/" & pluginRepoName & " pull")

  if output != 0:
    return false

  return pluginRepoExists()


proc pluginDownload*(pluginGit, pluginFolder: string): bool =
  ## Downloads an external plugin with clone

  let output = execProcess("git clone " & pluginGit & " " & getAppDir() & "/plugins/" & pluginFolder)

  if output == ("fatal: repository '" & pluginGit & "' does not exists"):
    false
  else:
    true


proc pluginUpdate*(pluginFolder: string): bool =
  ## Updates an external plugin with pull

  let output = execProcess("git -C plugins/" & pluginFolder & " pull")

  if output == ("fatal: cannot change to " & pluginFolder & ": No such file or directory"):
    false
  else:
    true
  