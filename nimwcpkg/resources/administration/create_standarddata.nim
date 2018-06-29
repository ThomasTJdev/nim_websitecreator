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
<nav id="navbar" class="navbar navbar-expand-md navbar-dark">
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
<style>
body .para {
  height: 100vh;
}
</style>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/css3-animate-it/1.0.3/css/animations.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/css3-animate-it/1.0.3/js/css3-animate-it.min.js" defer=""></script>
<div>
  <div class="para para_foo" style="background-image: url(/images/par1b.jpeg)">
    <div class="animatedParent" style="padding-top: 150px;max-width: 200px;margin-left: auto;margin-right: auto;">
      <div class="animated bounceInRight go" style="background: black;color: white;padding: 20px;border-radius: 10px;text-align: center;">
        <h1>What</h1>
        <p>A small and quick website creator.</p>
      </div>
    </div>
  </div>
  <div class="para para_bar" style="background-image: url(/images/par2b.jpeg)">
    <div class="animatedParent" data-appear-top-offset="-300" style="padding-top: 150px;max-width: 200px;margin-left: auto;margin-right: auto;">
      <div class="animated fadeInUp" style="background: white;color: black;padding: 20px;border-radius: 10px;text-align: center;">
        <h1>Why</h1>
        <p>Quick setup of a website with custom configuration</p><p>
      </p></div>
    </div>
  </div>
  <div class="para para_baz" style="background-image: url(/images/par3b.jpeg)">
    <div class="animatedParent" data-appear-top-offset="-300" style="padding-top: 150px;max-width: 200px;margin-left: auto;margin-right: auto;">
      <div class="animated growIn" style="background: rgb(88, 234, 94);color: rgb(165, 68, 236);padding: 20px;border-radius: 10px;text-align: center;">
        <h1>How</h1>
        <p>Clone the GIT repo and you're ready to go!</p>
      </div>
    </div>
  </div>
</div>
"""

const frontpage = """
<style>
body .para {
  height: 70vh;
}
.para>div {
  padding-top:150px;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}
@media only screen and (max-width: 768px) {
 .para>div {
    padding-top: 50px;
  }
}
</style>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/css3-animate-it/1.0.3/css/animations.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/css3-animate-it/1.0.3/js/css3-animate-it.min.js" defer=""></script>
<div>
  <div class="para para_foo" style="background-image: url(/images/par1a.jpeg);">
    <div class="animatedParent animateOnce">
      <div class="animated bounceInRight go" style="background: white;color: black;border: 1px solid grey;padding: 20px;border-radius: 10px;text-align: center;">
        <h1 style="text-align: center; ">Nim Website Creator</h1>
		<br>
        <h4 style="text-align: center;">Website in 5 minutes</h4>
		<p style="text-align: center;">A quick tool to setup a website in no time. Run the program and POW - the website is ready!</p>
      </div>
    </div>
  </div>
  <div class="para para_bar" style="background-image: url(/images/par2a.jpeg);">
    <div class="animatedParent animateOnce" data-appear-top-offset="-150">
      <div class="animated fadeInUp" style="background: white;color: black;border: 1px solid grey;padding: 20px;border-radius: 10px;text-align: center;">
        <h2>From beginner to expert</h2>
        <p style="text-align: center;">All the pages can be edited without any HTML (programming) knowledge. Advanced users can edit the header, navbar, footer etc.</p>
        <br>
        <h2>Plugins</h2>
        <p style="text-align: center;">Multiple plugins are available: Schedule mails to all users, backup the database continuously, change themes and more.</p><p>
      </p></div>
    </div>
  </div>
  <div class="para para_baz" style="background-image: url(/images/par3a.jpeg);">
    <div class="animatedParent animateOnce" data-appear-top-offset="-150">
      <div class="animated growIn" style="background: black;color: white;padding: 20px;border-radius: 10px;text-align: center;">
        <h2>Get started</h2>
        <p style="text-align: center;">Visit the <a href="https://github.com/ThomasTJdev/nim_websitecreator">Github page</a>&nbsp;for installation instructions or try the <a href="https://nimwc.org/login">test user</a>.</p>
        <br>
        <h2>Customize it</h2>
        <p style="text-align: center;">Nim Website Creator is programmed with Nim-lang. Visit the Github page to learn more.</p>  
      </div>
    </div>
  </div>
