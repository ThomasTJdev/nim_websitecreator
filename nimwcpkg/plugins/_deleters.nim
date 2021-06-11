## Do NOT import this file directly, instead import ``plugins.nim``

proc pluginDelete*(pluginFolder: string): bool =
  ## Delete a Plugin from the filesystem.
  preconditions pluginFolder.len > 0, fileExists"plugins/plugin_import.txt"
  for line in lines("plugins/plugin_import.txt"):
    if line == pluginFolder:
      return false
  try:
    removeDir("plugins" / pluginFolder)
    result = true
  except:
    result = false
  finally:
    echo "Removed Plugin folder and subfolders: ./plugins/" & pluginFolder
