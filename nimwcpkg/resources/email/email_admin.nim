import asyncdispatch, smtp, strutils, os, htmlparser, asyncnet, parsecfg
from times import getTime, getGMTime, format


import ../email/email_connection
import ../email/email_generate_message


proc sendEmailAdminError*(msg: string) {.async.} =
  ## Send email - user removed

  let message = """Hi Admin
<br><br>
An error occurred.
<br><br>
$1
<br><br>
""" % [msg]
  
  await sendAdminMailNow("Admin: Error occurred", genEmailMessage(message))

