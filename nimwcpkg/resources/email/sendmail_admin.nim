
proc sendAdminMailNow*(subject, message: string) {.async.} =
  ## Send email only to Admin.
  preconditions subject.len > 0, message.len > 0
  setCurrentDir(appDir)
  when defined(dev) and not defined(devemailon):
    info("Dev is true, email is not sent")
    return
  if adminEmail == "":
    info("No admin email specified")
    return

  let from_addr = adminEmail
  var
    headers = otherHeaders
    client = newAsyncSmtp(useSsl = true, debug = false)
  headers.add(("From", from_addr))
  let
    recipient = adminEmail
    toList = @[recipient]
    encoded = createMessage("Admin - " & subject, message, toList, @[], headers)

  try:
    await client.connect(smtpAddress, Port(parseInt(smtpPort)))
    await client.auth(smtpUser, smtpPassword)
    await client.sendMail(from_addr, toList, $encoded)
  except:
    info("Error in sending mail: " & recipient)
  when defined(dev): info("Admin email sent")
