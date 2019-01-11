import
  asyncdispatch, smtp, strutils, os, htmlparser, asyncnet, parsecfg, times, logging,
  ../utils/logging_nimwc

# Changing app dir due to, that module is not imported from main module
setCurrentDir(getAppDir())

const otherHeaders = @[("Content-Type", "text/html; charset=\"UTF-8\"")]

let
  dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
  smtpAddress  = dict.getSectionValue("SMTP", "SMTPAddress")
  smtpPort     = dict.getSectionValue("SMTP", "SMTPPort")
  smtpFrom     = dict.getSectionValue("SMTP", "SMTPFrom")
  smtpUser     = dict.getSectionValue("SMTP", "SMTPUser")
  smtpPassword = dict.getSectionValue("SMTP", "SMTPPassword")
  adminEmail   = dict.getSectionValue("SMTP", "SMTPEmailAdmin")


proc sendMailNow*(subject, message, recipient: string) {.async.} =
  ## Send the email through smtp
  when defined(demo):
    info("Demo is true, email is not send")
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

  when defined(dev):
    info("Email sent")


proc sendAdminMailNow*(subject, message: string) {.async.} =
  ## Send the email through smtp. Clean admin mailing.
  when defined(dev):
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

  when defined(dev):
    info("Admin email sent")
