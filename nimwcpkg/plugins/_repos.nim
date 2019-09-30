## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginRepoClone*(): bool =
  ## Clones (updates) the plugin repo
  preconditions existsDir(replace(getAppDir(), "/nimwcpkg", "") & "/plugins/")
  postconditions fileExists("plugins/nimwc_plugins/plugins.json")
  if unlikely(not("git".findExe.len > 0)): return false
  let folder = replace(getAppDir(), "/nimwcpkg", "") / "plugins/"
  let output = execCmd("git clone " & pluginRepo & " " & folder & pluginRepoName)
  if output != 0: return false
  return fileExists("plugins/nimwc_plugins/plugins.json")

proc pluginRepoUpdate*(): bool =
  ## Clones (updates) the plugin repo
  preconditions existsDir("plugins" / pluginRepoName)
  postconditions fileExists("plugins/nimwc_plugins/plugins.json")
  if unlikely(not("git".findExe.len > 0)): return false
  let folder = "plugins" / pluginRepoName
  assert existsDir(folder), "pluginRepoUpdate folder not found (Plugins)"
  let output = execCmd("git --force -C " & folder & " pull")
  if output != 0: return false
  return fileExists("plugins/nimwc_plugins/plugins.json")
