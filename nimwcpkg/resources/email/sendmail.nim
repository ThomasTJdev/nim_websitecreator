
proc sendMailNow*(subject, message, recipient: string) {.async.} =
  ## Send the email through smtp
  preconditions subject.len > 0, message.len > 0, recipient.len > 0
  setCurrentDir(appDir)
  when defined(demo): info("Demo is true, email is not send")
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
    info("Error in sending mail: " & recipient)
  when defined(dev): info("Email sent")