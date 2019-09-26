import parsecfg, contra

from strutils import format, replace
from os import getAppDir

import ../../constants/constants


let
  dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
  title = dict.getSectionValue("Server", "title")
  website = dict.getSectionValue("Server", "website")
  mailStyleHeader = mailStyleHeaderMsg.format(website, title)
  mailStyleFooter = mailStyleFooterMsg.format(website, title)


proc genEmailMessage*(msgContent: string): string {.inline.} =
  ## Generate email content
  preconditions msgContent.len > 0
  postconditions result.len > msgContent.len
  mailStyleHeader & msgContent & mailStyleFrom & mailStyleFooter
