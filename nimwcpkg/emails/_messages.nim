## Do NOT import this file directly, instead import ``email.nim``

proc genEmailMessage*(msgContent: string): string {.inline.} =
  ## Generate email content
  preconditions msgContent.len > 0
  postconditions result.len > msgContent.len
  mailStyleHeader & msgContent & mailStyleFrom & mailStyleFooter
