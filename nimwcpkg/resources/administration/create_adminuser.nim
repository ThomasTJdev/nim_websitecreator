import os, strutils, logging, rdstdin, contra
import ../password/password_generate, ../password/salt_generate, ../utils/logging_nimwc

import ../administration/connectdb

when defined(postgres): import db_postgres
else:                   import db_sqlite


const
  createAdminUserMsg = """Checking if any Admin exists in the database...
  $1 Admins already exists. Adding 1 new Admin.
  Requirements:
    - Username > 3 characters long.
    - Email    > 5 characters long.
    - Password > 9 characters long."""

  createTestUserMsg = """Checking if any test@test.com exists in the database...
  $1 Test user already exists."""


proc ask4UserPass*(): tuple[iName, iEmail, iPwd: string] =
  ## Ask the user for user, mail, password, and return them.
  postconditions(result.iName.len > 3, result.iEmail.len > 5, result.iPwd.len > 9,
    result.iName.len < 60, result.iEmail.len < 255, result.iPwd.len < 301)
  var iName, iEmail, iPwd, iPwd2: string
  while not(iName.len > 3 and iName.len < 60):  # Max len from DB SQL
    iName = readLineFromStdin("\nType Username: ").strip
  while not(iEmail.len > 5 and iEmail.len < 255):
    iEmail = readLineFromStdin("\nType Email (Lowercase): ").strip.toLowerAscii
  while not(iPwd.len > 9 and iPwd.len < 301 and iPwd == iPwd2):
    iPwd = readLineFromStdin("\nType Password: ").strip  # Type it Twice.
    iPwd2 = readLineFromStdin("\nConfirm Password (Repeat it again): ").strip
  result = (iName: iName, iEmail: iEmail, iPwd: iPwd)


proc createAdminUser*() {.discardable.} =
  ## Create new admin user.

  connectDb() # Read config, connect database, inject it as db variable.
  assert db is DbConn, "Failed to connect to database"

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
  info("Admin added.")
  close(db)


proc createTestUser*(db: DbConn) {.discardable.} =
  ## Create new admin user.
  const sqlAnyAdmin = sql"SELECT id FROM person WHERE email = 'test@test.com'"
  let anyAdmin = getAllRows(db, sqlAnyAdmin)
  info(createTestUserMsg.format(anyAdmin.len))

  if anyAdmin.len < 1:
    const salt = "0".repeat(128)  # Weak Salt for Test user only.
    const sqlAddTestUser = sql("""
      INSERT INTO person (name, email, password, salt, status)
      VALUES ('Testuser', 'test@test.com', ?, '$1', 'Moderator')""".format(salt))

    discard insertID(db, sqlAddTestUser, makePassword("test", salt))

    info("Test user added!.")
  else:
    info("Test user already exists. Skipping it.")
