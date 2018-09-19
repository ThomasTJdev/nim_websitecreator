# Copyright 2018 - Thomas T. Jarløv

import os, strutils, db_sqlite, rdstdin


const title = "Nim Website Creator"

const head* = """
<meta name="description" content="Nim Website Creator">
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1.0" />

<link rel="shortcut icon" href="/images/logo/favicon.ico">
<link rel="icon" type="image/png" href="/images/logo/favicon-16x16.png" sizes="16x16">
<link rel="icon" type="image/png" href="/images/logo/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="/images/logo/favicon-192x192.png" sizes="192x192">
<link rel="apple-touch-icon" sizes="180x180" href="/images/logo/favicon-180x180.png">

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
<link rel="stylesheet" href="/css/style.css">
<link rel="stylesheet" href="/css/style_custom.css">

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous" defer></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous" defer></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous" defer></script>
<script src="/js/js.js" defer></script>
<script src="/js/js_custom.js" defer></script>
"""

const navbar* = """
<nav id="navbar" class="navbar navbar-expand-md navbar-light">
  <div id="navbarInside">
    <a class="navbar-brand" href="/">
      <img src="/images/logo/NimWC_logo_blue.png" />
      <div>Nim Website Creator</div>
    </a>
    <div class="navbar-toggler mainMenu">
      <div class="baricon bar1"></div>
      <div class="baricon bar2"></div>
      <div class="baricon bar3"></div>
    </div>
    <div class="menu" id="mainMenu">
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
    <div class="menu" id="mobileMenu">
      <div class="navbar-toggler">
        <div class="baricon bar1"></div>
        <div class="baricon bar2"></div>
        <div class="baricon bar3"></div>
      </div>
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
<div id="aboutContainer">
  <div class="title reveal">
    <h1>Learn more about NimWC</h1>
    <h2>Get involved.</h2>
  </div>
  
  <div class="text1">
    <h2>Flexibility</h2>    
  	<div class="text1container">
      <div class="container-fluid">
        <div class="row">
          
        <div class="col-12 col-md-6">
            <div class="text1element">
              <h4>Customizable</h4>
              <p>
                NimWC is designed for users who have a little knowledge about HTML, CSS and JS.
                It is possible to customize the frontend code for all pages or for specific pages.
                This flexibility gives the user the power instead of given the power to the platform.
              </p>
            </div>
          </div>
          
          <div class="col-12 col-md-6">
            <div class="text1element">
              <h4>Wordpress</h4>
              <p>
                NimWC is not a replacement for Wordpress but an alternative.
                NimWC is a self-hosted solution with a minimum of requirements
                which also ensures, that there are fewer dependencies.
            </p></div>
          </div>
        </div>
          
        <div class="row">
        <div class="col-12 col-md-6">
            <div class="text1element">
              <h4>Self-hosting</h4>
              <p>
                By utilizing the powerful language Nim, NimWC is compiled to C code,
                which is runnable on almost all platforms. This further more makes it incredibly easy
                to host NimWC on e.g. Amazon or on a Raspberry Pi.
              </p>
            </div>
          </div>
          
          <div class="col-12 col-md-6">
            <div class="text1element">
              <h4>Open source</h4>
              <p>
                All of NimWC code is available to the public. Any Nim programmer can contribute with
                improvements and new features. The codebase is built upon modules, which makes it 
                easy to add new features and plugins.
              </p>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>
  
  <div class="spacer"></div>
</div>
"""

