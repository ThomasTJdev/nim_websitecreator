import os, strutils, db_sqlite, logging


import ../password/password_generate
import ../password/salt_generate
import ../utils/logging_nimwc


proc createAdminUser*(db: DbConn, args: seq[string]) =
  ## Create new admin user
  ## Input is done through stdin

  info("Checking if any Admin exists in DB.")
  let anyAdmin = getAllRows(db, sql"SELECT id FROM person WHERE status = ?", "Admin")

  if anyAdmin.len() < 1:
    info("No Admin exists. Adding an Admin!.")
  else:
    info($anyAdmin.len() & " Admin already exists. Adding another Admin!.")

  var iName = ""
  var iEmail = ""
  var iPwd = ""

  for arg in args:
    if arg.substr(0, 1) == "u:":
      iName = arg.substr(2, arg.len())
    elif arg.substr(0, 1) == "p:":
      iPwd = arg.substr(2, arg.len())
    elif arg.substr(0, 1) == "e:":
      iEmail = arg.substr(2, arg.len())

  if iName == "" or iPwd == "" or iEmail == "":
    error("Missing either name, password or email to create the Admin user.")

  let salt = makeSalt()
  let password = makePassword(iPwd, salt)

  discard insertID(db, sql"INSERT INTO person (name, email, password, salt, status) VALUES (?, ?, ?, ?, ?)", $iName, $iEmail, password, salt, "Admin")

  info("Admin added.")


proc createTestUser*(db: DbConn) =
  ## Create new admin user
  ## Input is done through stdin

  info("Checking if any test@test.com exists in DB.")
  let anyAdmin = getAllRows(db, sql"SELECT id FROM person WHERE email = ?", "test@test.com")

  if anyAdmin.len() < 1:
    info("No test user exists. Creating it!.")

    let salt = makeSalt()
    let password = makePassword("test", salt)

    discard insertID(db, sql"INSERT INTO person (name, email, password, salt, status) VALUES (?, ?, ?, ?, ?)", "Testuser", "test@test.com", password, salt, "Moderator")

    info("Test user added!.")

  else:
    info("Test user already exists. Skipping it.")
