## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginDownload*(pluginGit, pluginFolder: string): bool =
  ## Downloads an external plugin with clone
  preconditions pluginGit.len > 0, pluginFolder.len > 0
  let output = execProcess("git clone --depth 1 " & pluginGit & " " &
    replace(getAppDir(), "/nimwcpkg", "") / "plugins" / pluginFolder)
  result = output != "fatal: repository '" & pluginGit & "' does not exists"


proc pluginUpdate*(pluginFolder: string): bool =
  ## Updates an external plugin with pull
  preconditions pluginFolder.len > 0
  discard execCmd("git -C plugins" / pluginFolder & " fetch --all")
  discard execCmd("git -C plugins" / pluginFolder & " reset --hard origin/master")
  let output = execProcess("git --force -C plugins" / pluginFolder & " pull")
  result = output != "fatal: cannot change to " & pluginFolder & ": No such file or directory"
