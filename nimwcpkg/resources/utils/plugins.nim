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

  let output = execCmd("git clone " & pluginRepo & " " & replace(getAppDir(), "/nimwcpkg", "") & "/plugins/" & pluginRepoName)

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

  let output = execProcess("git clone " & pluginGit & " " & replace(getAppDir(), "/nimwcpkg", "") & "/plugins/" & pluginFolder)

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


proc pluginDelete*(pluginFolder: string): bool =
  ## Updates an external plugin with pull

  let output = execProcess("rm -rf plugins/" & pluginFolder)

  if output == ("fatal: cannot change to " & pluginFolder & ": No such file or directory"):
    false
  else:
    true


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
    newFile.add("plugins/" & pluginName)

  writeFile("plugins/plugin_import.txt", newFile)


proc extensionSettings(): seq[string] =
  ## Macro to check if plugins listed in plugins_imported.txt
  ## are enabled or disabled. The result will be "true:pluginname"
  ## or "false:pluginname".

  let plugins = (readFile("plugins/plugin_import.txt").split("\n"))

  var extensions: seq[string]
  for plugin in walkDir("plugins/"):
    let (pd, ppath) = plugin
    discard pd

    if ppath in ["plugins/nimwc_plugins", "plugins/plugin_import.txt"]:
      continue
  
    if ppath in plugins:
      if extensions.len() == 0:
        extensions = @["true:" & ppath]
      else:
        extensions.add("true:" & ppath)

    else:
      if extensions.len() == 0:
        extensions = @["false:" & ppath]
      else:
        extensions.add("false:" & ppath)
  
  return extensions


proc genExtensionSettings*(): string =
  ## Generate HTML list items with plugins

  var extensions = ""
  for plugin in extensionSettings():
    let pluginName = replace((split(plugin, ":"))[1], "plugins/", "")
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
