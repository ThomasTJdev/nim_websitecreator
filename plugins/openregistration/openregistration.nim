# Copyright 2018 - Thomas T. Jarløv

import
  asyncdispatch,
  asyncnet,
  db_sqlite,
  parseCfg,
  strutils


import ../../src/resources/email/email_registration
import ../../src/resources/password/password_generate
import ../../src/resources/password/salt_generate
import ../../src/resources/session/user_data
import ../../src/resources/utils/random_generator
import ../../src/resources/web/google_recaptcha


const pluginTitle       = "Open registration"
const pluginAuthor      = "Thomas T. Jarløv"
const pluginVersion     = "0.1"
const pluginVersionDate = "2018-05-14"


proc pluginInfo() =
  echo " "
  echo "--------------------------------------------"
  echo "  Package:      " & pluginTitle & " plugin"
  echo "  Author:       " & pluginAuthor
  echo "  Version:      " & pluginVersion
  echo "  Version date: " & pluginVersionDate
  echo "--------------------------------------------"
  echo " "
pluginInfo()


include "html.tmpl"


let openRegistration* = true


proc openregistrationCheck*(): bool =
  return openRegistration


proc openregistrationRegister*(db: DbConn, name, email: string): tuple[b: bool, s: string] =
  ## Register a user with open registration access

  if not openRegistration:
    return (false, "Open registration is not enabled")

  # Check email formatting
  if not ("@" in email and "." in email):
    return (false, "Error: Your email has a wrong format")

  # Check if email alreay exists
  let emailExist = getValue(db, sql"SELECT id FROM person WHERE email = ?", email)
  if emailExist != "":
    return (false, "Error: A user with that email already exists")

  # Generate password
  let salt = makeSalt()
  let passwordOriginal = randomString(12)
  let password = makePassword(passwordOriginal, salt)
  let secretUrl = randomStringDigitAlpha(99)

  # Add user
  let userID = insertID(db, sql"INSERT INTO person (name, email, status, password, salt, secretUrl) VALUES (?, ?, ?, ?, ?, ?)", name, email, "User", password, salt, secretUrl)

  # Send activation email
  asyncCheck sendEmailActivationManual(email, name, passwordOriginal, "/users/activate?id=" & $userID & "&ident=" & secretUrl, "There")

  return (true, "")



proc openregistrationStart*(db: DbConn) =
  ## Required proc. Will run on each program start
  ##
  ## If there's no need for this proc, just
  ## discard it. The proc may not be removed.

  echo "Open registration: Public registration is " & $openRegistration