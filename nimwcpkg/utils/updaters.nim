import os, osproc, ./utils

proc updateNimwc*() =
  ## GIT hard update
  assert findExe"git".len > 0
  assert dirExists"plugins/"
  assert dirExists"public/js/"
  assert dirExists"public/css/"
  assert fileExists"public/js/js_custom.js"
  assert fileExists"plugins/plugin_import.txt"
  assert fileExists"public/css/style_custom.css"
  creates "", pluginImport, styleCustom, jsCustom, humansTxt
  pluginImport[] = readFile"plugins/plugin_import.txt"  # Save contents
  styleCustom[] = readFile"public/css/style_custom.css"
  jsCustom[] = readFile"public/js/js_custom.js"
  humansTxt[] = readFile"public/humans.txt"
  discard execCmdEx("git fetch --all ; git reset --hard origin/master",
    options = {poStdErrToStdOut, poUsePath, poEchoCmd})
  writeFile("plugins/plugin_import.txt", pluginImport[])  # Write contents back
  writeFile("public/css/style_custom.css", styleCustom[])
  writeFile("public/js/js_custom.js", jsCustom[])
  writeFile("public/humans.txt", humansTxt[])
  deallocs pluginImport, styleCustom, jsCustom, humansTxt
  quit("\n\nTo finish the update:\n - Compile NimWC\n - Run with the arg `--newdb`\nGit fetch and update done", 0)
