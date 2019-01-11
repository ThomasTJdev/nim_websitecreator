#
#
#        Hubanize / Cx Manager
#        (c) Copyright 2017 Thomas Toftgaard Jarløv
#        All rights reserved.
#
#

import
  db_postgres, os, parsecfg, strutils,
  ../administration/create_standarddata

setCurrentDir(getAppDir().replace("/nimwcpkg", "") & "/")

const
  personTable = sql"""
    create table if not exists person(
      id         integer       primary key,
      name       varchar(60)   not null,
      password   varchar(300)  not null,
      email      varchar(60)   not null,
      creation   timestamp     not null           default NOW(),
      modified   timestamp     not null           default NOW(),
      salt       varchar(128)  not null,
      status     varchar(30)   not null,
      timezone   varchar(100),
      secretUrl  varchar(250),
      lastOnline timestamp     not null           default NOW()
    );"""

  sessionTable = sql"""
    create table if not exists session(
      id           integer           primary key,
      ip           inet              not null,
      key          $#                not null,
      userid       integer           not null,
      lastModified timestamp         not null     default NOW(),
      foreign key (userid) references person(id)
    );"""

  historyTable = sql"""
    create table if not exists history(
      id              integer        primary key,
      user_id         integer        not null,
      item_id         integer,
      element         varchar(100),
      choice          varchar(100),
      text            varchar(1000),
      creation        timestamp      not null     default NOW()
    );"""

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
      modified        timestamp      not null     default NOW(),
      creation        timestamp      not null     default NOW(),
      foreign key (author_id) references person(id)
    );"""

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
      modified        timestamp      not null     default (STRFTIME('%s', 'now')),
      creation        timestamp      not null     default (STRFTIME('%s', 'now')),
      foreign key (author_id) references person(id)
    );
    """


proc generateDB*() =
  echo "Generating database"
  let
    dict = loadConfig("config/config.cfg")
    db_user = dict.getSectionValue("Database","user")
    db_pass = dict.getSectionValue("Database","pass")
    db_name = dict.getSectionValue("Database","name")
    db_host = dict.getSectionValue("Database","host")
    db_folder = dict.getSectionValue("Database","folder")
    dbexists = if fileExists(db_host): true else: false

  if dbexists:
    echo " - Database already exists. Inserting standard tables if they do not exist."

  discard existsOrCreateDir(db_folder)  # Creating folder

  echo " - Opening database"  # Open DB
  var db = db_postgres.open(connection=db_host, user=db_user, password=db_pass, database=db_name)

  if not db.tryExec(personTable):
    echo " - Database: person table already exists"

  # Session
  if not db.tryExec(sessionTable):
    echo " - Database: session table already exists"

  # History
  if not db.tryExec(historyTable):
    echo " - Database: history table already exists"

  # Settings
  if not db.tryExec(settingsTable):
    echo " - Database: settings table already exists"

  # Pages
  if not db.tryExec(pagesTable):
    echo " - Database: pages table already exists"

  # Blog
  if not db.tryExec(blogTable):
    echo " - Database:blog table already exists"

  if not dbexists:
    echo "Inserting standard elements"
    createStandardData(db)

  echo " - Database: Closing database"
  close(db)
