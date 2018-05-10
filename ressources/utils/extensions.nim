# Copyright 2018 - Thomas T. Jarløv

import strutils, macros, osproc, os, db_sqlite, parsecfg, re

from jester import Request

import ../session/user_data


macro extensionCss*(): string =
  ## Macro with 2 functions
  ##
  ## 1) Copy the plugins style.css to the public css/ folder and
  ## renaming to <extensionname>.css
  ##
  ## 2) Insert <style>-link into HTML

  var plugins = (staticRead("../../plugins/plugin_import.txt").split("\n"))

  var css = ""
  for importit in plugins:
    if staticRead(importit.split(":")[1] & "/public/style.css") == "":
      continue

    echo staticExec("cp " & importit.split(":")[1] & "/public/style.css ../../public/css/mailer.css")

    css.add("<link rel=\"stylesheet\" href=\"/css/" & importit.split(":")[0] & ".css\">\n")

  return css


macro extensionJs*(): string =
  ## Macro with 2 functions
  ##
  ## 1) Copy the plugins js.js to the public js/ folder and
  ## renaming to <extensionname>.js
  ##
  ## 2) Insert <js>-link into HTML

  var plugins = (staticRead("../../plugins/plugin_import.txt").split("\n"))

  var js = ""
  for importit in plugins:
    if staticRead(importit.split(":")[1] & "/public/js.js") == "":
      continue

    echo staticExec("cp " & importit.split(":")[1] & "/public/js.js ../../public/js/" & importit.split(":")[0] & ".js")

    js.add("<script src=\"/js/" & importit.split(":")[0] & ".js\" defer></script>\n")

  return js
