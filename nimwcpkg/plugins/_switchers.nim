## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginEnableDisable*(pluginPath, pluginName, status: string) =
  ## Enable or disable plugins in plugin_import.txt
  ##
  ## @"status" == false => Plugin is not enabled
  ##                       this will enable the plugin (add a line)
  ## @"status" == true  => Plugin is enabled,
  ##                       this will disable the plugin (remove the line)
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
