import asyncdispatch, contra

from strutils import format, countLines
from times import now

import ../../constants/constants
from ../email/email_generate_message import genEmailMessage
from ../email/email_connection import sendAdminMailNow


proc sendEmailAdminError*(msg: string) {.async.} =
  ## Send email - user removed
  preconditions msg.len > 0
  postconditions result is Future[void]
  await sendAdminMailNow(
    "Admin: Error occurred",
    genEmailMessage(adminErrorMsg.format(msg, msg.countLines, now())))
