import os, parsecfg, strutils

when defined(postgres): import db_postgres
else:                   import db_sqlite


template connectDb*(configFile = "config/config.cfg"): untyped =
  ## Connect the Database and injects a ``db`` variable with the ``DbConn``.
  assert configFile.len > 0, "configFile must not be empty string."
  let
    dict = loadConfig(configFile)
    db_host = dict.getSectionValue("Database", "host").strip
  assert db_host.len > 2, "db_host must not be empty string."
  when defined(postgres):
    let
      db_user = dict.getSectionValue("Database", "user").strip
      db_pass = dict.getSectionValue("Database", "pass").strip
      db_name = dict.getSectionValue("Database", "name").strip
    assert db_user.len > 0, "db_user must not be empty string."
    assert db_pass.len > 0, "db_pass must not be empty string."
    assert db_name.len > 0, "db_name must not be empty string."
    var db {.inject.} = db_postgres.open(connection=db_host, user=db_user, password=db_pass, database=db_name)
  else:
    let db_folder = dict.getSectionValue("Database", "folder").strip
    assert db_folder.len > 0, "db_folder must not be empty string."
    discard existsOrCreateDir(db_folder)  # Creating folder
    var db {.inject.} = db_sqlite.open(db_host, "", "", "")
