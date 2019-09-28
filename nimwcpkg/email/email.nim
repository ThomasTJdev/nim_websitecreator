import asyncdispatch, contra, strutils, times, os, parsecfg, smtp, logging

import ../constants/constants

when defined(postgres): import db_postgres
else: import db_sqlite


## Base Header for SMTP.
const otherHeaders = @[("Content-Type", "text/html; charset=\"UTF-8\"")]


## Read config file here,so we only do the I/O only once for all submodules.
let
  appDir = getAppDir().replace("/nimwcpkg", "")
  dict = loadConfig(appDir / "config/config.cfg")
  supportEmail = dict.getSectionValue("SMTP", "SMTPEmailSupport")
  smtpAddress = dict.getSectionValue("SMTP", "SMTPAddress")
  smtpPort = dict.getSectionValue("SMTP", "SMTPPort")
  smtpFrom = dict.getSectionValue("SMTP", "SMTPFrom")
  smtpUser = dict.getSectionValue("SMTP", "SMTPUser")
  smtpPassword = dict.getSectionValue("SMTP", "SMTPPassword")
  adminEmail = dict.getSectionValue("SMTP", "SMTPEmailAdmin")
  title = dict.getSectionValue("Server", "title")
  website = dict.getSectionValue("Server", "website")
  mailStyleHeader = mailStyleHeaderMsg.format(website, title)
  mailStyleFooter = mailStyleFooterMsg.format(website, title)


# Order is important here.
include
  "_email_generate_message",
  "_sendmail",
  "_sendmail_admin",
  "_senderror_admin",
  "_email_registration"
