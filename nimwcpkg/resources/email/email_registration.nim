import asyncdispatch, parsecfg

from strutils import replace, format
from os import getAppDir

from ../email/email_generate_message import genEmailMessage
from ../email/email_connection import sendMailNow


const
  activationMsg = """
    <h3>Hello $1 </h3>
    <br><br>
    $2 has created a user account for you on $7.
    <br><br>
    As the final step in your registration, we require that you confirm your email
    via the following link:
    <br>
    $5
    <br><br>
    To login use the details below. On your first login, please navigate to your settings and <b>change your password!</b>
    <ul>
      <li>Email:   <code> $3 </code></li>
      <li>
        Password:
        <input type="text" title="Password" onClick="this.select();document.execCommand('copy')" value="$4" readonly >
      </li>
    </ul>
    Please do not hesitate to contact us at $8, if you have any questions.
    <br><br>
    Thank you for registering and becoming a part of $6!"""

  registrationMsg = """
    <h3>Hello $1 </h3>
    <br><br>
    We are looking forward to see you at $3!
    We have sent you an activation email with your password.
    You just need to click on the link become a part of $3.
    <a href="https://freeotp.github.io">Get FreeOTP App at https://freeotp.github.io</a>
    <br><br>
    Please do not hesitate to contact us at $5, if you have any questions.
    <br><br>
    Thank you for registering and becoming a part of $2!"""


let
  dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
  title = dict.getSectionValue("Server", "title")
  website = dict.getSectionValue("Server", "website")
  supportEmail = dict.getSectionValue("SMTP", "SMTPEmailSupport")


using email, userName, password, activateUrl, invitorName: string


proc sendEmailActivationManual*(email, userName, password, activateUrl, invitorName) {.async.} =
  ## Send the activation email, when admin added a new user.
  let message = activationMsg.format(
    userName, invitorName, email, password,
    (website & activateUrl), title, website, supportEmail)
  await sendMailNow(title & " - Email Confirmation", genEmailMessage(message), email)


proc sendEmailRegistrationFollowup*(email, userName) {.async.} =
  ## Send a follow up mail, if user has not used their activation link.
  let message = registrationMsg.format(userName, title, website, supportEmail)
  await sendMailNow(title & "- Reminder: Email Confirmation", genEmailMessage(message), email)
