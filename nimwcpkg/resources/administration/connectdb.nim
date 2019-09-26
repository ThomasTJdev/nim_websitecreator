import os, logging, parsecfg, strutils

when defined(postgres): import db_postgres
else:                   import db_sqlite


template connectDb*(configFile = "config/config.cfg"): untyped =
  ## Connect the Database and injects a ``db`` variable with the ``DbConn``.
  assert configFile.len > 0, "configFile must not be empty string."
  let
    dict = loadConfig(configFile)
    db_user {.used.} = dict.getSectionValue("Database", "user").strip
    db_pass {.used.} = dict.getSectionValue("Database", "pass").strip
    db_name {.used.} = dict.getSectionValue("Database", "name").strip
    db_host = dict.getSectionValue("Database", "host").strip
    db_folder = dict.getSectionValue("Database", "folder").strip
    dbexists =
      when defined(postgres): db_host.len > 2
      else:                   fileExists(db_host)

  if dbexists: info("Database: Already exists")

  when defined(postgres):
    assert db_user.len > 0, "db_user must not be empty string."
    assert db_pass.len > 0, "db_pass must not be empty string."
    assert db_name.len > 0, "db_name must not be empty string."
    assert db_host.len > 2, "db_host must not be empty string."
  else: discard existsOrCreateDir(db_folder)  # Creating folder

  var db {.inject.} =
    when defined(postgres):
      db_postgres.open(connection=db_host, user=db_user, password=db_pass, database=db_name)
    else:
      db_sqlite.open(db_host, "", "", "")
