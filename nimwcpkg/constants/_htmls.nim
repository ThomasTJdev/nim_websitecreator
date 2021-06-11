## Static string HTML constants, do NOT put any run-time logic here, only consts.
## Do NOT import this file directly, instead import ``constants.nim``
import strutils, ../webs/html_utils

const
  inputNumber* = r"""
    <input type="tel" value="$1" name="$2" class="$3" id="$4" placeholder="$5" title="$5"
    $6 min="$7" max="$8" maxlength="$9" step="1" pattern="\d*" autocomplete="off" dir="auto">
  """

  inputFile* = r"""
    <input type="file" name="$1" class="$2" id="$3" title="$5" accept="$5" $4
    onChange="if(!this.value.toLowerCase().match(/(.*?)\.($6)$$/)){alert('Invalid File Format. ($5)');this.value='';return false}">
  """

  imageLazy* = r"""
    <img class="$5" id="$2" alt="$6" data-src="$1" src="" lazyload="on" onclick="this.src=this.dataset.src" onmouseover="this.src=this.dataset.src" width="$3" heigth="$4"/>
    <script>
      const i = document.querySelector("img#$2");
      window.addEventListener('scroll',()=>{if(i.offsetTop<window.innerHeight+window.pageYOffset+99){i.src=i.dataset.src}});
      window.addEventListener('resize',()=>{if(i.offsetTop<window.innerHeight+window.pageYOffset+99){i.src=i.dataset.src}});
    </script>
  """

  head* = """<meta charset="utf-8">
<meta name="generator" content="Nim Website Creator">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="author" href="humans.txt">
<link rel="shortcut icon" href="/favicon.ico">
<link rel="icon" type="image/png" href="/images/logo/favicon-16x16.png" sizes="16x16">
<link rel="icon" type="image/png" href="/images/logo/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="/images/logo/favicon-192x192.png" sizes="192x192">
<link rel="apple-touch-icon" sizes="180x180" href="/images/logo/favicon-180x180.png">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.2/css/bulma.min.css" integrity="sha512-byErQdWdTqREz6DLAA9pCnLbdoGGhXfU6gm1c8bkf7F51JVmUBlayGe2A31VpXWQP+eiJ3ilTAZHCR3vmMyybA==" crossorigin="anonymous" />
<link rel="stylesheet" href="/css/style.css">
<link rel="stylesheet" href="/css/style_custom.css">
<script src="/js/js.js" crossorigin="anonymous" defer></script>
<script src="/js/js_custom.js" crossorigin="anonymous" defer></script>"""


  headOfficial* = """<meta charset="utf-8">
<meta name="generator" content="Nim Website Creator">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="author" href="humans.txt">
<link rel="shortcut icon" href="/favicon.ico">
<link rel="icon" type="image/png" href="/images/logo/favicon-16x16.png" sizes="16x16">
<link rel="icon" type="image/png" href="/images/logo/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="/images/logo/favicon-192x192.png" sizes="192x192">
<link rel="apple-touch-icon" sizes="180x180" href="/images/logo/favicon-180x180.png">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.2/css/bulma.min.css" integrity="sha512-byErQdWdTqREz6DLAA9pCnLbdoGGhXfU6gm1c8bkf7F51JVmUBlayGe2A31VpXWQP+eiJ3ilTAZHCR3vmMyybA==" crossorigin="anonymous" />
<link href="https://fonts.googleapis.com/css?family=Heebo:400,500,700|Playfair+Display:700" rel="stylesheet">
<script src="https://unpkg.com/scrollreveal@4.0.0/dist/scrollreveal.min.js"></script>
<link rel="stylesheet" href="/css/style.css">
<link rel="stylesheet" href="/css/style_custom.css">
<script src="/js/js.js" crossorigin="anonymous" defer></script>
<script src="/js/js_custom.js" crossorigin="anonymous" defer></script>"""


  headClean* = """<meta charset="utf-8">
<meta name="generator" content="Nim Website Creator">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="author" href="humans.txt">
<link rel="shortcut icon" href="/favicon.ico">
<link rel="icon" type="image/png" href="/images/logo/favicon-16x16.png" sizes="16x16">
<link rel="icon" type="image/png" href="/images/logo/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="/images/logo/favicon-192x192.png" sizes="192x192">
<link rel="apple-touch-icon" sizes="180x180" href="/images/logo/favicon-180x180.png">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/kognise/water.css@latest/dist/light.min.css"> <!-- Delete this line to remove Water CSS -->
<link rel="stylesheet" href="/css/style_custom.css">
<script src="/js/js_custom.js" crossorigin="anonymous" defer></script>"""


  headBootstrap* = """<meta charset="utf-8" name="viewport" content="width=device-width, initial-scale=1.0" />
<link rel="author" href="humans.txt">
<link rel="shortcut icon" href="/images/logo/favicon.ico">
<link rel="icon" type="image/png" href="/images/logo/favicon-16x16.png" sizes="16x16">
<link rel="icon" type="image/png" href="/images/logo/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="/images/logo/favicon-192x192.png" sizes="192x192">
<link rel="apple-touch-icon" sizes="180x180" href="/images/logo/favicon-180x180.png">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha256-L/W5Wfqfa0sdBNIKN9cG6QA5F2qx4qICmU2VgLruv9Y=" crossorigin="anonymous" />
<link rel="stylesheet" href="/css/style.css">
<link rel="stylesheet" href="/css/style_custom.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous" defer></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js" integrity="sha256-x3YZWtRjM8bJqf48dFAv/qmgL68SI4jqNWeSLMZaMGA=" crossorigin="anonymous" defer></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha256-WqU1JavFxSAMcLP2WIOI+GB2zWmShMI82mTpLDcqFUg=" crossorigin="anonymous" defer></script>
<script src="/js/js.js" crossorigin="anonymous" defer></script>
<script src="/js/js_custom.js" crossorigin="anonymous" defer></script>"""


  navbar* = """<nav class="navbar is-transparent is-fixed-top" role="navigation" aria-label="main navigation">
  <div class="navbar-brand">
    <a class="navbar-item logo" href="/">
      <img src="/images/logo/NimWC_logo_blue.png" title="Nim Website Creator" />
    </a>
    <a role="button" class="navbar-burger burger" aria-label="menu" aria-expanded="false" data-target="navbarMain">
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
    </a>
  </div>
  <div id="navbarMain" class="navbar-menu">
    <div class="navbar-start">
      <hr class="navbar-divider">
      <a class="nav-link navbar-item is-hoverable" href="/">Home</a>
      <hr class="navbar-divider">
      <a class="nav-link navbar-item is-hoverable" href="/blog">Blog</a>
      <hr class="navbar-divider">
      <a class="nav-link navbar-item is-hoverable" href="/p/about">About</a>
      <hr class="navbar-divider">
      <a class="nav-link navbar-item is-hoverable is-hidden-tablet" href="/login">Login</a>
      <hr class="navbar-divider is-hidden-tablet">
    </div>
    <div class="navbar-end is-hidden-mobile">
      <div class="navbar-item">
        <div class="buttons">
          <a class="button is-small is-outlined" href="/login">Login</a>
        </div>
      </div>
    </div>
  </div>
</nav>"""


  navbarClean* = """<nav>
  <a href="/">Home</a>
  <a href="/blog">Blog</a>
  <a href="/login">Login</a>
</nav>"""


  navbarBootstrap* = """<nav id="navbar" class="navbar navbar-expand-md navbar-light">
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
    <div class="menu hidden" id="mobileMenu">
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
        <li class="nav-item">
          <a class="nav-link" href="/login">Login</a>
        </li>
      </ul>
    </div>
  </div>
</nav>"""


  navbarOfficial* = """<nav class="navbar is-transparent is-fixed-top is-hidden-mobile" role="navigation" aria-label="main navigation">
  <div class="navbar-brand">
    <a class="navbar-item logo" href="/">
      <img src="/images/logo/NimWC_logo_blue.png" title="Nim Website Creator" />
    </a>
    <a role="button" class="navbar-burger burger" aria-label="menu" aria-expanded="false" data-target="navbarMain">
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
    </a>
  </div>
  <div id="navbarMain" class="navbar-menu">
    <div class="navbar-start">
      <hr class="navbar-divider">
      <a class="nav-link navbar-item is-hoverable" href="/">Home</a>
      <hr class="navbar-divider">
      <a class="nav-link navbar-item is-hoverable" href="/blog">Blog</a>
      <hr class="navbar-divider">
      <a class="nav-link navbar-item is-hoverable is-hidden-tablet" href="/login">Login</a>
      <hr class="navbar-divider is-hidden-tablet">
    </div>
    <div class="navbar-end is-hidden-mobile">
      <div class="navbar-item">
        <div class="buttons">
          <a class="button is-small is-outlined" href="/login">Login</a>
        </div>
      </div>
    </div>
  </div>
</nav>"""

  footerClean* = minifyHtml"""

    <footer>
      <center> &#169; 2019 </center>
    </footer>

  """


  footer* = """<div class="container" class="footer is-light">
  <div class="columns">
    <div class="column is-4 has-text-centered is-hidden-tablet"><a class="title is-4" href="/">Nim Website Creator</a></div>
    <div class="column is-4">
      <div class="level"><p>2019 - <a href="https://ttj.dk"><u>Thomas T. Jarløv</u></a> & <a href="https://github.com/juancarlospaco"><u>Juan Carlos</u></a></p></div>
    </div>
    <div class="column is-4 has-text-centered is-hidden-mobile"><a class="title is-4" href="/">Nim Website Creator</a></div>
    <div class="column is-4 has-text-right">
      <div class="level"><a class="level-item" href="https://nim-lang.org">Powered by Nim</a></div>
    </div>
  </div>
  <span class="subtitle has-text-centered is-6">&copy; PPL - <a href="https://github.com/ThomasTJdev/nim_websitecreator"><u>Github</u></a></span>
</div>"""

  about* = """<div id="about">
  <div class="title reveal reveal-bottom">
    <h1>Learn more about NimWC
    </h1>
    <h2>Get involved.
    </h2>
  </div>
  <div class="text1">
    <h2>Flexibility
    </h2>
    <div class="text1container">
      <div class="container-fluid">
        <div class="columns row">
          <div class="column col-12 col-md-6">
            <div class="text1element">
              <h4>Customizable
              </h4>
              <p>
                NimWC is designed for users who have a little knowledge about HTML, CSS and JS.
                It is possible to customize the frontend code for all pages or for specific pages.
                This flexibility gives the user the power instead of given the power to the platform.
              </p>
            </div>
          </div>
          <div class="column col-12 col-md-6">
            <div class="text1element">
              <h4>Wordpress
              </h4>
              <p>
                NimWC is not a replacement for Wordpress but an alternative.
                NimWC is a self-hosted solution with a minimum of requirements
                which also ensures, that there are fewer dependencies.
              </p>
            </div>
          </div>
        </div>
        <div class="columns row">
          <div class="column col-12 col-md-6">
            <div class="text1element">
              <h4>Self-hosting
              </h4>
              <p>
                By utilizing the powerful language Nim, NimWC is compiled to C code,
                which is runnable on almost all platforms. This further more makes it incredibly easy
                to host NimWC on e.g. Amazon or on a Raspberry Pi.
              </p>
            </div>
          </div>
          <div class="column col-12 col-md-6">
            <div class="text1element">
              <h4>Open source
              </h4>
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
  <div class="spacer">
  </div>
</div>"""


  frontpageClean* = """<style> #background{ background-image: none !important } </style>
<div id="frontpage">
  <div>
    <h1>Nim Website Creator</h1>
    <h2>Open-source website framework</h2>
    <h2>
      <a href="#start">Get started today!</a>
    </h2>
  </div>
  <div id="start">
    <h2>NimWC is a new tool for<br>
    generating websites on the fly</h2>
    <div>
      <ul>
        <li>Explore the dashboard with access to the plugin store</li>
        <li>Admin configuration of the backend from the browser</li>
        <li>Custom profiles with Libravatar/Gravatar</li>
        <li>SEO optimized</li>
        <li>Secured by self-firejailing and 2FA</li>
        <li>1 language for the whole stack</li>
        <li>C speed</li>
        <li>Python-like syntax</li>
        <li>Seamlessly integration with anything that has a C API</li>
        <li>.. and much more!</li>
      </ul>
    </div>
  </div>
  <div>
    <div>
      <div>
        <div>
          <div>
            <h4>One click install </h4>
            <p>Install using Nim's <a href="http://nimble.directory">package manager Nimble</a>,
            <a href="https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/docker">use the Docker template</a> or
            <a href="https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/autoinstall.sh">use the AutoInstall script</a>.</p>
            <br>
            <p>For more options <a href="https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops">checkout the DevOps resources</a>.</p>
          </div>
        </div>
        <div>
          <div>
            <h4>Plugin Store</h4>
            <p>Its like an App Store but for features. Install plugins within the browser - a feature, a click.</p>
            <br>
            <p><a href="https://github.com/ThomasTJdev/nimwc_plugins#contribute">Code your ideas into features, create your own Plugin</a>.</p>
          </div>
        </div>
        <div>
          <div>
            <h4>Speed + Security </h4>
            <p>Written using <a href="https://nim-lang.org">the Nim programming language</a> to <a href="https://nim-lang.org/features.html">ensure high performance</a>.</p>
            <br>
            <p><a href="https://github.com/ThomasTJdev/nim_websitecreator#security">Firejail and 2 Factor Authentication is enabled by default.</a></p>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div>
    <h2>Install & Run</h2>
    <div>
      <div>
        <div>
          <div>
            <div>
              <h4>Nimble</h4>
              <p>
                <label>Install:</label>
                <kbd>nimble install nimwc</kbd>
              </p>
              <p>
                <label>Run:</label>
                <kbd>nimwc</kbd>
              </p>
            </div>
          </div>
          <div>
            <div>
              <h4>Compile</h4>
              <p>
                <label>Clone:</label>
                <kbd>git clone https://github.com/ThomasTJdev/nim_websitecreator.git</kbd>
              </p>
              <p>
                <label>Compile:</label>
                <kbd>nim c -r nimwc.nim</kbd>
              </p>
            </div>
          </div>
          <div>
            <div>
              <h4>Auto install</h4>
              <p>
                <label>Install:</label>
                <kbd>curl https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/devops/autoinstall.sh -sSf | sh</kbd>
              </p>
              <p>
                <span>Follow the tutorial in the terminal</span>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <br>
    <iframe width="100%" height="480" src="https://www.youtube-nocookie.com/embed/3R1l4Ha0tDI" frameborder=0 allowfullscreen
    style="height:480px !important;">https://youtu.be/3R1l4Ha0tDI</iframe>
  </div>
  <div>
    <h2>Less code, more performance<br>use Nim-Lang</h2>
    <h4>
      Nim compiles to tiny single-file which is a dependency-free optimized native binaries.
      The C sources will still compile 100 years in the future, will your stack compile 1 year in the future?.</h4>
  </div>
  <div>
    <div>
      <div>
        <div>
          <div>
            <div>
              <h4>Try NimWC</h4>
              <p>You can try NimWC without registration or installation.</p>
              <br>
              <p><a href="/login">Login</a> with the test users credentials to explore NimWC options.</p>
            </div>
          </div>
          <div>
            <div>
              <h4>Learn more</h4>
              <p>Visit the <a href="https://github.com/ThomasTJdev/nim_websitecreator">Github page</a> to see the examples on how to use NimWC.</p>
              <br>
              <p>Got a question? Open an issue!.</p>
              <br>
              <a href="https://github.com/ThomasTJdev/nim_websitecreator" data-icon="octicon-star" data-size="large" aria-label="Star ThomasTJdev/nim_websitecreator on GitHub">Star</a>
              <a href="https://github.com/ThomasTJdev/nim_websitecreator/fork" data-icon="octicon-repo-forked" data-size="large" aria-label="Fork ThomasTJdev/nim_websitecreator on GitHub">Fork</a>
              <a href="https://github.com/ThomasTJdev/nim_websitecreator/issues" data-icon="octicon-issue-opened" data-size="large" aria-label="Issue ThomasTJdev/nim_websitecreator on GitHub">Issue</a>
            </div>
          </div>
          <div>
          <div>
            <h4>Keep pushing the limits</h4>
            <p>Can you write YAML? then you can code a web app and a NimWC plugin!</p>
            <br>
            <p><b>Keep It Simple</b><br>this is how a <i>Hello World</i> looks like:</p>
            <div id="code">
              <span class="route1">routes:</span>
              <br>
              <span class="route2">get "/yourUrlHere":</span>
              <br>
              <span class="route3">resp "Hello World"</span>
            </div>
            <br>
            <small><a href="https://github.com/juancarlospaco/nim-presentation-slides/blob/master/ejemplos/basico/jester/hello_web_3.nim#L38">A more complete example</a></small>
          </div>
        </div>
        </div>
      </div>
    </div>
  </div>
  <div>
  </div>
</div>
<script src="https://buttons.github.io/buttons.js" crossorigin="anonymous" async defer ></script>"""


  frontpage* = """<div id="frontpage">
  <div class="title has-text-centered">
    <h1 class="reveal reveal-bottom">Nim Website Creator</h1>
    <h2 class="reveal reveal-bottom">Open-source website framework</h2>
    <img src="/images/logo/NimWC_logo_shadow.png" alt="NimWC logo">
    <hr>
  </div>
  <div class="text3">
    <div class="container-fluid">
      <div class="columns row">
        <div class="column">
          <div class="text3element">
            <h4>One click install
            </h4>
            <p>Install using Nim's <a href="http://nimble.directory">package manager Nimble</a>,
            <a href="https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/docker">use the Docker template</a> or
            <a href="https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/autoinstall.sh">use the AutoInstall script</a>.</p>
            <br>
            <p>For more options <a href="https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops">checkout the DevOps resources</a>.</p>
          </div>
        </div>
        <div class="column">
          <div class="text3element">
            <h4>Plugin Store</h4>
            <p>Its like an App Store but for features. Install plugins within the browser - a feature, a click.</p>
            <br>
            <p><a href="https://github.com/ThomasTJdev/nimwc_plugins#contribute">Code your ideas into features, create your own Plugin</a>.</p>
          </div>
        </div>
        <div class="column">
          <div class="text3element">
            <h4>Speed + Security
            </h4>
            <p>Written using <a href="https://nim-lang.org">the Nim programming language</a> to <a href="https://nim-lang.org/features.html">ensure high performance</a>.</p>
            <br>
            <p><a href="https://github.com/ThomasTJdev/nim_websitecreator#security">Firejail and 2 Factor Authentication is enabled by default.</a></p>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="text4">
    <h2>Install & Run</h2>
    <div class="text4container">
      <div class="container-fluid">
        <div class="columns row">
          <div class="column col-12 col-md-4">
            <div class="text4element">
              <h4>Nimble</h4>
              <p>
                <label>Install:</label>
                <kbd>nimble install nimwc</kbd>
              </p>
              <p>
                <label>Run:</label>
                <kbd>nimwc</kbd>
              </p>
            </div>
          </div>
          <div class="column col-12 col-md-4">
            <div class="text4element">
              <h4>Compile</h4>
              <p>
                <label>Clone:</label>
                <kbd>git clone https://github.com/ThomasTJdev/nim_websitecreator.git</kbd>
              </p>
              <p>
                <label>Compile:</label>
                <kbd>nim c -r nimwc.nim</kbd>
              </p>
            </div>
          </div>
          <div class="column col-12 col-md-4">
            <div class="text4element">
              <h4>Auto install</h4>
              <p>
                <label>Install:</label>
                <kbd>curl https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/devops/autoinstall.sh -sSf | sh</kbd>
              </p>
              <p>
                <span>Follow the tutorial in the terminal</span>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <br>
    <iframe width="100%" height="480" src="https://www.youtube-nocookie.com/embed/3R1l4Ha0tDI" frameborder=0 allowfullscreen
    style="height:480px !important;">https://youtu.be/3R1l4Ha0tDI</iframe>
  </div>
  <div class="text5">
    <h2 class="sub1 reveal reveal-bottom">Less code, more performance<br>use Nim-Lang</h2>
    <h4 class="sub2 reveal reveal-bottom">
      Nim compiles to tiny single-file which is a dependency-free optimized native binaries.
      The C sources will still compile 100 years in the future, will your stack compile 1 year in the future?.</h4>
  </div>
  <div class="text6">
    <div class="text6container">
      <div class="container-fluid">
        <div class="columns row">
          <div class="column">
            <div class="text6element">
              <h4>Try NimWC</h4>
              <p>You can try NimWC without registration or installation.</p>
              <br>
              <p><a href="/login">Login</a> with the test users credentials to explore NimWC options.</p>
            </div>
          </div>
          <div class="column">
            <div class="text6element">
              <h4>Learn more</h4>
              <p>Visit the <a href="https://github.com/ThomasTJdev/nim_websitecreator">Github page</a> to see the examples on how to use NimWC.</p>
              <br>
              <p>Got a question? Open an issue!.</p>
              <br>
              <a class="github-button" href="https://github.com/ThomasTJdev/nim_websitecreator" data-icon="octicon-star" data-size="large" aria-label="Star ThomasTJdev/nim_websitecreator on GitHub">Star</a>
              <a class="github-button" href="https://github.com/ThomasTJdev/nim_websitecreator/fork" data-icon="octicon-repo-forked" data-size="large" aria-label="Fork ThomasTJdev/nim_websitecreator on GitHub">Fork</a>
              <a class="github-button" href="https://github.com/ThomasTJdev/nim_websitecreator/issues" data-icon="octicon-issue-opened" data-size="large" aria-label="Issue ThomasTJdev/nim_websitecreator on GitHub">Issue</a>
            </div>
          </div>
          <div class="column">
          <div class="text6element">
            <h4>Keep pushing the limits</h4>
            <p>Can you write YAML? then you can code a web app and a NimWC plugin!</p>
            <br>
            <p><b>Keep It Simple</b><br>this is how a <i>Hello World</i> looks like:</p>
            <div id="code">
              <span class="route1">routes:</span>
              <br>
              <span class="route2">get "/yourUrlHere":</span>
              <br>
              <span class="route3">resp "Hello World"</span>
            </div>
            <br>
            <small><a href="https://github.com/juancarlospaco/nim-presentation-slides/blob/master/ejemplos/basico/jester/hello_web_3.nim#L38">A more complete example</a></small>
          </div>
        </div>
        </div>
      </div>
    </div>
  </div>
  <div class="spacer">
  </div>
</div>
<script src="https://buttons.github.io/buttons.js" crossorigin="anonymous" async defer ></script>"""


  blogpost1* = """<div id="mainContainer" class="blogpage">
  <h1>Insert blog title</h1>
  <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>
  <hr/>
  <h2>Section 2</h2>
  <p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
  <h2>Section 3</h2>
  <p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
  <hr>
  <h4>Section 4</h4>
  <p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
</div>"""


  blogpost2* = """<style>
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
    background-image: url(/images/par1b.jpg);
  }
  body .para_bar {
    background-image: url(/images/par2b.jpg);
  }
  body .para_baz {
    background-image: url(/images/par3b.jpg);
  }
</style>
<div>
  <div class="para para_foo">
    <div style="padding-top: 100px;max-width: 200px;margin-left: auto;margin-right: auto;">
      <div class="animated bounceInRight go reveal reveal-left" style="background: black;color: white;padding: 20px;border-radius: 10px;text-align: center;">
        <h1>First parallax</h1>
      </div>
    </div>
  </div>
  <div class="para para_bar">
    <div style="background: white;color: black;padding: 20px;border-radius: 10px;text-align: center;max-width: 200px;margin-left: auto;margin-right: auto;">
        <h1>Second parallax</h1>
      </div>
  </div>
  <div class="para para_baz">
    <div style="background: white;color: black;padding: 20px;border-radius: 10px;text-align: center;max-width: 200px;margin-left: auto;margin-right: auto;">
      <h1>Third parallax</h1>
    </div>
  </div>
</div>"""


  blogpost3* = """<div style="background: white; color: black; padding: 20px; max-width: 1200px; padding: 20px; border-radius: 10px; margin-left: auto; margin-right: auto; margin-top: 100px;">
  <h1>Standard blog
  </h1>
  <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  </p>
  <p>
    <br>
  </p>
  <div>
    <p>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?
      <br>
    </p>
  </div>
</div>
<div style="height: 50px; background: transparent;">
</div>
<div class="container-fluid" style="max-width: 1200px; margin-left: auto; margin-right: auto;">
  <div class="columns row">
    <div class="column col-12 col-sm-6">
      <div style="background: white; color: black; padding: 25px; border-radius: 10px;">
        <h2 style="text-align: center;">UNO
        </h2>
      </div>
    </div>
    <div class="column col-12 col-sm-6">
      <div style="background: white; color: black; padding: 25px; border-radius: 10px;">
        <h2 style="text-align: center;">DUO
        </h2>
      </div>
    </div>
  </div>
</div>
<div style="height: 50px; background: transparent;">
</div>
<div style="background: white; color: black; padding: 20px; max-width: 1200px; padding: 20px; border-radius: 10px; margin-left: auto; margin-right: auto; margin-bottom: 150px; text-align: right;">
  <h1 style="text-align: right;">Standard blog
  </h1>
  <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  </p>
  <p>
    <br>
  </p>
  <div>
    <p>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?
      <br>
    </p>
  </div>
</div>"""


  adminErrorMsg* = """

    <!DOCTYPE html>
    <center>
      <h1>Error Logs</h1>
      <p>Hi Admin, an error occurred at $3 </p>
      <textarea name="logs" id="logs" title="Log Size: $2 Lines." dir="auto" rows=20 readonly autofocus spellcheck style="width:99% !important;">
        $1
      </textarea>
      <br>
      <a title="Copy Logs" onclick="document.querySelector('#logs').select();document.execCommand('copy')">
        <button>Copy</button>
      </a>
      <br>
    </center>

  """


  mailStyleFrom* = minifyHtml"""

    <hr style="margin-top:40px;margin-bottom:20px;">
    <div> <b>Kind regards</b> </div>

  """


  mailStyleHeaderMsg* = minifyHtml"""

    <!DOCTYPE html>
      <html lang="EN" style="3D&quot;background:#FAFAFA;min-height:100%=">
        <head>
          <meta charset="UTF-8">
          <meta content="width=device-width, initial-scale=1.0" name="viewport">
          <title></title>
        </head>
        <body style="font-size:16px;font-family:'Roboto';font-style:normal;font-weight:400;src:local('Roboto'),local('Roboto-Regular'),url(https://fonts.gstatic.com/s/roboto/v18/CWB0XYA8bzo0kSThX0UTuA.woff2) format('woff2');unicode-range:U+0000-00FF,U+0131,U+0152-0153,U+02C6,U+02DA,U+02DC,U+2000-206F,U+2074,U+20AC,U+2212,U+2215;">
          <div style="background:#171921;border-color:#123d6d;height:70px;width:100%;margin-bottom:20px;padding-top:5px;padding-bottom:5px;text-align:center;">
            <a href="$1" style="color:white;font-size:22px;line-height:64px;"> $2 </a>
          </div>
          <div style="padding:0 9px">

  """


  mailStyleFooterMsg* = minifyHtml"""

        </div>
          <div style="background:#171921;border-color:#123d6d;height:35px;width:100%;margin-top:20px;text-align:center;">
            <div style="height:100%;font-size:18px;margin-left:15px;line-height:36px;">
              <a href="$1" style="color:white;"> $2 </a>
            </div>
          </div>
      </body>
    </html>

  """


  activationMsg* = minifyHtml"""

    <h3>Hello $1 </h3>
    <br><br>
    $2 has created a user account for you on $7.
    <br><br>
    As the final step in your registration, we require that you confirm your email
    via the following link:
    <br>
    $5
    <br><br>
    To login use the details below. On your first login, please navigate to your settings and <b>change your password!</b>
    <ul>
      <li>Email:   <code> $3 </code></li>
      <li>
        Password:
        <input type="text" title="Password" onClick="this.select();document.execCommand('copy')" value="$4" readonly >
      </li>
    </ul>
    Please do not hesitate to contact us at $8, if you have any questions.
    <br><br>
    Thank you for registering and becoming a part of $6!.

  """


  registrationMsg* = minifyHtml"""

    <h3>Hello $1 </h3>
    <br><br>
    We are looking forward to see you at $3!
    We have sent you an activation email with your password.
    You just need to click on the link to become a part of $3.
    <br><br>
    Please do not hesitate to contact us at $5, if you have any questions.
    <br><br>
    Thank you for registering and becoming a part of $2!.

  """


  pluginHtmlListItem* = minifyHtml"""

    <li data-plugin="$1" class="pluginSettings $6" data-enabled="$2">
      <div class="name"> <a href="$3"><b>$4</b> <i>($5)</i></a> </div>
      <div class="enablePlugin"  title="Turn ON">  Start </div>
      <div class="disablePlugin" title="Turn OFF"> Stop  </div>
    </li>

  """