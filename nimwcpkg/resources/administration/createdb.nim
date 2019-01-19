#        (c) Copyright 2017 Thomas Toftgaard Jarløv
#        All rights reserved.

import
  os, parsecfg, strutils, logging,
  ../administration/create_standarddata,
  ../utils/logging_nimwc

when defined(sqlite): import db_sqlite
else:                 import db_postgres


setCurrentDir(getAppDir().replace("/nimwcpkg", "") & "/")

const
  sql_now =
    when defined(sqlite): "(strftime('%s', 'now'))"     # SQLite 3 epoch.
    else:                 "(extract(epoch from now()))" # Postgres epoch.

  personTable = sql"""
    create table if not exists person(
      id         integer       primary key,
      name       varchar(60)   not null,
      password   varchar(300)  not null,
      email      varchar(254)  not null,
      creation   timestamp     not null           default $1,
      modified   timestamp     not null           default $1,
      salt       varchar(128)  not null,
      status     varchar(30)   not null,
      timezone   varchar(100),
      secretUrl  varchar(250),
      lastOnline timestamp     not null           default $1
    );""".format(sql_now)

  sessionTable = sql"""
    create table if not exists session(
      id           integer           primary key,
      ip           inet              not null,
      key          $#                not null,
      userid       integer           not null,
      lastModified timestamp         not null     default $1,
      foreign key (userid) references person(id)
    );""".format(sql_now)

  historyTable = sql"""
    create table if not exists history(
      id              integer        primary key,
      user_id         integer        not null,
      item_id         integer,
      element         varchar(100),
      choice          varchar(100),
      text            varchar(1000),
      creation        timestamp      not null     default $1
    );""".format(sql_now)

  settingsTable = sql"""
    create table if not exists settings(
      id              integer        primary key,
      analytics       text,
      head            text,
      footer          text,
      navbar          text,
      title           text,
      disabled        integer,
      blogorder       text,
      blogsort        text
    );"""

  pagesTable = sql"""
    create table if not exists pages(
      id              INTEGER        primary key,
      author_id       INTEGER        NOT NULL,
      status          INTEGER        NOT NULL,
      name            VARCHAR(200)   NOT NULL,
      url             VARCHAR(200)   NOT NULL     UNIQUE,
      title           TEXT,
      metadescription TEXT,
      metakeywords    TEXT,
      description     TEXT,
      head            TEXT,
      navbar          TEXT,
      footer          TEXT,
      standardhead    INTEGER,
      standardnavbar  INTEGER,
      standardfooter  INTEGER,
      tags            VARCHAR(1000),
      category        VARCHAR(1000),
      date_start      VARCHAR(100),
      date_end        VARCHAR(100),
      views           INTEGER,
      public          INTEGER,
      changes         INTEGER,
      modified        timestamp      not null     default $1,
      creation        timestamp      not null     default $1,
      foreign key (author_id) references person(id)
    );""".format(sql_now)

  blogTable = sql"""
    create table if not exists blog(
      id              INTEGER        primary key,
      author_id       INTEGER        NOT NULL,
      status          INTEGER        NOT NULL,
      name            VARCHAR(200)   NOT NULL,
      url             VARCHAR(200)   NOT NULL     UNIQUE,
      title           TEXT,
      metadescription TEXT,
      metakeywords    TEXT,
      description     TEXT,
      head            TEXT,
      navbar          TEXT,
      footer          TEXT,
      standardhead    INTEGER,
      standardnavbar  INTEGER,
      standardfooter  INTEGER,
      tags            VARCHAR(1000),
      category        VARCHAR(1000),
      date_start      VARCHAR(100),
      date_end        VARCHAR(100),
      views           INTEGER,
      public          INTEGER,
      changes         INTEGER,
      modified        timestamp      not null     default $1,
      creation        timestamp      not null     default $1,
      foreign key (author_id) references person(id)
    );
    """.format(sql_now)


proc generateDB*() =
  info("Database: Generating database")
  let
    dict = loadConfig("config/config.cfg")
    db_user = dict.getSectionValue("Database", "user")
    db_pass = dict.getSectionValue("Database", "pass")
    db_name = dict.getSectionValue("Database", "name")
    db_host = dict.getSectionValue("Database", "host")
    db_folder = dict.getSectionValue("Database", "folder")
    dbexists =
      when defined(sqlite): fileExists(db_host)
      else:                 db_host.len > 1

  if dbexists:
    info("Database: Database already exists. Inserting standard tables if they do not exist.")

  discard existsOrCreateDir(db_folder)  # Creating folder

  info("Database: Opening database")  # Open DB
  var db = open(connection=db_host, user=db_user, password=db_pass, database=db_name)

  if not db.tryExec(personTable):
    info("Database: person table already exists")

  # Session
  if not db.tryExec(sessionTable):
    info("Database: session table already exists")

  # History
  if not db.tryExec(historyTable):
    info("Database: history table already exists")

  # Settings
  if not db.tryExec(settingsTable):
    info("Database: settings table already exists")

  # Pages
  if not db.tryExec(pagesTable):
    info("Database: pages table already exists")

  # Blog
  if not db.tryExec(blogTable):
    info("Database: blog table already exists")

  if not dbexists:
    info("Database: Inserting standard elements")
    createStandardData(db)

  info("Database: Closing database")
  close(db)
