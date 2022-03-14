## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginRepoClone*(): bool =
  ## Clones (updates) the plugin repo
  let cmd = "git clone " & pluginRepo & " " & replace(getAppDir(), "/nimwcpkg", "") / "plugins/nimwc_plugins"
  when defined(dev): echo cmd
  execCmdEx(cmd).exitCode == 0


proc pluginRepoUpdate*(): bool =
  ## Clones (updates) the plugin repo
  let cmd = "git -C plugins" / pluginRepoName & " pull"
  when defined(dev): echo cmd
  execCmdEx(cmd).exitCode == 0
