# Copyright 2018 - Thomas T. Jarløv

import os, strutils, db_sqlite, rdstdin


const title = "Nim Website Creator"

const head* = """
<meta name="description" content="Nim Website Creator">
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1.0" />

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
<link rel="stylesheet" href="/css/style.css">

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous" defer></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous" defer></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous" defer></script>
<script src="/js/js.js" defer></script>
"""

const navbar* = """
<nav id="navbar" class="navbar navbar-expand-md navbar-light">
  <div id="navbarInside">
    <a class="navbar-brand" href="/">Nim Website Creator</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#collapsibleNavbar">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="collapsibleNavbar">
      <ul class="navbar-nav">
        <li class="nav-item">
          <a class="nav-link" href="/">Frontpage</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="/blog">Blog</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="/p/about">About</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
"""


const footer* = """
<div id="footerInside">
  <div class="container-fluid">
    <div class="row">
      <div class="col-12 col-md-3 footerLeft">
        <h5>
          Copyright
        </h5>
        <p>
          <p>&#169; 2018 - <a href="https://ttj.dk"><u>Thomas T. Jarløv</u></a></p>
        </p>
      </div>
      <div class="col-12 col-md-6 footerMiddle">
      </div>
      <div class="col-12 col-md-3 footerRight">
        <h5>
          Nim Website Creator
        </h5>
        <p>
          <p>License: GPLv3 - <a href="https://github.com/ThomasTJdev/nim_websitecreator"><u>Github</u></a></p>
        </p>
      </div>
    </div>
  </div>
</div>
"""


const about = """
<h4 class="text-center">
  Nim Website Creator
</h4>
<div class="container-fluid" style="text-align: center;">
  <div class="row">
    <div class="col-3 col-md-3">
    </div>
    <div class="col-6 col-md-6">
    <dl>
      <dt>
        What
      </dt>
      <dd>
        A small and quick website creator.
      </dd>
      <dt>
        Why
      </dt>
      <dd>
        Quick setup of a website with custom configuration
      </dd>
      <dt>
        How
      </dt>
      <dd>
        Clone the GIT repo and you're ready to go!
      </dd>
    </dl>
    </div>
    <div class="col-3 col-md-3">
    </div>
  </div>
</div>
"""

const frontpage = """<h1 style="text-align: center; ">Welcome to</h1>
<h3 style="text-align: center;">Nim Website Creator</h3>
<p style="text-align: center;"><br></p>
<p style="text-align: center;">A quick tool to setup a website in no time.</p>
<p style="text-align: center;">Visit the <a href="https://github.com/ThomasTJdev/nim_websitecreator">Github page</a>&nbsp;for installation instructions or try to <a href="https://nimwc.org/login">login</a>.</p>"""


proc standardDataSettings*(db: DbConn) =
  # Settings
  echo " - Standard data: Inserting settings-data"
  let settingsExists = getValue(db, sql"SELECT id FROM settings WHERE id = ?", "1")
  if settingsExists != "":
    exec(db, sql"DELETE FROM settings WHERE id = ?", "1")

  discard insertID(db, sql"INSERT INTO settings (title, head, navbar, footer) VALUES (?, ?, ?, ?)", title, head, navbar, footer)


proc standardDataFrontpage*(db: DbConn) =
  # Frontpage
  echo " - Standard data: Inserting frontpage-data"
  let frontpageExists = getValue(db, sql"SELECT id FROM pages WHERE url = ?", "frontpage")
  if frontpageExists != "":
    exec(db, sql"DELETE FROM pages WHERE url = ?", "frontpage")

  discard insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "frontpage", "Frontpage", frontpage, "1", "1", "1")


proc standardDataAbout*(db: DbConn) =
  # About
  echo " - Standard data: Inserting about-data"
  let aboutExists = getValue(db, sql"SELECT id FROM pages WHERE url = ?", "about")
  if aboutExists != "":
    exec(db, sql"DELETE FROM pages WHERE url = ?", "about")

  discard insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "about", "About", about, "1", "1", "1")


proc createStandardData*(db: DbConn) =
  ## Insert basic data
  echo "Standard data: Inserting standard data"
  standardDataSettings(db)
  standardDataFrontpage(db)
  standardDataAbout(db)
  
  