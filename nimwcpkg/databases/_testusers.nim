## Do NOT import this file directly, instead import ``database.nim``

proc createTestUser*(db: DbConn) {.discardable.} =
  ## Create new admin user.
  let anyAdmin = getAllRows(db, testusers_createTestUser0)
  info(createTestUserMsg.format(anyAdmin.len))

  if anyAdmin.len < 1:
    const salt = "0".repeat(128)  # Weak Salt for Test user only.
    discard insertID(db, testusers_createTestUser1,
      "Testuser", "test@test.com", makePassword("test", salt), salt, "Moderator")

    info("Test user added!.")
  else:
    info("Test user already exists. Skipping it.")