const frontpage = """
<div id="frontpageContainer">
  <div class="title">
    <h1 class="reveal">Nim Website Creator</h1>
    <h2 class="reveal">Websites on the fly</h2>
    <h2 class="reveal seemore">
      <a href="#start" class="jump">See more</a>
    </h2>
  </div>
  
  <div id="start" class="text2 reveal">
    <h2>NimWC is a new tool for<br>generating websites on the fly</h2>
  </div>
    
  <div class="text3">
  	<div class="container-fluid">
      <div class="row">
        
        <div class="col-12 col-md-4">
          <div class="text3element">
            <h4>One click install</h4>
            <p>Install with Nim's package manager Nimble or compile yourself. Just run the file, and your website is up and running.</p>
          </div>
        </div>
        
        <div class="col-12 col-md-4">
          <div class="text3element">
            <h4>Plugins</h4>
            <p>Install plugins within the browser, e.g. backup function, themes, etc. Easy development of new plugins.</p>
          </div>
        </div>
        
        <div class="col-12 col-md-4">
          <div class="text3element">
            <h4>Speed and security</h4>
            <p>NimWC is developed with the programming language Nim to ensure high speed and stability.</p>
          </div>
        </div>
    
      </div>
    </div>
  </div>
    
  <div class="text4">
    <h2>Installation</h2>    
  	<div class="text4container">
      <div class="container-fluid">
        <div class="row">
        <div class="col-12 col-md-6">
            <div class="text4element">
              <h4>Nimble</h4>
              <p style="margin-bottom: 0rem;"><label style="width: 70px;">Install:</label><kbd>nimble install nimwc</kbd></p>
              <p><label style="width: 70px;">Run:</label><kbd>nimwc</kbd></p>
            </div>
          </div>
          
          <div class="col-12 col-md-6">
            <div class="text4element">
              <h4>Compile</h4>
              <p style="margin-bottom: 0rem;"><label style="width: 70px;">Clone:</label><kbd>git clone https://git.io/f4AfL</kbd></p>
              <p><label style="width: 70px;">Compile:</label><kbd>nim c -r nimwc.nim</kbd></p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
      
  <div class="text5">
    <h2 class="sub1 reveal">NimWC is 100% free</h2>
    <h2 class="sub2 reveal">NimWC is 100% open source</h2>
  </div>
      
  <div class="text6">
    <h2>Next step</h2>    
  	<div class="text6container">
      <div class="container-fluid">
        <div class="row">
          <div class="col-12 col-md-6">
            <div class="text6element">
              <h4>Try NimWC</h4>
              <p style="margin-bottom: 0.3rem;">Try the test user without registration</p>
              <p>Go to <a href="/login">the login page</a> and login with the test user.</p>
            </div>
          </div>
          
          <div class="col-12 col-md-6">
            <div class="text6element">
              <h4>Learn more</h4>
              <p style="margin-bottom: 0.3rem;">You can visit the <a href="https://git.io/f4AfL">Github page</a> to see the code</p>
              <p>Checkout the features and see the examples on how to use NimWC</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
      
  <div class="spacer"></div>
  
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
        <div style="background: white; color: black; padding: 25px; border-radius: 10px;">
	      <h2 style="text-align: center;">UNO</h2>
        </div>
      </div>
      <div class="col-12 col-sm-6">
        <div style="background: white; color: black; padding: 25px; border-radius: 10px;">
	      <h2 style="text-align: center;">DUO</h2>
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
<style>
body [class*="para_"] {
  position: relative;
  height: 300px;
  background-attachment: fixed;
  background-position: top center;
  background-size: cover;
}
body [class*="para_"]:nth-child(2n) {
  box-shadow: inset 0 0 1em #111;
}
body .para {
  height: 100vh;
}
body .para_foo {
  background-image: url(/images/par1b.jpeg);
}
body .para_bar {
  background-image: url(/images/par2b.jpeg);
}
body .para_baz {
  background-image: url(/images/par3b.jpeg);
}

</style>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/css3-animate-it/1.0.3/css/animations.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/css3-animate-it/1.0.3/js/css3-animate-it.min.js" defer=""></script>
<div>
  <div class="para para_foo">
    <div class="animatedParent" style="padding-top: 150px;max-width: 200px;margin-left: auto;margin-right: auto;">
      <div class="animated bounceInRight go" style="background: black;color: white;padding: 20px;border-radius: 10px;text-align: center;">
        <h1>First parallax</h1>
      </div>
    </div>
  </div>
  <div class="para para_bar">
    <div class="animatedParent" data-appear-top-offset="-300" style="padding-top: 150px;max-width: 200px;margin-left: auto;margin-right: auto;">
      <div class="animated fadeInUp" style="background: white;color: black;padding: 20px;border-radius: 10px;text-align: center;">
        <h1>Second parallax</h1>
      </div>
    </div>
  </div>
  <div class="para para_baz">
    <div class="animatedParent" data-appear-top-offset="-300" style="padding-top: 150px;max-width: 200px;margin-left: auto;margin-right: auto;">
      <div class="animated growIn" style="background: rgb(88, 234, 94);color: rgb(165, 68, 236);padding: 20px;border-radius: 10px;text-align: center;">
        <h1>Third parallax</h1>
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

  discard insertID(db, sql"INSERT INTO blog (author_id, status, url, name, description, standardhead, standardnavbar, standardfooter) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", "1", "2", "standardpostv2", "Parallax post v2", blogpost2, "1", "1", "1")


proc createStandardData*(db: DbConn) =
  ## Insert basic data
  echo "Standard data: Inserting standard data"
  standardDataSettings(db)
  standardDataFrontpage(db)
  standardDataAbout(db)
  standardDataBlogpost1(db)
  standardDataBlogpost2(db)
  
  