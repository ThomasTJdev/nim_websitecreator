import strutils, osproc, os, json


const
  pluginRepo = "https://github.com/ThomasTJdev/nimwc_plugins.git"
  pluginRepoName = "nimwc_plugins"
  pluginHtmlListItem = """
    <li data-plugin="$1" class="pluginSettings $6" data-enabled="$2">
      <div class="name"> <a href="$3"><b>$4</b> <i>($5)</i></a> </div>
      <div class="enablePlugin"  title="Turn ON">  Start </div>
      <div class="disablePlugin" title="Turn OFF"> Stop  </div>
    </li>"""


proc pluginCheckGit*(): bool {.inline.} =
  ## Checks if git exists
  "git".findExe.len > 0


proc pluginExtractDetails*(pluginFolder: string): tuple[name, version, description, url: string] =
  ## Get plugin data from [pluginName]/plugin.json
  assert pluginFolder.len > 0, "pluginFolder must not be empty string"
  let pluginJsonPath = "plugins/" & pluginFolder & "/plugin.json"
  assert existsFile(pluginJsonPath), "pluginJsonPath file not found (plugin.json)"
  let pluginJson = parseFile(pluginJsonPath)
  for plugin in items(pluginJson):
    let
      name = plugin["name"].getStr.strip
      version = plugin["version"].getStr.strip
      description = plugin["description"].getStr.strip
      url = plugin["url"].getStr.strip
    return (name, version, description, url)


proc pluginRepoClone*(): bool =
  ## Clones (updates) the plugin repo
  if unlikely(not pluginCheckGit()):
    return false
  let folder = replace(getAppDir(), "/nimwcpkg", "") & "/plugins/"
  assert existsDir(folder), "pluginRepoClone folder not found (Plugins)"
  let output = execCmd("git clone " & pluginRepo & " " & folder & pluginRepoName)
  if output != 0:
    return false
  return fileExists("plugins/nimwc_plugins/plugins.json")


proc pluginRepoUpdate*(): bool =
  ## Clones (updates) the plugin repo
  if unlikely(not pluginCheckGit()):
    return false
  let folder = "plugins" / pluginRepoName
  assert existsDir(folder), "pluginRepoUpdate folder not found (Plugins)"
  let output = execCmd("git --force -C " & folder & " pull")
  if output != 0:
    return false
  return fileExists("plugins/nimwc_plugins/plugins.json")


proc pluginDownload*(pluginGit, pluginFolder: string): bool =
  ## Downloads an external plugin with clone
  assert pluginGit.len > 0, "pluginGit must not be empty string"
  assert pluginFolder.len > 0, "pluginFolder must not be empty string"
  let output = execProcess("git clone --depth 1 " & pluginGit & " " &
    replace(getAppDir(), "/nimwcpkg", "") & "/plugins/" & pluginFolder)
  result = output != "fatal: repository '" & pluginGit & "' does not exists"


proc pluginUpdate*(pluginFolder: string): bool =
  ## Updates an external plugin with pull
  assert pluginFolder.len > 0, "pluginFolder must not be empty string"
  discard execCmd("git -C plugins/" & pluginFolder & " fetch --all")
  discard execCmd("git -C plugins/" & pluginFolder & " reset --hard origin/master")
  let output = execProcess("git --force -C plugins/" & pluginFolder & " pull")
  result = output != "fatal: cannot change to " & pluginFolder & ": No such file or directory"


proc pluginDelete*(pluginFolder: string): bool =
  ## Delete a Plugin from the filesystem.
  assert pluginFolder.len > 0, "pluginFolder must not be empty string"
  assert existsFile"plugins/plugin_import.txt", "plugins/plugin_import.txt not found"
  for line in lines("plugins/plugin_import.txt"):
    if line == pluginFolder:
      return false
  try:
    removeDir("plugins/" & pluginFolder)
    result = true
  except:
    result = false
  finally:
    echo "Removed Plugin folder and subfolders: ./plugins/" & pluginFolder


proc pluginEnableDisable*(pluginPath, pluginName, status: string) =
  ## Enable or disable plugins in plugin_import.txt
  ##
  ## @"status" == false => Plugin is not enabled
  ##                       this will enable the plugin (add a line)
  ## @"status" == true  => Plugin is enabled,
  ##                       this will disable the plugin (remove the line)
  assert pluginPath.len > 0, "pluginPath must not be empty string"
  assert pluginName.len > 0, "pluginName must not be empty string"
  assert status in ["false", "true"], "status must be true or false"
  assert existsFile"plugins/plugin_import.txt", "plugins/plugin_import.txt not found"
  var newFile = ""
  for line in lines("plugins/plugin_import.txt"):
    if line == "" or line == pluginPath:
      continue
    else:
      newFile.add(line)

    newFile.add("\n")

  if status == "false":
    newFile.add(pluginName)

  writeFile("plugins/plugin_import.txt", newFile)


proc extensionSettings(): seq[string] =
  ## Macro to check if plugins listed in plugins_imported.txt
  ## are enabled or disabled. The result will be "true:pluginname"
  ## or "false:pluginname".
  assert existsFile"plugins/plugin_import.txt", "plugins/plugin_import.txt not found"
  let plugins = readFile("plugins/plugin_import.txt").splitLines

  # Walk through files and folders in the plugin directory
  var extensions: seq[string]
  for plugin in walkDir("plugins/"):
    let (pd, ppath) = plugin
    discard pd
    let ppathName = replace(ppath, "plugins/", "")

    # Skip these files/folders
    if ppathName in ["nimwc_plugins", "plugin_import.txt"]:
      continue

    # If the plugins is present in plugin_import, set the
    # plugin status to true, else false
    if ppathName in plugins:
      if extensions.len() == 0:
        extensions = @["true:" & ppathName]
      else:
        extensions.add("true:" & ppathName)

    else:
      if extensions.len() == 0:
        extensions = @["false:" & ppathName]
      else:
        extensions.add("false:" & ppathName)

  return extensions


proc genExtensionSettings*(): string =
  ## Generate HTML list items with plugins
  for plugin in extensionSettings():
    let pluginName = (split(plugin, ":"))[1]

    result.add(pluginHtmlListItem.format(
      # $1
      pluginName,

      # $2
      (split(plugin, ":"))[0] == "true",

      # $3
      if (split(plugin, ":"))[0] == "true":
        pluginName & "/settings"
      else:
        "#",

      # $4
      pluginName.capitalizeAscii,

      # $5
      if (split(plugin, ":"))[0] == "true":
        "ON"
      else:
        "OFF",

      # $6
      if (split(plugin, ":"))[0] == "true":
        "enabled"
      else:
        "disabled"
    ))
