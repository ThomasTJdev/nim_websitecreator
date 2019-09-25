import asyncdispatch, parsecfg, contra

from strutils import replace, format
from os import getAppDir

import ../../constants/constants
from ../email/email_generate_message import genEmailMessage
from ../email/email_connection import sendMailNow


let
  dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
  title = dict.getSectionValue("Server", "title")
  website = dict.getSectionValue("Server", "website")
  supportEmail = dict.getSectionValue("SMTP", "SMTPEmailSupport")


using email, userName, password, activateUrl, invitorName: string


proc sendEmailActivationManual*(email, userName, password, activateUrl, invitorName) {.async.} =
  ## Send the activation email, when admin added a new user.
  preconditions email.len > 5, userName.len > 0, password.len > 3, activateUrl.len > 0, invitorName.len > 0
  postconditions result is Future[void]
  let message = activationMsg.format(
    userName, invitorName, email, password,
    (website & activateUrl), title, website, supportEmail)
  await sendMailNow(title & " - Email Confirmation", genEmailMessage(message), email)


proc sendEmailRegistrationFollowup*(email, userName) {.async.} =
  ## Send a follow up mail, if user has not used their activation link.
  preconditions email.len > 5, userName.len > 0
  postconditions result is Future[void]
  await sendMailNow(title & "- Reminder: Email Confirmation",
    genEmailMessage(registrationMsg.format(userName, title, website, supportEmail)), email)
