
proc sendEmailAdminError*(msg: string) {.async.} =
  ## Send email - user removed
  preconditions msg.len > 0
  await sendAdminMailNow("Admin: Error occurred", genEmailMessage(
    adminErrorMsg.format(msg, msg.countLines, now())))
