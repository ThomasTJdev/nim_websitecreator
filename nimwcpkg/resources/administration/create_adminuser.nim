import
  os, strutils, logging, random, base32,
  ../password/password_generate,
  ../password/salt_generate,
  ../utils/logging_nimwc

when defined(sqlite): import db_sqlite
else:                 import db_postgres
randomize()

proc createAdminUser*(db: DbConn, args: seq[string]) =
  ## Create new admin user.
  info("Checking if any Admin exists in DB.")
  let anyAdmin = getAllRows(db, sql"SELECT id FROM person WHERE status = ?", "Admin")
  info($anyAdmin.len() & " Admins already exist. Adding 1 new Admin.")

  var iName, iEmail, iPwd: string
  for arg in args:
    if arg.substr(0, 1) == "u:":
      iName = arg.substr(2, arg.len()).strip
    elif arg.substr(0, 1) == "p:":
      iPwd = arg.substr(2, arg.len()).strip
    elif arg.substr(0, 1) == "e:":
      iEmail = arg.substr(2, arg.len()).strip

  doAssert(iName.len > 3 and iEmail.len > 5 and iPwd.len > 3,
           "Missing or invalid Name, Email or Password to create Admin user.")

  let
    salt = makeSalt()
    password = makePassword(iPwd, salt)

  discard insertID(db, sql"INSERT INTO person (name, email, password, salt, status, twofa) VALUES (?, ?, ?, ?, ?, ?)", $iName, $iEmail, password, salt, "Admin", base32.encode($rand(10_01.int..89_98.int)))

  info("Admin added.")


proc createTestUser*(db: DbConn) =
  ## Create new admin user.
  info("Checking if any test@test.com exists in DB.")
  let anyAdmin = getAllRows(db, sql"SELECT id FROM person WHERE email = ?", "test@test.com")

  if anyAdmin.len() < 1:
    info("No test user exists. Creating it!.")

    let
      salt = makeSalt()
      password = makePassword("test", salt)

    discard insertID(db, sql"INSERT INTO person (name, email, password, salt, status, twofa) VALUES (?, ?, ?, ?, ?, ?)", "Testuser", "test@test.com", password, salt, "Moderator", base32.encode($rand(10_01.int..89_98.int)))

    info("Test user added!.")

  else:
    info("Test user already exists. Skipping it.")
