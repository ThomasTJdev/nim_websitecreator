## Do NOT import this file directly, instead import ``email.nim``

proc sendEmailActivationManual*(email, userName, password, activateUrl, invitorName: string) {.async.} =
  ## Send the activation email, when admin added a new user.
  preconditions email.len > 5, userName.len > 0, password.len > 3, activateUrl.len > 0, invitorName.len > 0
  let message = activationMsg.format(
    userName, invitorName, email, password,
    (website & activateUrl), title, website, supportEmail)
  await sendMailNow(title & " - Email Confirmation", genEmailMessage(message), email)


proc sendEmailRegistrationFollowup*(email, userName: string) {.async.} =
  ## Send a follow up mail, if user has not used their activation link.
  preconditions email.len > 5, userName.len > 0
  await sendMailNow(title & "- Reminder: Email Confirmation",
    genEmailMessage(registrationMsg.format(userName, title, website, supportEmail)), email)
