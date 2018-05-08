import os, strutils, db_sqlite, rdstdin


import ../password/password_generate
import ../password/salt_generate
import ../utils/logging


proc createAdminUser*(db: DbConn): bool = 
  ## Create new admin user
  ## Input is done through stdin
  
  let iName = readLineFromStdin "Input admin name:     "
  let iEmail = readLineFromStdin "Input admin email:    "
  let iPwd = readLineFromStdin "Input admin password: "

  let salt = makeSalt()
  let password = makePassword(iPwd, salt)

  discard insertID(db, sql"INSERT INTO person (name, email, password, salt, status) VALUES (?, ?, ?, ?, ?)", $iName, $iEmail, password, salt, "Admin")

  return true