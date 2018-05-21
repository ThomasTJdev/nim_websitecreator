# Copyright 2018 - Thomas T. Jarløv

import
  asyncdispatch,
  asyncnet,
  db_sqlite,
  os,
  osproc,
  parseCfg,
  strutils


import ../../src/resources/email/email_registration
import ../../src/resources/password/password_generate
import ../../src/resources/password/salt_generate
import ../../src/resources/session/user_data
import ../../src/resources/utils/random_generator
import ../../src/resources/web/google_recaptcha


const pluginTitle       = "Themes"
const pluginAuthor      = "Thomas T. Jarløv"
const pluginVersion     = "0.1"
const pluginVersionDate = "2018-05-20"


proc pluginInfo() =
  echo " "
  echo "--------------------------------------------"
  echo "  Package:      " & pluginTitle & " plugin"
  echo "  Author:       " & pluginAuthor
  echo "  Version:      " & pluginVersion
  echo "  Version date: " & pluginVersionDate
  echo "--------------------------------------------"
  echo " "
pluginInfo()


proc currentStylesheet*(): string =
  let stylesheet = open("public/css/style.css", fmRead)
  let currentSheetLine = readLine(stylesheet)
  return currentSheetLine.substr(2, currentSheetLine.len() - 3)


include "html.tmpl"


proc themesStart*(db: DbConn) =
  ## Required proc. Will run on each program start
  ##
  ## If there's no need for this proc, just
  ## discard it. The proc may not be removed.

  echo "Themes: Copying style.css (default) to plugin folder"

  if not fileExists("plugins/themes/stylesheets/style.css"):
    discard execCmd("cp public/css/style.css plugins/themes/stylesheets/style.css")
  else:
    echo "Themes: style.css (default) already exists in plugin folder - skipping"