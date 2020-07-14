## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginRepoClone*(): bool {.inline.} =
  ## Clones (updates) the plugin repo
  assert pluginRepo.len > 0 # poEchoCmd does echo cmd
  execCmdEx("git clone " & pluginRepo & " " & replace(getAppDir(), "/nimwcpkg", "") / "plugins/nimwc_plugins",
    options = {poStdErrToStdOut, poUsePath, poEchoCmd}).exitCode == 0


proc pluginRepoUpdate*(): bool {.inline.} =
  ## Clones (updates) the plugin repo
  assert existsDir("plugins" / pluginRepoName)
  execCmdEx("git -C plugins" / pluginRepoName & " pull",
    options = {poStdErrToStdOut, poUsePath, poEchoCmd}).exitCode == 0
