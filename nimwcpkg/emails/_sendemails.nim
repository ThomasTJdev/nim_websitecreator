## Do NOT import this file directly, instead import ``email.nim``

proc sendMailNow*(subject, message, recipient: string) {.async.} =
  ## Send the email through smtp
  setCurrentDir(appDir)
  when defined(dev) and not defined(devemailon):
    info("Dev is true, email is not send")
    return

  let
    from_addr = smtpFrom
    toList = @[recipient]
  var
    client = newAsyncSmtp(useSsl = true, debug = false)
    headers = otherHeaders
  headers.add(("From", from_addr))
  let encoded = createMessage(subject, message, toList, @[], headers)

  try:
    await client.connect(smtpAddress, Port(parseInt(smtpPort)))
    await client.auth(smtpUser, smtpPassword)
    await client.sendMail(from_addr, toList, $encoded)
  except:
    error("Error in sending mail: " & recipient)
  when defined(dev): info("Email sent")
