## Do NOT import this file directly, instead import ``email.nim``

proc sendEmailAdminError*(msg: string) {.async.} =
  ## Send email - user removed
  assert msg.len > 0
  await sendAdminMailNow("Admin: Error occurred", genEmailMessage(
    adminErrorMsg.format(msg, msg.countLines, now())))
