# Copyright 2018 - Thomas T. Jarløv

import
  asyncdispatch,
  asyncnet,
  db_sqlite,
  os,
  osproc,
  strutils,
  times,
  uri


import ../../src/resources/email/email_registration
import ../../src/resources/password/password_generate
import ../../src/resources/password/salt_generate
import ../../src/resources/session/user_data
import ../../src/resources/utils/dates
import ../../src/resources/utils/logging
import ../../src/resources/utils/random_generator
import ../../src/resources/web/google_recaptcha


const pluginTitle       = "Backup"
const pluginAuthor      = "Thomas T. Jarløv"
const pluginVersion     = "0.1"
const pluginVersionDate = "2018-05-20"


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


var runBackup* = true


proc backupNow*(): bool =
  let dateName = epochDate($toInt(epochTime()), "YYYY_MM_DD-HH_mm")
  let execOutput = execCmd("cp data/website.db data/website_" & dateName & ".db")
  if execOutput != 0:
    dbg("ERROR", "Backup plugin: Error while backing up data/website_" & dateName & ".db")
    return false
  return true


proc cronBackup*(db: DbConn) {.async.} =
  ## Cron backup run
  ## runBackup needs to be true to run
  

  while runBackup:
    let backupmodified = getValue(db, sql"SELECT modified FROM backup WHERE id = ?", "1")
    let backuptime = getValue(db, sql"SELECT backuptime FROM backup WHERE id = ?", "1")

    if backuptime == "" or backuptime == "0":
      runBackup = false
      dbg("DEBUG", "Backup plugin: No backuptime specified. Quitting loop.")

    else:
      when defined(dev):
        dbg("DEBUG", "Backup plugin: Waiting time between cron mails is 15 minute")
        dbg("DEBUG", "Backup plugin: Real waiting time is: " & backuptime & " hours")
        await sleepAsync(60 * 15 * 1000) # 15 minutes
        
      when not defined(dev):
        echo "Backup plugin: Waiting " & $(parseInt(backuptime) * 60 * 60) & " seconds before next backup"
        await sleepAsync((parseInt(backuptime) * 60 * 60) * 1000)
      
      let backupmodifiedCheck = getValue(db, sql"SELECT modified FROM backup WHERE id = ?", "1")
      if backupmodified != backupmodifiedCheck:
        break

      discard backupNow()
      


proc backupStart*(db: DbConn) =
  ## Required proc. Will run on each program start
  ##
  ## If there's no need for this proc, just
  ## discard it. The proc may not be removed.

  dbg("INFO", "Backup plugin: Updating database with Backup table if not exists")
  
  if not db.tryExec(sql"""
  create table if not exists backup(
    id INTEGER primary key,
    backuptime INTEGER NOT NULL,
    modified timestamp not null default (STRFTIME('%s', 'now')),
    creation timestamp not null default (STRFTIME('%s', 'now'))
  );""", []):
    dbg("INFO", "Backup plugin: Backup table created in database")

  if getAllRows(db, sql"SELECT id FROM backup").len() == 0:
    exec(db, sql"INSERT INTO backup (backuptime) VALUES (?)", "0")

  asyncCheck cronBackup(db)