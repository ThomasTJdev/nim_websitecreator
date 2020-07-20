## Do NOT import this file directly, instead import ``email.nim``

template genEmailMessage*(msgContent: string): string =
  ## Generate email content
  assert msgContent.len > 0
  mailStyleHeader & msgContent & mailStyleFrom & mailStyleFooter
