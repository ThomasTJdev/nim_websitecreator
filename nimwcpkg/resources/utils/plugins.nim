# Copyright 2018 - Thomas T. Jarløv
import strutils, osproc, os, json

const
  pluginRepo = "https://github.com/ThomasTJdev/nimwc_plugins.git"
  pluginRepoName = "nimwc_plugins"


proc pluginExtractDetails*(pluginFolder: string): tuple[name, version, description, url: string] =
  ## Get plugin data from [pluginName]/plugin.json
  let pluginJson = parseFile("plugins/" & pluginFolder & "/plugin.json")
  for plugin in items(pluginJson):
    let
      name = plugin["name"].getStr()
      version = plugin["version"].getStr()
      description = plugin["description"].getStr()
      url = plugin["url"].getStr()
    return (name, version, description, url)


func pluginCheckGit*(): bool {.inline.} =
  ## Checks if git exists
  result = execCmd("git > /dev/null") == 1


proc pluginRepoClone*(): bool =
  ## Clones (updates) the plugin repo
  if unlikely(not pluginCheckGit()):
    return false
  let output = execCmd("git clone " & pluginRepo & " " &
    replace(getAppDir(), "/nimwcpkg", "") & "/plugins/" & pluginRepoName)
  if output != 0:
    return false
  return fileExists("plugins/nimwc_plugins/plugins.json")


func pluginRepoUpdate*(): bool =
  ## Clones (updates) the plugin repo
  if unlikely(not pluginCheckGit()):
    return false
  let output = execCmd("git -C plugins/" & pluginRepoName & " pull")
  if output != 0:
    return false
  return fileExists("plugins/nimwc_plugins/plugins.json")


proc pluginDownload*(pluginGit, pluginFolder: string): bool =
  ## Downloads an external plugin with clone
  let output = execProcess("git clone " & pluginGit & " " &
    replace(getAppDir(), "/nimwcpkg", "") & "/plugins/" & pluginFolder)
  result = output != "fatal: repository '" & pluginGit & "' does not exists"


proc pluginUpdate*(pluginFolder: string): bool =
  ## Updates an external plugin with pull
  discard execCmd("git -C plugins/" & pluginFolder & " fetch --all")
  discard execCmd("git -C plugins/" & pluginFolder & " reset --hard origin/master")
  let output = execProcess("git -C plugins/" & pluginFolder & " pull")
  result = output != "fatal: cannot change to " & pluginFolder & ": No such file or directory"


proc pluginDelete*(pluginFolder: string): bool =
  ## Updates an external plugin with pull
  for line in lines("plugins/plugin_import.txt"):
    if line == pluginFolder:
      return false
  let output = execProcess("rm -rf plugins/" & pluginFolder)
  result = output != "fatal: cannot change to " & pluginFolder & ": No such file or directory"


proc pluginEnableDisable*(pluginPath, pluginName, status: string) =
  ## Enable or disable plugins in plugin_import.txt
  ##
  ## @"status" == false => Plugin is not enabled
  ##                       this will enable the plugin (add a line)
  ## @"status" == true  => Plugin is enabled,
  ##                       this will disable the plugin (remove the line)

  var newFile = ""
  for line in lines("plugins/plugin_import.txt"):
    if line == "":
      continue
    if line == pluginPath:
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

  let plugins = (readFile("plugins/plugin_import.txt").split("\n"))

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

  var extensions = ""
  for plugin in extensionSettings():
    let pluginName = (split(plugin, ":"))[1]
    let status = if (split(plugin, ":"))[0] == "true": "enabled" else: "disabled"

    extensions.add("<li data-plugin=\"" & pluginName & "\" class=\"pluginSettings ")

    if (split(plugin, ":"))[0] == "true":
      extensions.add("enabled\" data-enabled=\"true\"")
    else:
      extensions.add("disabled\" data-enabled=\"false\"")

    extensions.add(">")
    extensions.add("<div class=\"name\">")
    if (split(plugin, ":"))[0] == "true":
      extensions.add("  <a href=\"/" & pluginName & "/settings\">" & pluginName & " <i>[" & status & "]</i></a>")
    else:
      extensions.add("  " & pluginName & " <i>[" & status & "]</i>")
    extensions.add("</div>")
    extensions.add("<div class=\"enablePlugin\">Start</div>")
    extensions.add("<div class=\"disablePlugin\">Stop</div>")
    extensions.add("</li>")

  return extensions
