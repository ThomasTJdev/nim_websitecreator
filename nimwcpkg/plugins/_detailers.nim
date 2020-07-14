## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginGetDetails*(pluginFolder: string): tuple[name, version, description, url: string] =
  ## Get plugin data from [pluginName]/plugin.json
  assert pluginFolder.len > 0
  for plugin in items(parseFile("plugins" / pluginFolder / "plugin.json")):
    return (
      plugin["name"].getStr,
      plugin["version"].getStr,
      plugin["description"].getStr,
      plugin["url"].getStr
    )
