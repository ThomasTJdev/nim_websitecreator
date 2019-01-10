import
  os, strutils, ormin, logging,
  ../password/password_generate,
  ../password/salt_generate,
  ../utils/logging_nimwc


proc createAdminUser*(db: DbConn, args: seq[string]) =
  ## Create new admin user. Input is done through stdin.
  info("Checking if any Admin exists in DB.")

  var db {.global.} = db  # ORMin needs DbConn be var global named "db".
  let anyAdmin = query:
    select person(id)
    where status == "Admin"

  if anyAdmin.len() < 1:
    info("No Admin exists. Adding an Admin!.")
  else:
    info($anyAdmin.len() & " Admin already exists. Adding another Admin!.")

  var iName, iEmail, iPwd: string
  for arg in args:
    if arg.substr(0, 1) == "u:":
      iName = arg.substr(2, arg.len())
    elif arg.substr(0, 1) == "p:":
      iPwd = arg.substr(2, arg.len())
    elif arg.substr(0, 1) == "e:":
      iEmail = arg.substr(2, arg.len())

  if iName == "" or iPwd == "" or iEmail == "":
    error("Missing either name, password or email to create the Admin user.")

  let
    salt = makeSalt()
    password = makePassword(iPwd, salt)

  query:
    insert person(name = $iName, email = $iEmail,
                  password = ?password, salt = ?salt, status = !!"'Admin'")

  info("Admin added.")


proc createTestUser*(db: DbConn) =
  ## Create new admin user. Input is done through stdin.
  info("Checking if any test@test.com exists in DB.")

  var db {.global.} = db  # ORMin needs DbConn be var global named "db".
  let anyAdmin = query:
    select person(id)
    where email == "test@test.com"

  if anyAdmin.len() < 1:
    info("No test user exists. Creating it!.")

    let
      salt = makeSalt()
      password = makePassword("test", salt)

    query:
      insert person(name = !!"'Testuser'", email = !!"'test@test.com'",
                    password = ?password, salt = ?salt, status = !!"'Moderator'")

    info("Test user added!.")

  else:
    info("Test user already exists. Skipping it.")
