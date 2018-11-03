import asyncdispatch, smtp, strutils, os, htmlparser, asyncnet, parsecfg

import ../email/email_connection
import ../email/email_generate_message


let dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")

let title = dict.getSectionValue("Server","title")
let website = dict.getSectionValue("Server","website")
let supportEmail = dict.getSectionValue("SMTP","SMTPEmailSupport")



proc sendEmailActivationManual*(email, userName, password, activateUrl, invitorName: string) {.async.} =
  ## Send the activation email, when admin added a new user

  let message = """Hello $1,
<br><br>
$2 has created a user account for you on $7.
<br><br>
As the final step in your registration, we require that you confirm your email
via the following link:
  <br>
  $5
  <br><br>
To login use the details below. On your first login, please navigate to your settings and change your password!
<br>
Email:    $3
<br>
Password: $4
<br><br>
Please do not hesitate to contact us at $8, if you have any questions.
<br><br>
Thank you for registering and becoming a part of $6!""" % [userName, invitorName, email, password, (website & activateUrl), title, website, supportEmail]

  await sendMailNow(title & " - Email Confirmation", genEmailMessage(message), email)




proc sendEmailRegistrationFollowup*(email, userName: string) {.async.} =
  ## Send a follow up mail, if user
  ## has not used their activation link

  let message = """Hello $1,
<br><br>
We are looking forward to see you at $3! We have sent you an activation email with your password. You just need to click on the link become a part of $3.
<br><br>
Please do not hesitate to contact us at $5, if you have any questions.
<br><br>
Thank you for registering and becoming a part of $2!""" % [userName, title, website, supportEmail]

  await sendMailNow(title & "- Reminder: Email Confirmation", genEmailMessage(message), email)
