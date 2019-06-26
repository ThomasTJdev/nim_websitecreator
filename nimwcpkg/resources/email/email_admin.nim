import asyncdispatch

from strutils import format, countLines
from times import now

from ../email/email_generate_message import genEmailMessage
from ../email/email_connection import sendAdminMailNow


const adminErrorMsg = """<!DOCTYPE html>
  <center>
    <h1>Error Logs</h1>
    <p>Hi Admin, an error occurred at $3 </p>
    <textarea name="logs" id="logs" title="Log Size: $2 Lines." dir="auto" rows=20 readonly autofocus spellcheck style="width:99% !important">
      $1
    </textarea>
    <br>
    <a title="Copy Logs" onclick="document.querySelector('#logs').select();document.execCommand('copy')">
      <button>Copy</button>
    </a>
    <br>
  </center>
  """


proc sendEmailAdminError*(msg: string) {.async.} =
  ## Send email - user removed
  assert msg.len > 0, "msg must not be empty string: " & msg
  await sendAdminMailNow(
    "Admin: Error occurred",
    genEmailMessage(adminErrorMsg.format(msg.strip, msg.countLines, now())))
