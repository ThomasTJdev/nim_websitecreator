## Do NOT import this file directly, instead import ``email.nim``

proc genEmailMessage*(msgContent: string): string {.inline.} =
  ## Generate email content
  mailStyleHeader & msgContent & mailStyleFrom & mailStyleFooter
