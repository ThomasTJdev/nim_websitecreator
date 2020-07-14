## Do NOT import this file directly, instead import ``database.nim``

func ask4UserPass*(): tuple[iName, iEmail, iPwd: string] {.inline.} =
  ## Ask the user for user, mail, password, and return them.
  var iName, iEmail, iPwd, iPwd2: string
  while not(iName.len > nameMinLen and iName.len < nameMaxLen):  # Max len from DB SQL
    iName = readLineFromStdin("\nType Username: ").strip
  while not(iEmail.len > emailMinLen and iEmail.len < emailMaxLen):
    iEmail = readLineFromStdin("\nType Email (Lowercase): ").strip.toLowerAscii
  while not(iPwd.len > passwordMinLen and iPwd.len < passwordMaxLen and iPwd == iPwd2):
    iPwd = readLineFromStdin("\nType Password: ").strip  # Type it Twice.
    iPwd2 = readLineFromStdin("\nConfirm Password (Repeat it again): ").strip
  result = (iName: iName, iEmail: iEmail, iPwd: iPwd)


proc createAdminUser*(db: DbConn) {.discardable.} =
  ## Create new admin user.
  const sqlAnyAdmin = sql"SELECT id FROM person WHERE status = 'Admin'"
  let anyAdmin = getAllRows(db, sqlAnyAdmin)
  info(createAdminUserMsg.format(anyAdmin.len))

  let (iName, iEmail, iPwd) = ask4UserPass() # Ask for User/Password/Mail

  let
    salt = makeSalt()
    password = makePassword(iPwd, salt)
  const sqlAddAdmin = sql"""
    INSERT INTO person (name, email, password, salt, status)
    VALUES (?, ?, ?, ?, ?)"""

  discard insertID(db, sqlAddAdmin, iName, iEmail, password, salt,
    if readLineFromStdin("\nis Admin? (y/N): ").normalize == "y": "Admin" else: "Moderator")
  info("1 new user added: " & iName)
