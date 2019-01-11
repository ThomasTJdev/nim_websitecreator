import
  asyncdispatch, smtp, strutils, os, htmlparser, asyncnet, parsecfg,
  ../email/email_connection,
  ../email/email_generate_message

const AdminErrorMsg = """
  Hi Admin
  <br><br>
  An error occurred.
  <br><br>
  $1
  <br><br>"""


proc sendEmailAdminError*(msg: string) {.async.} =
  ## Send email - user removed
  await sendAdminMailNow("Admin: Error occurred",
                         genEmailMessage(AdminErrorMsg.format(msg)))
