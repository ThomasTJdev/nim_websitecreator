import
  asyncdispatch, smtp, strutils, os, htmlparser, asyncnet, parsecfg, times,
  ../email/email_connection,
  ../email/email_generate_message


const adminErrorMsg = """
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
  await sendAdminMailNow(
    "Admin: Error occurred",
    genEmailMessage(adminErrorMsg.format(msg, msg.splitLines.len, now())))
