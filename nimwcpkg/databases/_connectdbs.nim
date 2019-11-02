## Do NOT import this file directly, instead import ``database.nim``

template connectDb*(configFile = "config/config.cfg"): untyped =
  ## Connect the Database and injects a ``db`` variable with the ``DbConn``.
  assert configFile.len > 0, "config.cfg is empty."
  let
    dict = getConfig(configFile, cfgDatabase)
    db_host = dict["host"]
  assert db_host.len > 2, "db_host must not be empty string."
  when defined(postgres):
    let
      db_user = dict["user"]
      db_pass = dict["pass"]
      db_name = dict["name"]
    assert db_user.len > 0, "db_user must not be empty string."
    assert db_pass.len > 0, "db_pass must not be empty string."
    assert db_name.len > 0, "db_name must not be empty string."
    var db {.inject.} = db_postgres.open(connection=db_host, user=db_user, password=db_pass, database=db_name)
  else:
    let db_folder = dict["folder"]
    assert db_folder.len > 0, "db_folder must not be empty string."
    once: discard existsOrCreateDir(db_folder)  # Creating folder
    var db {.inject.} = db_sqlite.open(db_host, "", "", "")
