import os, strutils, db_sqlite, rdstdin


import ../password/password_generate
import ../password/salt_generate
import ../utils/logging


proc createAdminUser*(db: DbConn) = 
  ## Create new admin user
  ## Input is done through stdin
  
  dbg("INFO", "Checking if any Admin exists in DB")
  let anyAdmin = getAllRows(db, sql"SELECT id FROM person WHERE status = ?", "Admin")
  
  if anyAdmin.len() < 1:
    dbg("INFO", "No Admin exists. Create it!")
    
    let iName = readLineFromStdin "Input admin name:     "
    let iEmail = readLineFromStdin "Input admin email:    "
    let iPwd = readLineFromStdin "Input admin password: "

    let salt = makeSalt()
    let password = makePassword(iPwd, salt)

    discard insertID(db, sql"INSERT INTO person (name, email, password, salt, status) VALUES (?, ?, ?, ?, ?)", $iName, $iEmail, password, salt, "Admin")

    dbg("INFO", "Admin added! Moving on..")

  else:
    dbg("INFO", "Admin user already exists. Skipping it.")
  

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
  