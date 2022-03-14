## Do NOT import this file directly, instead import ``plugins.nim``

proc extensionSettings(): seq[string] =
  ## Proc to check if plugins listed in plugins_imported.txt
  ## are enabled or disabled. The result will be "true:pluginname"
  ## or "false:pluginname".
  let plugins = readFile("plugins/plugin_import.txt").splitLines

  # Walk through files and folders in the plugin directory
  var extensions: seq[string]
  for plugin in walkDir("plugins/"):
    let (pd, ppath) = plugin
    discard pd
    let ppathName = replace(ppath, "plugins/", "")

    # Skip these files/folders
    if ppathName in ["nimwc_plugins", "plugin_import.txt"]: continue

    # If the plugins is present in plugin_import, set the
    # plugin status to true, else false
    if ppathName in plugins:
      if extensions.len == 0:
        extensions = @["true:" & ppathName]
      else:
        extensions.add("true:" & ppathName)

    else:
      if extensions.len == 0:
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
