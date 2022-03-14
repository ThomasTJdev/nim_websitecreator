## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginGetDetails*(pluginFolder: string): tuple[name, version, description, url: string] =
  ## Get plugin data from [pluginName]/plugin.json
  let
    pluginJsonPath = "plugins" / pluginFolder / "plugin.json"
    pluginJson     = parseFile(pluginJsonPath)

  for plugin in items(pluginJson):
    let
      name = plugin["name"].getStr.strip
      version = plugin["version"].getStr.strip
      description = plugin["description"].getStr.strip
      url = plugin["url"].getStr.strip
    return (name, version, description, url)
