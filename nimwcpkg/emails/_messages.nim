## Do NOT import this file directly, instead import ``email.nim``

proc genEmailMessage*(msgContent: string): string {.inline.} =
  ## Generate email content
  assert msgContent.len > 0
  mailStyleHeader & msgContent & mailStyleFrom & mailStyleFooter
