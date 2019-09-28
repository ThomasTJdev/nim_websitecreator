## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginGetDetails*(pluginFolder: string): tuple[name, version, description, url: string] =
  ## Get plugin data from [pluginName]/plugin.json
  preconditions pluginFolder.len > 0
  postconditions result[0].len > 0, result[1].len > 0, result[2].len > 0, result[3].len > 0
  let pluginJsonPath = "plugins/" & pluginFolder & "/plugin.json"
  let pluginJson = parseFile(pluginJsonPath)
  for plugin in items(pluginJson):
    let
      name = plugin["name"].getStr.strip
      version = plugin["version"].getStr.strip
      description = plugin["description"].getStr.strip
      url = plugin["url"].getStr.strip
    return (name, version, description, url)
