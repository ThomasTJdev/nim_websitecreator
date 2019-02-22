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
  const sql_anyAdmin = sql"SELECT id FROM person WHERE status = 'Admin'"
  let anyAdmin = getAllRows(db, sql_anyAdmin)
  info($anyAdmin.len() & " Admins already exist. Adding 1 new Admin.")

  var iName, iEmail, iPwd: string
  for arg in args:
    if arg.substr(0, 1) == "u:":
      iName = arg.substr(2, arg.len()).strip
    elif arg.substr(0, 1) == "p:":
      iPwd = arg.substr(2, arg.len()).strip
    elif arg.substr(0, 1) == "e:":
      iEmail = arg.substr(2, arg.len()).strip

  doAssert iName.len > 3,  "Missing or invalid Name to create Admin user: " & iName
  doAssert iEmail.len > 5, "Missing or invalid Email to create Admin user: " & iEmail
  doAssert iPwd.len > 9,   "Missing or invalid Password to create Admin user."

  let
    salt = makeSalt()
    password = makePassword(iPwd, salt)

  discard insertID(db, sql"INSERT INTO person (name, email, password, salt, status) VALUES (?, ?, ?, ?, ?)", $iName, $iEmail, password, salt, "Admin")
  info("Admin added.")


proc createTestUser*(db: DbConn) =
  ## Create new admin user.
  info("Checking if any test@test.com exists in DB.")
  const sql_anyAdmin = sql"SELECT id FROM person WHERE email = 'test@test.com'"
  let anyAdmin = getAllRows(db, sql_anyAdmin)

  if anyAdmin.len() < 1:
    info("No test user exists. Creating it!.")

    const salt = "0".repeat(128)  # Weak Salt for Test user only.
    let password = makePassword("test", salt)

    discard insertID(db, sql("INSERT INTO person (name, email, password, salt, status) VALUES ('Testuser', 'test@test.com', '$1', '$2', 'Moderator')".format(password, salt)))

    info("Test user added!.")

  else:
    info("Test user already exists. Skipping it.")
