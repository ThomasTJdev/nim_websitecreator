## Do NOT import this file directly, instead import ``email.nim``

proc sendAdminMailNow*(subject, message: string) {.async.} =
  ## Send email only to Admin.
  assert subject.len > 0 and message.len > 0
  setCurrentDir(appDir)
  when defined(dev) and not defined(devemailon):
    info("Dev is true, email is not sent")
    return
  if adminEmail == "":
    info("No admin email specified")
    return
  var
    headers = otherHeaders
    client = newAsyncSmtp(useSsl = true, debug = false)
  headers.add(("From", adminEmail))
  let encoded = createMessage("Admin - " & subject, message, @[adminEmail], @[], headers)

  try:
    await client.connect(smtpAddress, Port(parseInt(smtpPort)))
    await client.auth(smtpUser, smtpPassword)
    await client.sendMail(adminEmail, @[adminEmail], $encoded)
  except:
    error("Error in sending mail: " & adminEmail)
  when defined(dev): info("Admin email sent")
