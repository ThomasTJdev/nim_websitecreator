import contra, tables

from strutils import format, replace
from os import getAppDir

import ../../constants/constants, ../utils/configs


let
  dict = getConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg", "Server")
  title = dict["title"]
  website = dict["website"]
  mailStyleHeader = mailStyleHeaderMsg.format(website, title)
  mailStyleFooter = mailStyleFooterMsg.format(website, title)


proc genEmailMessage*(msgContent: string): string {.inline.} =
  ## Generate email content
  preconditions msgContent.len > 0
  postconditions result.len > msgContent.len
  mailStyleHeader & msgContent & mailStyleFrom & mailStyleFooter
