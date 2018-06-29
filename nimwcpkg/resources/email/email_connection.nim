import asyncdispatch, smtp, strutils, os, htmlparser, asyncnet, parsecfg, times

# Changing app dir due to, that module is not imported from main module
setCurrentDir(getAppDir())

var dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")

let smtpAddress    = dict.getSectionValue("SMTP","SMTPAddress")
let smtpPort       = dict.getSectionValue("SMTP","SMTPPort")
let smtpFrom       = dict.getSectionValue("SMTP","SMTPFrom")
let smtpUser       = dict.getSectionValue("SMTP","SMTPUser")
let smtpPassword   = dict.getSectionValue("SMTP","SMTPPassword")
let adminEmail     = dict.getSectionValue("SMTP","SMTPEmailAdmin")


proc sendMailNow*(subject, message, recipient: string) {.async.} =
  ## Send the email through smtp

  when defined(demo):
    echo "Demo is true, email is not send"

  when defined(dev) and not defined(devemailon):
    echo "Dev is true, email is not send"
    return

  const otherHeaders = @[("Content-Type", "text/html; charset=\"UTF-8\"")]  
  
  # Go Cx Manager
  var client = newAsyncSmtp(useSsl = true, debug = false)
  await client.connect(smtpAddress, Port(parseInt(smtpPort)))
  await client.auth(smtpUser, smtpPassword)

  let from_addr = smtpFrom
  let toList = @[recipient]

  var headers = otherHeaders
  headers.add(("From", from_addr))

  let encoded = createMessage(subject, message, toList, @[], headers)

  try:
    await client.sendMail(from_addr, toList, $encoded)

  except:
    echo "Error in sending mail: " & recipient

  when defined(dev):
    echo "Email send"



proc sendAdminMailNow*(subject, message: string) {.async.} =
  ## Send the email through smtp
  ## Clean admin mailing

  when defined(dev):
    echo "Dev is true, email is not send"
    return

  if adminEmail == "":
    echo "No admin email specified"
    return

  let recipient = adminEmail
  let from_addr = adminEmail
  const otherHeaders = @[("Content-Type", "text/html; charset=\"UTF-8\"")]  

  var client = newAsyncSmtp(useSsl = true, debug = false)

  await client.connect(smtpAddress, Port(parseInt(smtpPort)))

  await client.auth(smtpUser, smtpPassword)

  let toList = @[recipient]

  var headers = otherHeaders
  headers.add(("From", from_addr))

  let encoded = createMessage("Admin - " & subject, message,
      toList, @[], headers)

  await client.sendMail(from_addr, toList, $encoded)

  when defined(dev):
    echo "Admin email send"