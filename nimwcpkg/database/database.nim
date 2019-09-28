import os, parsecfg, tables, osproc, logging, times, nativesockets, strutils, rdstdin

import contra

import ../constants/constants, ../utils/configs, ../password/password, ../enums/enums
export head, navbar, footer, title  # HTML template fragments

when defined(postgres): import db_postgres
else:                   import db_sqlite


let nimwcpkgDir = getAppDir().replace("/nimwcpkg", "")
assert existsDir(nimwcpkgDir), "nimwcpkg directory not found"


template vacuumDb*(db: DbConn): bool = db.tryExec(sqlVacuum)


# Order is important here.
include
  "_connectdb",
  "_createdb",
  "_create_testuser",
  "_create_adminuser",
  "_create_standarddata",
  "_backupdb"
