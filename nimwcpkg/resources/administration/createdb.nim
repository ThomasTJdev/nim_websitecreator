#
#
#        Hubanize / Cx Manager
#        (c) Copyright 2017 Thomas Toftgaard Jarløv
#        All rights reserved.
#
#

import db_sqlite, os, parsecfg, strutils

import ../administration/create_standarddata

setCurrentDir(getAppDir().replace("/nimwcpkg", "") & "/")

proc generateDB*() =
  echo "Generating database"
  let dict = loadConfig("config/config.cfg")
  let db_user = dict.getSectionValue("Database","user")
  let db_pass = dict.getSectionValue("Database","pass")
  let db_name = dict.getSectionValue("Database","name")
  let db_host = dict.getSectionValue("Database","host")
  let db_folder = dict.getSectionValue("Database","folder")

  let dbexists = if fileExists(db_host): true else: false

  if dbexists:
    echo " - Database already exists. Inserting standard tables if they do not exist."
  
  # Creating folder
  discard existsOrCreateDir(db_folder)  

  # Open DB
  echo " - Opening database"
  var db = open(connection=db_host, user=db_user, password=db_pass, database=db_name)


  const
    TUserName = "varchar(20)"
    TPassword = "varchar(32)"
    TEmail = "varchar(30)"


  if not db.tryExec(sql("""
  create table if not exists person(
    id integer primary key,
    name varchar(60) not null,
    password varchar(300) not null,
    email varchar(60) not null,
    creation timestamp not null default (STRFTIME('%s', 'now')),
    modified timestamp not null default (STRFTIME('%s', 'now')),
    salt varbin(128) not null,
    status varchar(30) not null,
    timezone VARCHAR(100),
    secretUrl VARCHAR(250),
    lastOnline timestamp not null default (STRFTIME('%s', 'now'))
  );""" % [TUserName, TPassword, TEmail]), []):
    echo " - Database: person table already exists"




  # -------------------- Session -------------------------------------------------

  if not db.tryExec(sql("""
  create table if not exists session(
    id integer primary key,
    ip inet not null,
    key $# not null,
    userid integer not null,
    lastModified timestamp not null default (STRFTIME('%s', 'now')),
    foreign key (userid) references person(id)
  );""" % [TPassword]), []):
    echo " - Database: session table already exists"



  # ----------------------- History -----------------------------------

  if not db.tryExec(sql"""
  create table if not exists history(
    id INTEGER primary key,
    user_id INTEGER NOT NULL,
    item_id INTEGER,
    element VARCHAR(100),
    choice VARCHAR(100),
    text VARCHAR(1000),
    creation timestamp not null default (STRFTIME('%s', 'now'))
  );""", []):
    echo " - Database: history table already exists"



  # ----------------------- Settings -----------------------------------

  if not db.tryExec(sql"""
  create table if not exists settings(
    id INTEGER primary key,
    analytics TEXT,
    head TEXT,
    footer TEXT,
    navbar TEXT,
    title TEXT,
    disabled INTEGER
  );""", []):
    echo " - Database: settings table already exists"

  # ----------------------- Pages ----------------------------------------------

  if not db.tryExec(sql"""
  create table if not exists pages(
    id INTEGER primary key,
    author_id INTEGER NOT NULL,
    status INTEGER NOT NULL,
    name VARCHAR(200) NOT NULL,
    url VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    head TEXT,
    navbar TEXT,
    footer TEXT,
    standardhead INTEGER,
    standardnavbar INTEGER,
    standardfooter INTEGER,
    tags VARCHAR(1000),
    category VARCHAR(1000),
    date_start VARCHAR(100) ,
    date_end VARCHAR(100) ,
    views INTEGER,
    public INTEGER,
    changes INTEGER,
    modified timestamp not null default (STRFTIME('%s', 'now')),
    creation timestamp not null default (STRFTIME('%s', 'now')),

    foreign key (author_id) references person(id)
  );""", []):
    echo " - Database: pages table already exists"



  # ----------------------- Blog ----------------------------------------------

  if not db.tryExec(sql"""
  create table if not exists blog(
    id INTEGER primary key,
    author_id INTEGER NOT NULL,
    status INTEGER NOT NULL,
    name VARCHAR(200) NOT NULL,
    url VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    head TEXT,
    navbar TEXT,
    footer TEXT,
    standardhead INTEGER,
    standardnavbar INTEGER,
    standardfooter INTEGER,
    tags VARCHAR(1000),
    category VARCHAR(1000),
    date_start VARCHAR(100) ,
    date_end VARCHAR(100) ,
    views INTEGER,
    public INTEGER,
    changes INTEGER,
    modified timestamp not null default (STRFTIME('%s', 'now')),
    creation timestamp not null default (STRFTIME('%s', 'now')),

    foreign key (author_id) references person(id)
  );""", []):
    echo " - Database:blog table already exists"


  if not dbexists:
    echo "Inserting standard elements"
    createStandardData(db)

  echo " - Database: Closing database"
  close(db)

