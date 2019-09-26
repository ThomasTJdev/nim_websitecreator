import asyncdispatch, smtp, strutils, os, parsecfg, logging, contra, tables

import ../utils/configs

# Changing app dir due to, that module is not imported from main module
let appDir = getAppDir().replace("/nimwcpkg", "")
let configFile = appDir / "config/config.cfg"
assert existsDir(appDir), "appDir directory not found: " & appDir
assert existsFile(configFile), "config/config.cfg file not found"
setCurrentDir(appDir)

const otherHeaders = @[("Content-Type", "text/html; charset=\"UTF-8\"")]

let
  dict = getConfig(configFile, "SMTP")
  smtpAddress  = dict["SMTPAddress"]
  smtpPort     = dict["SMTPPort"]
  smtpFrom     = dict["SMTPFrom"]
  smtpUser     = dict["SMTPUser"]
  smtpPassword = dict["SMTPPassword"]
  adminEmail   = dict["SMTPEmailAdmin"]


proc sendMailNow*(subject, message, recipient: string) {.async.} =
  ## Send the email through smtp
  preconditions subject.len > 0, message.len > 0, recipient.len > 0
  postconditions result is Future[void]
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
  ## Send email only to Admin.
  preconditions subject.len > 0, message.len > 0
  postconditions result is Future[void]
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

  when defined(dev):
    info("Admin email sent")
