import os, strutils, db_sqlite, rdstdin


import ../password/password_generate
import ../password/salt_generate
import ../utils/logging


proc createAdminUser*(db: DbConn, args: seq[string]) = 
  ## Create new admin user
  ## Input is done through stdin
  
  dbg("INFO", "Checking if any Admin exists in DB")
  let anyAdmin = getAllRows(db, sql"SELECT id FROM person WHERE status = ?", "Admin")
  
  if anyAdmin.len() < 1:
    dbg("INFO", "No Admin exists. Create it!")
    
    var iName = ""
    var iEmail = ""
    var iPwd = ""

    for arg in args:
      if arg.substr(0, 2) == "-u:":
        iName = arg.substr(3, arg.len())
      elif arg.substr(0, 2) == "-p:":
        iPwd = arg.substr(3, arg.len())
      elif arg.substr(0, 2) == "-e:":
        iEmail = arg.substr(3, arg.len())

    if iName == "" or iPwd == "" or iEmail == "":
      dbg("ERROR", "Missing either name, password or email to create the admin user")

    let salt = makeSalt()
    let password = makePassword(iPwd, salt)

    discard insertID(db, sql"INSERT INTO person (name, email, password, salt, status) VALUES (?, ?, ?, ?, ?)", $iName, $iEmail, password, salt, "Admin")

    dbg("INFO", "Admin added! Moving on..")
  else:
    dbg("ERROR", "Admin user already exists. Skipping it.")
  

proc createTestUser*(db: DbConn) = 
  ## Create new admin user
  ## Input is done through stdin
  
  dbg("INFO", "Checking if any test@test.com exists in DB")
  let anyAdmin = getAllRows(db, sql"SELECT id FROM person WHERE email = ?", "test@test.com")
  
  if anyAdmin.len() < 1:
    dbg("INFO", "No test user exists. Create it!")
    
    let salt = makeSalt()
    let password = makePassword("test", salt)

    discard insertID(db, sql"INSERT INTO person (name, email, password, salt, status) VALUES (?, ?, ?, ?, ?)", "Testuser", "test@test.com", password, salt, "Moderator")

    dbg("INFO", "Test user added! Moving on..")

  else:
    dbg("INFO", "Test user already exists. Skipping it.")
  