</div>
"""


const blogpost1 = """
<div style="background: white; color: black; padding: 20px; max-width: 1200px; padding: 20px; border-radius: 10px; margin-left: auto; margin-right: auto; margin-top: 100px;">
 <h1>Standard blog</h1>
  <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p><p><br></p>
  
 <div>
  <p>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?<br></p>
 </div>
</div>
  
<div style="height: 50px; background: transparent;"></div>
  
<div class="container-fluid" style="max-width: 1200px;">
  <div class="row">
    <div class="col-12 col-sm-6">
      <div style="background: white; color: black; padding: 25px; border-radius: 10px; margin-bottom: 20px;">
      <h2 style="text-align: center;">UNO</h2>
      </div>
    </div>
    <div class="col-12 col-sm-6">
      <div style="background: white; color: black; padding: 25px; border-radius: 10px; margin-bottom: 20px;">
      <h2 style="text-align: center;">DOS</h2>
      </div>
    </div>
  </div>
</div>
  
<div style="height: 50px; background: transparent;"></div>
  
<div style="background: white; color: black; padding: 20px; max-width: 1200px; padding: 20px; border-radius: 10px; margin-left: auto; margin-right: auto; margin-bottom: 150px; text-align: right;">
  <h1 style="text-align: right;">Standard blog</h1>
  <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p><p><br></p>
  
  <div>
    <p>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?<br></p>
  </div>
</div>
"""

const blogpost2 = """
<h1 style="color: white; text-align: center;">Blog post</h1>
<div class="container-fluid" style="max-width: 1200px; padding-top: 20px;">
  <div class="row">
    <div class="col-12 col-sm-4">
      <div style="background: white; color: black; padding: 25px; border-radius: 10px; margin-bottom: 20px;">
      <h2 style="text-align: center;">UNO</h2>
        <p>
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        </p>
      </div>
    </div>
    <div class="col-12 col-sm-4">
      <div style="background: white; color: black; padding: 25px; border-radius: 10px; text-align: center; margin-bottom: 20px;">
      <h2 style="text-align: center;">DOS</h2>
        <img src="/images/avatar.jpg">
      </div>
    </div>
    <div class="col-12 col-sm-4">
      <div style="background: white; color: black; padding: 25px; border-radius: 10px; margin-bottom: 20px;">
      <h2 style="text-align: center;">TRES</h2>
        <p>
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        </p>
      </div>
    </div>
  </div>
</div>  
"""

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
    exec(db, sql"DELETE FROM pages WHERE id = ?", frontpageExists)

  discard insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "frontpage", "Frontpage", frontpage, "1", "1", "1")


proc standardDataAbout*(db: DbConn) =
  # About
  echo " - Standard data: Inserting about-data"
  let aboutExists = getValue(db, sql"SELECT id FROM pages WHERE url = ?", "about")
  if aboutExists != "":
    exec(db, sql"DELETE FROM pages WHERE id = ?", aboutExists)

  discard insertID(db, sql"INSERT INTO pages (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "about", "About", about, "1", "1", "1")


proc standardDataBlogpost1*(db: DbConn) =
  # Blog post
  echo " - Standard data: Inserting blog post-data"
  let blogExists = getValue(db, sql"SELECT id FROM blog WHERE url = ?", "standardpost")
  if blogExists != "":
    exec(db, sql"DELETE FROM blog WHERE id = ?", blogExists)

  discard insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "standardpost", "Standard post", blogpost1, "1", "1", "1")

proc standardDataBlogpost2*(db: DbConn) =
  # Blog post
  echo " - Standard data: Inserting blog post-data"
  let blogExists = getValue(db, sql"SELECT id FROM blog WHERE url = ?", "standardpostv2")
  if blogExists != "":
    exec(db, sql"DELETE FROM blog WHERE id = ?", blogExists)

  discard insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "standardpostv2", "Standard post v2", blogpost2, "1", "1", "1")


proc createStandardData*(db: DbConn) =
  ## Insert basic data
  echo "Standard data: Inserting standard data"
  standardDataSettings(db)
  standardDataFrontpage(db)
  standardDataAbout(db)
  standardDataBlogpost1(db)
  standardDataBlogpost2(db)
  
  