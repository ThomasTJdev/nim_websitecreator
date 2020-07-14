## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginDownload*(pluginGit, pluginFolder: string): bool {.inline.} =
  ## Downloads an external plugin with clone
  assert pluginGit.len > 0 and pluginFolder.len > 0
  execCmdEx("git clone --depth 1 " & pluginGit & " " &
    replace(getAppDir(), "/nimwcpkg", "") / "plugins" / pluginFolder,
    options = {poStdErrToStdOut, poUsePath, poEchoCmd}).exitCode == 0


proc pluginUpdate*(pluginFolder: string): bool =
  ## Updates an external plugin with pull
  assert pluginFolder.len > 0
  if execCmdEx("git -C plugins" / pluginFolder & " fetch --all").exitCode == 0:
    if execCmdEx("git -C plugins" / pluginFolder & " reset --hard origin/master").exitCode == 0:
      result = execCmdEx("git -C plugins" / pluginFolder & " pull origin master").exitCode == 0
