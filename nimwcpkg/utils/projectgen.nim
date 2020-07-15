import os, times, rdstdin, strutils


template pluginSkeleton*() =
  ## Creates the skeleton (folders and files) for a plugin
  styledEcho(fgCyan, bgBlack, skeletonMsg)
  let pluginName = readLineFromStdin("Plugin name: ").strip.normalize
  assert pluginName.len > 1, "Plugin name needs to be longer: " & pluginName

  let
    authorName = readLineFromStdin("Author name: ").strip
    authorMail = readLineFromStdin("Author email: ").strip.toLowerAscii
    authorWeb = readLineFromStdin("Author website HTTP URL: ").strip

  # Create dirs
  discard existsOrCreateDir("plugins")
  let folder = "plugins" / pluginName
  discard existsOrCreateDir(folder)
  discard existsOrCreateDir(folder / "public")

  # Create files
  writeFile(folder / pluginName & ".nim", reqCode.format(pluginName))
  writeFile(folder / "routes.nim", reqRoutes.format(pluginName))
  writeFile(folder / "public" / "js.js",
    "/* https://github.com/pragmagic/karax OR Vanilla JavaScript */\n")
  writeFile(folder / "public" / "style.css",
    "/* https://bulma.io/documentation OR clean CSS */\n")

  if readLineFromStdin("Generate optional compile-time config files? (y/N): ") == "y":
    if readLineFromStdin("Use NimScript instead of CFG? (y/N): ").normalize == "y":
      writeFile(folder / pluginName & ".nims", "# https://nim-lang.org/docs/nims.html\n")
    else:
      writeFile(folder / pluginName & ".nim.cfg", "# https://nim-lang.org/docs/parsecfg.html\n")

  if readLineFromStdin("Generate Unitests files on ./tests/ ? (y/N): ") == "y":
    discard existsOrCreateDir(folder / "tests")
    writeFile(folder / "tests" / "test1.nim", "")

  if readLineFromStdin("Generate GitHub files including GitHub Actions on ./github/ ? (y/N): ") == "y":
    discard existsOrCreateDir(folder / ".github")
    discard existsOrCreateDir(folder / ".github" / "workflows")
    discard existsOrCreateDir(folder / ".github/ISSUE_TEMPLATE")
    discard existsOrCreateDir(folder / ".github/PULL_REQUEST_TEMPLATE")
    writeFile(folder / ".github/ISSUE_TEMPLATE/ISSUE_TEMPLATE.md", "")
    writeFile(folder / ".github/PULL_REQUEST_TEMPLATE/PULL_REQUEST_TEMPLATE.md", "")
    writeFile(folder / ".github/FUNDING.yml", "")
    writeFile(folder / ".github" / "workflows" / "build.yml", "")

  if readLineFromStdin("Generate NimWC files? (y/N): ") == "y":
    writeFile(folder / "public/js_private.js", "")
    writeFile(folder / "public/style_private.css", "")
    writeFile(folder / "html.nimf", "<!-- https://nim-lang.org/docs/filters.html -->\n")

  if readLineFromStdin("Generate .gitignore file? (y/N): ") == "y":
    writeFile(folder / ".gitattributes", "*.* linguist-language=Nim\n")
    writeFile(folder / ".gitignore", "*.c\n*.h\n*.o\n*.sql\n*.log\n*.s")

  if readLineFromStdin("Generate README,LICENSE,CHANGELOG,etc ? (y/N): ") == "y":
    let ext = if readLineFromStdin("Use Markdown (MD) instead of ReSTructuredText (RST)? (y/N): ") == "y": ".md" else: ".rst"
    writeFile(folder / "LICENSE" & ext, "See https://tldrlegal.com/licenses/browse\n")
    writeFile(folder / "CODE_OF_CONDUCT" & ext, "")
    writeFile(folder / "CONTRIBUTING" & ext, "")
    writeFile(folder / "AUTHORS" & ext, "# Authors\n\n- " & getEnv"USER" & "\n")
    writeFile(folder / "README" & ext, "# " & folder & "\n")
    writeFile(folder / "CHANGELOG" & ext, "# 0.0.1\n\n- First initial version of " & folder & " created at " & $now())

  writeFile(folder / "plugin.json", pluginJson.format(
    capitalizeAscii(pluginName), pluginName, authorName, authorMail, authorWeb, NimblePkgVersion.substr(0, 2)))

  if findExe"git".len > 0 and readLineFromStdin("Run 'git init .' on the Plugin folder? (y/N): ") == "y":
    if execShellCmd("git init .") == 0:
      if readLineFromStdin("Run 'git add .' on the Plugin folder? (y/N): ") == "y":
        if execShellCmd("git add .") == 0:
          if readLineFromStdin("Run 'git commit -a' on the Plugin folder? (y/N): ") == "y":
            if execShellCmd("git commit -am 'init'") == 0:
              if readLineFromStdin("Run 'git remote add origin ...' to add 1 Remote URL? (y/N): ") == "y":
                if execShellCmd("git remote add origin " & readLineFromStdin("Git Remote URL?: ").strip) == 0:
                  if readLineFromStdin("Run 'git fetch --all' on the Plugin folder? (y/N): ") == "y":
                    echo execShellCmd("git fetch --all") == 0

  quit("New Plugin at /plugins/\n\nNimWC created a new Plugin skeleton, happy hacking, bye...", 0)
