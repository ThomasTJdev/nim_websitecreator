## Do NOT import this file directly, instead import ``email.nim``

proc sendMailNow*(subject, message, recipient: string) {.async.} =
  ## Send the email through smtp
  assert subject.len > 0 and message.len > 0 and recipient.len > 0
  setCurrentDir(appDir)
  when defined(dev) and not defined(devemailon):
    info("Dev is true, email is not send")
    return
  var
    client = newAsyncSmtp(useSsl = true, debug = false)
    headers = otherHeaders
  headers.add(("From", smtpFrom))
  let encoded = createMessage(subject, message, @[recipient], @[], headers)

  try:
    await client.connect(smtpAddress, Port(parseInt(smtpPort)))
    await client.auth(smtpUser, smtpPassword)
    await client.sendMail(smtpFrom, @[recipient], $encoded)
  except:
    error("Error in sending mail: " & recipient)
  when defined(dev): info("Email sent")
