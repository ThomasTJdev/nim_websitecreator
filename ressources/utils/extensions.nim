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
    echo staticExec("cp " & importit.split(":")[1] & "/public/js.js ../../public/js/" & importit.split(":")[0] & ".js")

    js.add("<script src=\"/js/" & importit.split(":")[0] & ".js\" defer></script>\n")

  return js



macro extensionImport(): untyped =
  ## Macro with 2 functions
  ##
  ## 1) Generate code for importing modules from extensions.
  ## The extensions main module needs to be in plugins/plugin_import.txt
  ## to be activated. Only 1 module will be imported.
  ##
  ## 2) Generate proc for updating the database with new tables etc.
  ## The extensions main module shall contain a proc named 'proc <extensionname>Start(db: DbConn) ='
  ## The proc will be executed when the program is executed.

  var plugins = (staticRead("../../plugins/plugin_import.txt").split("\n"))

  var extensions = ""
  for importit in plugins:
    extensions.add("import " & importit.split(":")[1] & "/" & importit.split(":")[0] & "\n")

  extensions.add("proc extensionUpdateDB*(db: DbConn) =")
  for importit in plugins:
    extensions.add("  " & importit.split(":")[0] & "Start(db)")

  result = parseStmt(extensions)

extensionImport()



macro caseRoute(): typed =
  ## The macro generates a case to access the url.
  ## When visiting a url with reference to the extensions,
  ## the name is  parsed to 'genExtension', which contains
  ## this case.

  var plugins = (staticRead("../../plugins/plugin_import.txt").split("\n"))

  var extensions = ""
  
  extensions.add("\n\ncase urlName\n")
  for caseit in plugins:
    extensions.add("\n")
    extensions.add(staticRead(caseit.split(":")[1] & "/routes.nim"))

  extensions.add("\n\nelse:\n")
  extensions.add("  return \"ERROR\"\n")

  result = parseStmt(extensions)


proc genExtension*(c: var TData, db: DbConn, urlName: string): string =
  ## Case routing to extensions

  caseRoute()
