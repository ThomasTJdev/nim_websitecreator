#
#
#        TTJ
#        (c) Copyright 2018 Thomas Toftgaard Jarløv
#        Plugin for Nim Website Creator: Contact
#        License: MIT
#
#

import strutils, os, db_sqlite, json, asyncdispatch, asyncnet, parsecfg, uri


from times import epochTime
import jester
import ../../ressources/email/email_connection
import ../../ressources/session/user_data
import ../../ressources/utils/dates
import ../../ressources/web/google_recaptcha


const pluginTitle       = "Contact"
const pluginAuthor      = "Thomas T. Jarløv"
const pluginVersion     = "0.1"
const pluginVersionDate = "2018-05-12"


proc pluginInfo() =
  echo "\n"
  echo "--------------------------------------------"
  echo "  Package:      " & pluginTitle & " plugin"
  echo "  Author:       " & pluginAuthor
  echo "  Version:      " & pluginVersion
  echo "  Version date: " & pluginVersionDate
  echo "--------------------------------------------"
  echo " "
pluginInfo()

let dict = loadConfig("config/config.cfg")
let emailSupport = dict.getSectionValue("SMTP","SMTPEmailSupport")
let title = dict.getSectionValue("Server","title")

include "html.tmpl"


proc contactSendMail*(c: var TData, db: DbConn, content, senderEmail, senderName: string): string =
  ## Send the mail

  let emailContent = """
A new message from $1
<br><br>
Senders name: $2
<br>
Senders email: $3
<br>
Email content:
$4
""" % [title, senderName, senderEmail, content]

  when not defined(demo):
    asyncCheck sendMailNow("Contact email from: " & senderName, emailContent, emailSupport)

  return "Thank you. The email was sent."
    


proc contactStart*(db: DbConn) =
  ## Required proc. Will run on each program start
  ##
  ## If there's no need for this proc, just
  ## discard it. The proc may not be removed.

  discard