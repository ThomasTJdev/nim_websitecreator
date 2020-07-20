## Do NOT import this file directly, instead import ``email.nim``

proc sendEmailActivationManual*(email, userName, password, activateUrl, invitorName: string) {.async.} =
  ## Send the activation email, when admin added a new user.
  assert email.len > 5 and userName.len > 0 and password.len > 3 and activateUrl.len > 0 and invitorName.len > 0
  await sendMailNow(title & " - Email Confirmation", genEmailMessage(
    activationMsg.format(
      userName, invitorName, email, password, (website & activateUrl), title, website, supportEmail)
    ), email,
  )


proc sendEmailRegistrationFollowup*(email, userName: string) {.async.} =
  ## Send a follow up mail, if user has not used their activation link.
  assert email.len > 5 and userName.len > 0
  await sendMailNow(title & "- Reminder: Email Confirmation",
    genEmailMessage(registrationMsg.format(userName, title, website, supportEmail)), email)
