## Do NOT import this file directly, instead import ``database.nim``

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
