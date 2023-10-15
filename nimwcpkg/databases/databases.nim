import os, parsecfg, tables, osproc, logging, times, nativesockets, strutils, rdstdin

import ../constants/constants, ../utils/configs, ../passwords/passwords, ../enums/enums
export head, navbar, footer, title  # HTML template fragments

when NimMajor < 2:
    when defined(postgres): import db_postgres
    else:                   import db_sqlite
else:
    when defined(postgres): import db_connector/db_postgres
    else:                   import db_connector/db_sqlite

let nimwcpkgDir = getAppDir().replace("/nimwcpkg", "")
assert dirExists(nimwcpkgDir), "nimwcpkg directory not found"


template vacuumDb*(db: DbConn): bool = db.tryExec(sqlVacuum)


# Order is important here.
include
  "_connectdbs",
  "_createdbs",
  "_testusers",
  "_adminusers",
  "_standarddatas",
  "_backupdbs"
