## Do NOT import this file directly, instead import ``database.nim``

proc ask4UserPass*(): tuple[iName, iEmail, iPwd: string] {.inline.} =
  ## Ask the user for user, mail, password, and return them.
  creates "", iName, iEmail, iPwd, iPwd2
  while not(iName[].len > nameMinLen and iName[].len < nameMaxLen):  # Max len from DB SQL
    iName[] = readLineFromStdin("\nType Username: ").strip
  while not(iEmail[].len > emailMinLen and iEmail[].len < emailMaxLen):
    iEmail[] = readLineFromStdin("\nType Email (Lowercase): ").strip.toLowerAscii
  while not(iPwd[].len > passwordMinLen and iPwd[].len < passwordMaxLen and iPwd[] == iPwd2[]):
    iPwd[] = readLineFromStdin("\nType Password: ").strip  # Type it Twice.
    iPwd2[] = readLineFromStdin("\nConfirm Password (Repeat it again): ").strip
  result = (iName: iName[], iEmail: iEmail[], iPwd: iPwd[])
  deallocs iName, iEmail, iPwd, iPwd2


proc createAdminUser*(db: DbConn) {.discardable.} =
  ## Create new admin user.
  let anyAdmin = getAllRows(db, adminusers_createAdminUser0)
  info(createAdminUserMsg.format(anyAdmin.len))

  let (iName, iEmail, iPwd) = ask4UserPass() # Ask for User/Password/Mail

  let
    salt = makeSalt()
    password = makePassword(iPwd, salt)

  discard insertID(db, adminusers_createAdminUser1, iName, iEmail, password, salt,
    if readLineFromStdin("\nis Admin? (y/N): ").normalize == "y": "Admin" else: "Moderator")
  info("1 new user added: " & iName)
