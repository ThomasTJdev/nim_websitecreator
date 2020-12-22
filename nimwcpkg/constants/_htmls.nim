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
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.0/css/bulma.min.css" integrity="sha256-D9M5yrVDqFlla7nlELDaYZIpXfFWDytQtiV+TaH6F1I=" crossorigin="anonymous" />
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
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.0/css/bulma.min.css" integrity="sha256-D9M5yrVDqFlla7nlELDaYZIpXfFWDytQtiV+TaH6F1I=" crossorigin="anonymous" />
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
  <p class="subtitle has-text-centered is-6">&copy; PPL - <a href="https://github.com/ThomasTJdev/nim_websitecreator"><u>Github</u></a></p>
</div>"""

  footerOfficial* = """<div class="container" class="footer is-light">
  <div class="columns">
    <div class="column is-4 has-text-centered is-hidden-tablet"><a class="title is-4" href="/">Nim Website Creator</a></div>
    <div class="column is-4">
      <div class="level"><p>2019 - <a href="https://ttj.dk"><u>Thomas T. Jarløv</u></a> & <a href="https://github.com/juancarlospaco"><u>Juan Carlos</u></a></p></div>
    </div>
    <div class="column is-4 has-text-centered is-hidden-mobile"></div>
    <div class="column is-4 has-text-right">
      <div class="level"><a class="level-item" href="https://nim-lang.org">Powered by Nim</a></div>
    </div>
  </div>
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
  <div class="title">
    <h1 class="reveal reveal-bottom">Nim Website Creator</h1>
    <h2 class="reveal reveal-bottom">Open-source website framework</h2>
    <h2 class="reveal reveal-bottom seemore">
      <a href="#start" class="jump">Get started today!</a>
    </h2>
  </div>
  <div id="start" class="text2 reveal reveal-bottom">
    <h2>NimWC is a new tool for<br>
    generating websites on the fly</h2>
    <div class="featurelist">
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

  frontpageOfficial* = """<div id="welcome">
  <section class="hero">
    <div class="container">
      <div class="hero-inner">
        <div class="hero-copy">
          <h1 class="hero-title mt-0">Nim Website Creator</h1>
          <p class="hero-paragraph">NimWC is a new open-source tool for generating websites on the fly. It is possible
            to customize the frontend code for all pages or for specific pages. This flexibility gives the user the
            power instead of given the power to the platform.</p>
          <div class="hero-cta"><a class="button button-shadow" href="#flexi">Learn more</a><a
              class="button button-primary button-shadow" href="/login">Try it!</a></div>
        </div>
        <div class="hero-app">
          <img class="device-mockup" src="/images/logo/NimWC_logo_shadow.png" alt="App preview">
          <div class="hero-app-dots hero-app-dots-1">
            <svg width="124" height="75" xmlns="http://www.w3.org/2000/svg">
              <g fill="none" fill-rule="evenodd">
                <path fill="#FFF"
                  d="M33.392 0l3.624 1.667.984 3.53-1.158 3.36L33.392 10l-3.249-1.639L28 5.196l1.62-3.674z" />
                <path fill="#7487A3"
                  d="M74.696 3l1.812.833L77 5.598l-.579 1.68L74.696 8l-1.624-.82L72 5.599l.81-1.837z" />
                <path fill="#556B8B"
                  d="M40.696 70l1.812.833.492 1.765-.579 1.68-1.725.722-1.624-.82L38 72.599l.81-1.837z" />
                <path fill="#7487A3"
                  d="M4.314 37l2.899 1.334L8 41.157l-.926 2.688L4.314 45l-2.6-1.31L0 41.156l1.295-2.94zM49.314 32l2.899 1.334.787 2.823-.926 2.688L49.314 40l-2.6-1.31L45 36.156l1.295-2.94z" />
                <path fill="#556B8B"
                  d="M99.696 56l1.812.833.492 1.765-.579 1.68-1.725.722-1.624-.82L97 58.599l.81-1.837zM112.696 37l1.812.833.492 1.765-.579 1.68-1.725.722-1.624-.82L110 39.599l.81-1.837zM82.696 37l1.812.833.492 1.765-.579 1.68-1.725.722-1.624-.82L80 39.599l.81-1.837zM122.618 57l1.087.5.295 1.059-.347 1.008-1.035.433-.975-.492-.643-.95.486-1.101z" />
              </g>
            </svg>
          </div>
          <div class="hero-app-dots hero-app-dots-2">
            <svg width="124" height="75" xmlns="http://www.w3.org/2000/svg">
              <g fill="none" fill-rule="evenodd">
                <path fill="#556B8B"
                  d="M33.392 0l3.624 1.667.984 3.53-1.158 3.36L33.392 10l-3.249-1.639L28 5.196l1.62-3.674zM74.696 3l1.812.833L77 5.598l-.579 1.68L74.696 8l-1.624-.82L72 5.599l.81-1.837zM40.696 70l1.812.833.492 1.765-.579 1.68-1.725.722-1.624-.82L38 72.599l.81-1.837zM4.314 37l2.899 1.334L8 41.157l-.926 2.688L4.314 45l-2.6-1.31L0 41.156l1.295-2.94zM49.314 32l2.899 1.334.787 2.823-.926 2.688L49.314 40l-2.6-1.31L45 36.156l1.295-2.94z" />
                <path fill="#FFF"
                  d="M99.696 56l1.812.833.492 1.765-.579 1.68-1.725.722-1.624-.82L97 58.599l.81-1.837z" />
                <path fill="#556B8B"
                  d="M112.696 37l1.812.833.492 1.765-.579 1.68-1.725.722-1.624-.82L110 39.599l.81-1.837z" />
                <path fill="#FFF"
                  d="M82.696 37l1.812.833.492 1.765-.579 1.68-1.725.722-1.624-.82L80 39.599l.81-1.837z" />
                <path fill="#556B8B"
                  d="M122.618 57l1.087.5.295 1.059-.347 1.008-1.035.433-.975-.492-.643-.95.486-1.101z" />
              </g>
            </svg>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section class="features section">
    <div class="container">
      <div class="features-inner section-inner has-bottom-divider">
        <h2 class="section-title mt-0" id="flexi">Flexibility</h2>
        <div class="features-wrap">
          <div class="feature is-revealing">
            <div class="feature-inner">
              <h3 class="feature-title mt-24">Self-hosting</h3>
              <p class="text-sm mb-0">By utilizing the powerful language Nim, NimWC is compiled to C code, which is
                runnable on almost all platforms. This further more makes it incredibly easy to host NimWC on e.g.
                Amazon or on a Raspberry Pi.</p>
            </div>
          </div>
          <div class="feature is-revealing">
            <div class="feature-inner">
              <h3 class="feature-title mt-24">Open source</h3>
              <p class="text-sm mb-0">All of NimWC code is available to the public. Any Nim programmer can contribute
                with improvements and new features. The codebase is built upon modules, which makes it easy to add new
                features and plugins.</p>
            </div>
          </div>
          <div class="feature is-revealing">
            <div class="feature-inner">
              <h3 class="feature-title mt-24">Wordpress</h3>
              <p class="text-sm mb-0">NimWC is not a replacement for Wordpress but an alternative. NimWC is a
                self-hosted solution with a minimum of requirements which also ensures, that there are fewer
                dependencies.</p>
            </div>
          </div>
        </div>
        <div class="features-wrap">
          <div class="feature is-revealing">
            <div class="feature-inner">
              <h3 class="feature-title mt-24">One-click install</h3>
              <p class="text-sm mb-0">Setup NimWC in no time. Install using Nim's package manager Nimble, use the Docker template or use the AutoInstall script.</p>
            </div>
          </div>
          <div class="feature is-revealing">
            <div class="feature-inner">
              <h3 class="feature-title mt-24">Plugin Store</h3>
              <p class="text-sm mb-0">Its like an App Store but for features - newsletters, backup, etc. Install plugins within the browser - a feature, a click.</p>
            </div>
          </div>
          <div class="feature is-revealing">
            <div class="feature-inner">
              <h3 class="feature-title mt-24">Speed + Security</h3>
              <p class="text-sm mb-0">Written using the Nim programming language to ensure high performance. Firejail, 2 Factor Authentication and honeypot.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section class="media section">
    <div class="container">
      <div class="media-inner section-inner">
        <div class="media-header text-center">
          <h2 class="section-title mt-0">Install & Run</h2>
          <p class="section-paragraph mb-0">The installation tool Nimble will take of all the dependencies - just run
            NimWC!</p>
        </div>

        <div class="features-wrap">
          <div class="feature is-revealing">
            <div class="feature-inner installmethod">
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
          <div class="feature is-revealing">
            <div class="feature-inner installmethod">
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
          <div class="feature is-revealing">
            <div class="feature-inner installmethod">
              <h4>Auto install</h4>
              <p>
                <label>Install:</label>
                <kbd>curl https://raw.githubusercontent.com/ThomasTJdev/nim_websitecreator/master/devops/autoinstall.sh
                  -sSf | sh</kbd>
              </p>
              <p>
                <span>Follow the tutorial in the terminal</span>
              </p>
            </div>
          </div>
        </div>

        <div class="media-canvas">
          <iframe width="100%" height="480" src="https://www.youtube-nocookie.com/embed/3R1l4Ha0tDI" frameborder="0"
            allowfullscreen="" style="height:480px !important;">https://youtu.be/3R1l4Ha0tDI</iframe>

        </div>
      </div>
    </div>
  </section>

  <section class="newsletter section">
    <div class="container-sm">
      <div class="newsletter-inner section-inner">
        <div class="newsletter-header text-center">
          <h2 class="section-title mt-0">Interested?</h2>
          <p class="section-paragraph">Get in contact with us, ask a question or checkout the source code - visit us at
            the Github repo.</p>
        </div>
        <a class="button button-primary button-block button-shadow"
          href="https://github.com/ThomasTJdev/nim_websitecreator">Nim Website Creator at Github</a>
      </div>
    </div>
  </section>
</div>"""

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


  officialCss* = """html{line-height:1.15;-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%}body{margin:0}article,aside,footer,header,nav,section{display:block}h1{font-size:2em;margin:0.67em 0}figcaption,figure,main{display:block}figure{margin:1em 40px}hr{box-sizing:content-box;height:0;overflow:visible}pre{font-family:monospace, monospace;font-size:1em}a{background-color:transparent;-webkit-text-decoration-skip:objects}abbr[title]{border-bottom:none;text-decoration:underline;-webkit-text-decoration:underline dotted;text-decoration:underline dotted}b,strong{font-weight:inherit}b,strong{font-weight:bolder}code,kbd,samp{font-family:monospace, monospace;font-size:1em}dfn{font-style:italic}mark{background-color:#ff0;color:#000}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-0.25em}sup{top:-0.5em}audio,video{display:inline-block}audio:not([controls]){display:none;height:0}img{border-style:none}svg:not(:root){overflow:hidden}button,input,optgroup,select,textarea{font-family:sans-serif;font-size:100%;line-height:1.15;margin:0}button,input{overflow:visible}button,select{text-transform:none}button,html [type="button"],[type="reset"],[type="submit"]{-webkit-appearance:button}button::-moz-focus-inner,[type="button"]::-moz-focus-inner,[type="reset"]::-moz-focus-inner,[type="submit"]::-moz-focus-inner{border-style:none;padding:0}button:-moz-focusring,[type="button"]:-moz-focusring,[type="reset"]:-moz-focusring,[type="submit"]:-moz-focusring{outline:1px dotted ButtonText}fieldset{padding:0.35em 0.75em 0.625em}legend{box-sizing:border-box;color:inherit;display:table;max-width:100%;padding:0;white-space:normal}progress{display:inline-block;vertical-align:baseline}textarea{overflow:auto}[type="checkbox"],[type="radio"]{box-sizing:border-box;padding:0}[type="number"]::-webkit-inner-spin-button,[type="number"]::-webkit-outer-spin-button{height:auto}[type="search"]{-webkit-appearance:textfield;outline-offset:-2px}[type="search"]::-webkit-search-cancel-button,[type="search"]::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}details,menu{display:block}summary{display:list-item}canvas{display:inline-block}template{display:none}[hidden]{display:none}html{box-sizing:border-box}*,*:before,*:after{box-sizing:inherit}body{background:#06101F;-moz-osx-font-smoothing:grayscale;-webkit-font-smoothing:antialiased}hr{border:0;display:block;height:1px;background:#273C5A;background:linear-gradient(to right, rgba(39,60,90,0.1) 0, rgba(39,60,90,0.6) 50%, rgba(39,60,90,0.1) 100%);margin-top:24px;margin-bottom:24px}ul,ol{margin-top:0;margin-bottom:24px;padding-left:24px}ul{list-style:disc}ol{list-style:decimal}li>ul,li>ol{margin-bottom:0}dl{margin-top:0;margin-bottom:24px}dt{font-weight:700}dd{margin-left:24px;margin-bottom:24px}img{height:auto;max-width:100%;vertical-align:middle}figure{margin:24px 0}figcaption{font-size:16px;line-height:24px;padding:8px 0}img,svg{display:block}table{border-collapse:collapse;margin-bottom:24px;width:100%}tr{border-bottom:1px solid #273C5A}th{text-align:left}th,td{padding:10px 16px}th:first-child,td:first-child{padding-left:0}th:last-child,td:last-child{padding-right:0}html{font-size:20px;line-height:30px}body{color:#7487A3;font-size:1rem}body,button,input,select,textarea{font-family:"Heebo", sans-serif}a{color:#F9425F;text-decoration:none}a:hover,a:active{outline:0;text-decoration:underline}#welcome h1,#welcome h2,#welcome h3,#welcome h4,#welcome h5,#welcome h6,#welcome .h1,#welcome .h2,#welcome .h3,#welcome .h4,#welcome .h5,#welcome .h6{clear:both;color:#fff;font-family:"Playfair Display", serif;font-weight:700}h1,.h1{font-size:44px;line-height:56px;letter-spacing:0px}@media (min-width: 641px){h1,.h1{font-size:48px;line-height:62px;letter-spacing:0px}}h2,.h2{font-size:40px;line-height:52px;letter-spacing:0px}@media (min-width: 641px){h2,.h2{font-size:44px;line-height:56px;letter-spacing:0px}}h3,.h3,blockquote{font-size:24px;line-height:34px;letter-spacing:-0.1px}h4,h5,h6,.h4,.h5,.h6{font-size:20px;line-height:30px;letter-spacing:-0.1px}@media (max-width: 640px){.h1-mobile{font-size:44px;line-height:56px;letter-spacing:0px}.h2-mobile{font-size:40px;line-height:52px;letter-spacing:0px}.h3-mobile{font-size:24px;line-height:34px;letter-spacing:-0.1px}.h4-mobile,.h5-mobile,.h6-mobile{font-size:20px;line-height:30px;letter-spacing:-0.1px}}.text-light h1,.text-light h2,.text-light h3,.text-light h4,.text-light h5,.text-light h6,.text-light .h1,.text-light .h2,.text-light .h3,.text-light .h4,.text-light .h5,.text-light .h6{color:!important}.text-sm{font-size:18px;line-height:27px;letter-spacing:-0.1px}.text-xs{font-size:16px;line-height:24px;letter-spacing:-0.1px}h1,h2,.h1,.h2{margin-top:48px;margin-bottom:16px}h3,.h3{margin-top:36px;margin-bottom:12px}h4,h5,h6,.h4,.h5,.h6{margin-top:24px;margin-bottom:4px}p{margin-top:0;margin-bottom:24px}dfn,cite,em,i{font-style:italic}blockquote{color:#556B8B;font-style:italic;margin-top:24px;margin-bottom:24px;margin-left:24px}blockquote::before{content:"\201C"}blockquote::after{content:"\201D"}blockquote p{display:inline}address{color:#7487A3;border-width:1px 0;border-style:solid;border-color:#273C5A;padding:24px 0;margin:0 0 24px}pre,pre h1,pre h2,pre h3,pre h4,pre h5,pre h6,pre .h1,pre .h2,pre .h3,pre .h4,pre .h5,pre .h6{font-family:"Courier 10 Pitch", Courier, monospace}pre,code,kbd,tt,var{background:#1D304B}pre{font-size:16px;line-height:24px;margin-bottom:1.6em;max-width:100%;overflow:auto;padding:24px;margin-top:24px;margin-bottom:24px}code,kbd,tt,var{font-family:Monaco, Consolas, "Andale Mono", "DejaVu Sans Mono", monospace;font-size:16px;padding:2px 4px}abbr,acronym{cursor:help}mark,ins{text-decoration:none}small{font-size:18px;line-height:27px;letter-spacing:-0.1px}b,strong{font-weight:700}button,input,select,textarea,label{font-size:20px;line-height:30px}.container,.container-sm{width:100%;margin:0 auto;padding-left:16px;padding-right:16px}@media (min-width: 481px){.container,.container-sm{padding-left:24px;padding-right:24px}}.container{max-width:1128px}.container-sm{max-width:848px}.container .container-sm{max-width:800px;padding-left:0;padding-right:0}.screen-reader-text{clip:rect(1px, 1px, 1px, 1px);position:absolute !important;height:1px;width:1px;overflow:hidden;word-wrap:normal !important}.screen-reader-text:focus{border-radius:2px;box-shadow:0 0 2px 2px rgba(0,0,0,0.6);clip:auto !important;display:block;font-size:14px;letter-spacing:0px;font-weight:700;line-height:16px;text-decoration:none;text-transform:uppercase;background-color:#06101F;color:#F9425F !important;border:none;height:auto;left:8px;padding:16px 32px;top:8px;width:auto;z-index:100000}.list-reset{list-style:none;padding:0}.text-left{text-align:left}.text-center{text-align:center}.text-right{text-align:right}.text-primary{color:#F9425F}.text-secondary{color:#47A1F9}.has-top-divider{position:relative}.has-top-divider::before{content:'';position:absolute;top:0;left:0;width:100%;display:block;height:1px;background:#273C5A;background:linear-gradient(to right, rgba(39,60,90,0.1) 0, rgba(39,60,90,0.6) 50%, rgba(39,60,90,0.1) 100%)}.has-bottom-divider{position:relative}.has-bottom-divider::after{content:'';position:absolute;bottom:0;left:0;width:100%;display:block;height:1px;background:#273C5A;background:linear-gradient(to right, rgba(39,60,90,0.1) 0, rgba(39,60,90,0.6) 50%, rgba(39,60,90,0.1) 100%)}.m-0{margin:0}.mt-0{margin-top:0}.mr-0{margin-right:0}.mb-0{margin-bottom:0}.ml-0{margin-left:0}.m-8{margin:8px}.mt-8{margin-top:8px}.mr-8{margin-right:8px}.mb-8{margin-bottom:8px}.ml-8{margin-left:8px}.m-16{margin:16px}.mt-16{margin-top:16px}.mr-16{margin-right:16px}.mb-16{margin-bottom:16px}.ml-16{margin-left:16px}.m-24{margin:24px}.mt-24{margin-top:24px}.mr-24{margin-right:24px}.mb-24{margin-bottom:24px}.ml-24{margin-left:24px}.m-32{margin:32px}.mt-32{margin-top:32px}.mr-32{margin-right:32px}.mb-32{margin-bottom:32px}.ml-32{margin-left:32px}.m-40{margin:40px}.mt-40{margin-top:40px}.mr-40{margin-right:40px}.mb-40{margin-bottom:40px}.ml-40{margin-left:40px}.m-48{margin:48px}.mt-48{margin-top:48px}.mr-48{margin-right:48px}.mb-48{margin-bottom:48px}.ml-48{margin-left:48px}.m-56{margin:56px}.mt-56{margin-top:56px}.mr-56{margin-right:56px}.mb-56{margin-bottom:56px}.ml-56{margin-left:56px}.m-64{margin:64px}.mt-64{margin-top:64px}.mr-64{margin-right:64px}.mb-64{margin-bottom:64px}.ml-64{margin-left:64px}.p-0{padding:0}.pt-0{padding-top:0}.pr-0{padding-right:0}.pb-0{padding-bottom:0}.pl-0{padding-left:0}.p-8{padding:8px}.pt-8{padding-top:8px}.pr-8{padding-right:8px}.pb-8{padding-bottom:8px}.pl-8{padding-left:8px}.p-16{padding:16px}.pt-16{padding-top:16px}.pr-16{padding-right:16px}.pb-16{padding-bottom:16px}.pl-16{padding-left:16px}.p-24{padding:24px}.pt-24{padding-top:24px}.pr-24{padding-right:24px}.pb-24{padding-bottom:24px}.pl-24{padding-left:24px}.p-32{padding:32px}.pt-32{padding-top:32px}.pr-32{padding-right:32px}.pb-32{padding-bottom:32px}.pl-32{padding-left:32px}.p-40{padding:40px}.pt-40{padding-top:40px}.pr-40{padding-right:40px}.pb-40{padding-bottom:40px}.pl-40{padding-left:40px}.p-48{padding:48px}.pt-48{padding-top:48px}.pr-48{padding-right:48px}.pb-48{padding-bottom:48px}.pl-48{padding-left:48px}.p-56{padding:56px}.pt-56{padding-top:56px}.pr-56{padding-right:56px}.pb-56{padding-bottom:56px}.pl-56{padding-left:56px}.p-64{padding:64px}.pt-64{padding-top:64px}.pr-64{padding-right:64px}.pb-64{padding-bottom:64px}.pl-64{padding-left:64px}.sr .has-animations .is-revealing{visibility:hidden}.input,.textarea{background-color:#fff;border-width:1px;border-style:solid;border-color:#273C5A;border-radius:2px;color:#7487A3;max-width:100%;width:100%}.input::-webkit-input-placeholder,.textarea::-webkit-input-placeholder{color:#556B8B}.input:-ms-input-placeholder,.textarea:-ms-input-placeholder{color:#556B8B}.input::-ms-input-placeholder,.textarea::-ms-input-placeholder{color:#556B8B}.input::placeholder,.textarea::placeholder{color:#556B8B}.input::-ms-input-placeholder,.textarea::-ms-input-placeholder{color:#556B8B}.
input:-ms-input-placeholder,.textarea:-ms-input-placeholder{color:#556B8B}.input:hover,.textarea:hover{border-color:#1f3048}.input:active,.input:focus,.textarea:active,.textarea:focus{outline:none;border-color:#273C5A}.input[disabled],.textarea[disabled]{cursor:not-allowed;background-color:#1D304B;border-color:#1D304B}.input{-moz-appearance:none;-webkit-appearance:none;font-size:16px;letter-spacing:-0.1px;line-height:20px;padding:13px 16px;height:48px;box-shadow:none}.input .inline-input{display:inline;width:auto}.textarea{display:block;min-width:100%;resize:vertical}.textarea .inline-textarea{display:inline;width:auto}.field-grouped>.control:not(:last-child){margin-bottom:8px}@media (min-width: 641px){.field-grouped{display:flex}.field-grouped>.control{flex-shrink:0}.field-grouped>.control.control-expanded{flex-grow:1;flex-shrink:1}.field-grouped>.control:not(:last-child){margin-bottom:0;margin-right:8px}}.button{display:inline-flex;font-size:14px;letter-spacing:0px;font-weight:700;line-height:16px;text-decoration:none !important;text-transform:uppercase;background-color:#273C5A;color:#fff !important;border:none;border-radius:2px;cursor:pointer;justify-content:center;padding:16px 32px;height:48px;text-align:center;white-space:nowrap}.button:hover{background:#293e5e}.button:active{outline:0}.button::before{border-radius:2px}.button-shadow{position:relative}.button-shadow::before{content:'';position:absolute;top:0;right:0;bottom:0;left:0;box-shadow:0 8px 24px rgba(6,16,31,0.25);mix-blend-mode:multiply;transition:box-shadow .15s ease}.button-shadow:hover::before{box-shadow:0 8px 24px rgba(6,16,31,0.35)}.button-sm{padding:8px 24px;height:32px}.button-sm.button-shadow::before{box-shadow:0 4px 16px rgba(6,16,31,0.25)}.button-sm.button-shadow:hover::before{box-shadow:0 4px 16px rgba(6,16,31,0.35)}.button-primary{background-color:#F9425F}.button-primary:hover{background:#f94763}.button-primary.button-shadow::before{box-shadow:0 8px 16px rgba(249,66,95,0.25);mix-blend-mode:normal}.button-primary.button-shadow:hover::before{box-shadow:0 8px 16px rgba(249,66,95,0.35)}.button-primary .button-sm.button-shadow::before{box-shadow:0 4px 16px rgba(249,66,95,0.25)}.button-primary .button-sm.button-shadow:hover::before{box-shadow:0 4px 16px rgba(249,66,95,0.35)}.button-block{display:flex}.site-header{position:relative;padding:24px 0}.site-header::before{content:'';position:absolute;right:0;top:0;width:373px;height:509px;background-image:url(data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzczIiBoZWlnaHQ9IjUwOSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4gIDxkZWZzPiAgICA8bGluZWFyR3JhZGllbnQgeDE9IjkyLjgyNyUiIHkxPSIwJSIgeDI9IjUzLjQyMiUiIHkyPSI4MC4wODclIiBpZD0iYSI+ICAgICAgPHN0b3Agc3RvcC1jb2xvcj0iI0Y5NDI1RiIgb2Zmc2V0PSIwJSIvPiAgICAgIDxzdG9wIHN0b3AtY29sb3I9IiNGOTdDNTgiIHN0b3Atb3BhY2l0eT0iMCIgb2Zmc2V0PSIxMDAlIi8+ICAgIDwvbGluZWFyR3JhZGllbnQ+ICAgIDxsaW5lYXJHcmFkaWVudCB4MT0iOTIuODI3JSIgeTE9IjAlIiB4Mj0iNTMuNDA2JSIgeTI9IjgwLjEyJSIgaWQ9ImIiPiAgICAgIDxzdG9wIHN0b3AtY29sb3I9IiM0N0ExRjkiIG9mZnNldD0iMCUiLz4gICAgICA8c3RvcCBzdG9wLWNvbG9yPSIjRjk0MjVGIiBzdG9wLW9wYWNpdHk9IjAiIG9mZnNldD0iODAuNTMyJSIvPiAgICAgIDxzdG9wIHN0b3AtY29sb3I9IiNGREZGREEiIHN0b3Atb3BhY2l0eT0iMCIgb2Zmc2V0PSIxMDAlIi8+ICAgIDwvbGluZWFyR3JhZGllbnQ+ICA8L2RlZnM+ICA8ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPiAgICA8cGF0aCBkPSJNNTY5LjY4IDBjLTE5LjU2NSA1OC42NS00OC45NzMgODIuNjA5LTg4LjIyNiA3MS44NzktNTguODgtMTYuMDk1LTE1OC45LTE4LjI2NS0yMTEuMzkyIDc2Ljg0NS01Mi40OTMgOTUuMTExLTEyMC42ODcgMTQxLjA0My0xODAuMjMzIDk5LjY0NUM1MC4xMyAyMjAuNzY5IDIwLjE4OCAyNDEuOTA0IDAgMzExLjc3TDI1Ni40MzkgNDc2YzE3My41MDYtMy41NjUgMjU2LjAwOS00My4zNzQgMjQ3LjUwNy0xMTkuNDI2LTguNTAyLTc2LjA1MiAyOC45MjMtMTM3LjQ0NSAxMTIuMjc1LTE4NC4xNzhMNjIwIDcxLjg4IDU2OS42OCAweiIgZmlsbD0idXJsKCNhKSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMSAtMjA5KSIvPiAgICA8cGF0aCBkPSJNNjg0Ljk2MSAxODYuNDYxYy0xOS42NTYgNTguNTI4LTQ5LjEzNSA4Mi40Ni04OC40MzggNzEuNzk3LTU4Ljk1NS0xNS45OTQtMTU5LjEyOS0xOC4wNTQtMjExLjgwNCA3Ni44ODEtNTIuNjc0IDk0LjkzNS0xMjEuMDIzIDE0MC44MjctMTgwLjYyIDk5LjU5Mi0zOS43My0yNy40OS02OS43NDItNi4zNzYtOTAuMDM1IDYzLjM0M2wyNTYuNjY4IDE2My41NmMxNzMuNzgyLTMuNzM5IDI1Ni40NTUtNDMuNTM3IDI0OC4wMi0xMTkuMzk2LTguNDM2LTc1Ljg1OCAyOS4xMTItMTM3LjE0MSAxMTIuNjQ0LTE4My44NDhsMy44OS0xMDAuMjc3LTUwLjMyNS03MS42NTJ6IiBmaWxsPSJ1cmwoI2IpIiB0cmFuc2Zvcm09InJvdGF0ZSgtNTMgMjE1LjU4IDMxOC41NDUpIi8+ICA8L2c+PC9zdmc+)}.site-header-inner{position:relative;display:flex;justify-content:space-between;align-items:center}.header-links{display:inline-flex}.header-links li{display:inline-flex}.header-links a:not(.button){font-size:16px;line-height:24px;letter-spacing:-0.1px;font-weight:700;text-transform:uppercase;text-decoration:none;line-height:16px;padding:8px 24px}@media (min-width: 641px){.site-header::before{display:none}}.hero{text-align:center;padding-top:48px;padding-bottom:24px}.hero-copy{position:relative}.hero-paragraph{margin-bottom:32px}.hero-app{position:relative}.hero-app-illustration{position:absolute;top:-358px;left:calc(50% - 436px);pointer-events:none}.hero-app-dots{display:none;position:absolute}.hero-app-dots-1{top:15px;left:-108px}.hero-app-dots-2{bottom:100px;left:320px}.device-mockup{position:relative;width:350px;height:auto;margin:0 auto;visibility:hidden;opacity:0;-webkit-transform:translateY(40px);transform:translateY(40px);transition:opacity 0.6s cubic-bezier(0.5, -0.01, 0, 1.005),-webkit-transform 0.6s cubic-bezier(0.5, -0.01, 0, 1.005);transition:opacity 0.6s cubic-bezier(0.5, -0.01, 0, 1.005),transform 0.6s cubic-bezier(0.5, -0.01, 0, 1.005);transition:opacity 0.6s cubic-bezier(0.5, -0.01, 0, 1.005),transform 0.6s cubic-bezier(0.5, -0.01, 0, 1.005),-webkit-transform 0.6s cubic-bezier(0.5, -0.01, 0, 1.005)}.device-mockup.has-loaded{visibility:visible;opacity:1;-webkit-transform:translateY(0);transform:translateY(0)}.hero-cta{max-width:400px;margin-left:auto;margin-right:auto;margin-bottom:40px}@media (max-width: 639px){.hero-cta .button{display:flex}.hero-cta .button+.button{margin-top:16px}.hero-shape-top{display:none}}@media (min-width: 641px){.hero{position:relative;text-align:left;padding-top:56px;padding-bottom:12px}.hero::before{content:'';position:absolute;left:0;bottom:20px;width:415px;height:461px;background-image:url(data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDE1IiBoZWlnaHQ9IjQ2MSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4gIDxkZWZzPiAgICA8bGluZWFyR3JhZGllbnQgeDE9IjguNjg1JSIgeTE9IjIzLjczMyUiIHgyPSI5OS40MzUlIiB5Mj0iODUuMDc4JSIgaWQ9ImEiPiAgICAgIDxzdG9wIHN0b3AtY29sb3I9IiMxRDMwNEIiIG9mZnNldD0iMCUiLz4gICAgICA8c3RvcCBzdG9wLWNvbG9yPSIjMUQzMDRCIiBzdG9wLW9wYWNpdHk9IjAiIG9mZnNldD0iMTAwJSIvPiAgICA8L2xpbmVhckdyYWRpZW50PiAgPC9kZWZzPiAgPHBhdGggZD0iTTMxOC4xNzEgNjE2LjY0YzE2MC4wODYgMCA3MDIuNTI3LTIyOC4yNiAyODkuODYyLTI5MC00MTIuNjY2LTYxLjczOC0xMjkuNzc2LTI5MC0yODkuODYyLTI5MFMyOC4zMSAxNjYuNDc5IDI4LjMxIDMyNi42NGMwIDE2MC4xNjMgMTI5Ljc3NSAyOTAgMjg5Ljg2MSAyOTB6IiB0cmFuc2Zvcm09InJvdGF0ZSgtNiAtMTMyNy4wMyAzNTk0LjM4KSIgZmlsbD0idXJsKCNhKSIgZmlsbC1ydWxlPSJldmVub2RkIi8+PC9zdmc+)}.hero-inner{display:flex;justify-content:space-between}.hero-copy{padding-top:88px;padding-right:48px;min-width:448px;max-width:588px}.hero-title{margin-bottom:24px}.hero-paragraph{margin-bottom:40px}.hero-app-illustration{left:-257px}.hero-app-dots{display:block}.device-mockup{max-width:none}.hero-cta{margin:0}.hero-cta .button{min-width:170px}.hero-cta .button:first-child{margin-right:16px}}.features .section-title{margin-bottom:48px}.features-wrap{display:flex;flex-wrap:wrap;justify-content:space-evenly;margin-right:-30px;margin-left:-30px}.features-wrap:first-of-type{margin-top:-16px}.features-wrap:last-of-type{margin-bottom:-16px}.feature{padding:16px 30px;width:380px;max-width:380px;flex-grow:1}.feature-inner{height:100%}.feature-title{font-family:"Heebo", sans-serif;font-weight:500}@media (min-width: 641px){.features{position:relative}.features .section-inner{padding-bottom:100px}.features .section-title{position:relative;margin-bottom:80px}.features .section-title::before{content:'';position:absolute;left:-40px;top:-25px;width:49px;height:50px;background-image:url(data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDkiIGhlaWdodD0iNTAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+ICA8ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPiAgICA8cGF0aCBmaWxsPSIjMjczQzVBIiBkPSJNMTQuMTM4IDlsLTcuOTczIDMuNjY3TDQgMjAuNDMybDIuNTQ3IDcuMzkzTDE0LjEzNyAzMWw3LjE0OC0zLjYwNUwyNiAyMC40MzJsLTMuNTYzLTguMDgzeiIvPiAgICA8cGF0aCBmaWxsPSIjNzQ4N0EzIiBkPSJNNDYuMzA0IDBsLTEuODEyLjgzM0w0NCAyLjU5OGwuNTc5IDEuNjhMNDYuMzA0IDVsMS42MjQtLjgyTDQ5IDIuNTk5IDQ4LjE5Ljc2MXpNMi4zMDQgNDVsLTEuODEyLjgzM0wwIDQ3LjU5OGwuNTc5IDEuNjhMMi4zMDQgNTBsMS42MjQtLjgyTDUgNDcuNTk5bC0uODEtMS44Mzd6Ii8+ICA8L2c+PC9zdmc+)}.features::before{content:'';position:absolute;right:0;top:60px;width:257px;height:279px;background-image:url(data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjU3IiBoZWlnaHQ9IjI3OSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4gIDxkZWZzPiAgICA8bGluZWFyR3JhZGllbnQgeDE9IjguNjg1JSIgeTE9IjIzLjczMyUiIHgyPSI5OS40MzUlIiB5Mj0iODUuMDc4JSIgaWQ9ImEiPiAgICAgIDxzdG9wIHN0b3AtY29sb3I9IiMxRDMwNEIiIG9mZnNldD0iMCUiLz4gICAgICA8c3RvcCBzdG9wLWNvbG9yPSIjMUQzMDRCIiBzdG9wLW9wYWNpdHk9IjAiIG9mZnNldD0iMTAwJSIvPiAgICA8L2xpbmVhckdyYWRpZW50PiAgPC9kZWZzPiAgPHBhdGggZD0iTTE4MzAuMTcxIDEwMTcuNjRjMTYwLjA4NiAwIDcwMi41MjctMjI4LjI2IDI4OS44NjItMjkwLTQxMi42NjYtNjEuNzM3LTEyOS43NzYtMjkwLTI4OS44NjItMjkwcy0yODkuODYxIDEyOS44MzgtMjg5Ljg2MSAyOTBjMCAxNjAuMTYzIDEyOS43NzUgMjkwIDI4OS44NjEgMjkweiIgdHJhbnNmb3JtPSJzY2FsZSgtMSAxKSByb3RhdGUoLTYgLTU4NTQuMTU0IDIyMTE0Ljg1NykiIGZpbGw9InVybCgjYSkiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjwvc3ZnPg==)}.features-wrap:first-of-type{margin-top:-32px}.features-wrap:last-of-type{margin-bottom:-32px}.feature{padding:32px 30px}}.media .section-inner{padding-bottom:104px}.media .section-paragraph{margin-bottom:48px}.media-canvas{position:relative}.media-canvas svg{position:relative;width:100%;height:auto}.media-canvas::before{content:'';position:absolute;width:320px;height:230px;bottom:-76px;left:calc(50% - 160px);background-image:url(data:image/svg+xml;base64,
PHN2ZyB3aWR0aD0iNTMwIiBoZWlnaHQ9IjM4MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4gICAgPGRlZnM+ICAgICAgICA8bGluZWFyR3JhZGllbnQgeDE9IjguNjg1JSIgeTE9IjIzLjczMyUiIHgyPSI4NS44MDglIiB5Mj0iODIuODM3JSIgaWQ9Im1lZGlhLWlsbHVzdHJhdGlvbi1hIj4gICAgICAgICAgICA8c3RvcCBzdG9wLWNvbG9yPSIjRkZGIiBzdG9wLW9wYWNpdHk9Ii40OCIgb2Zmc2V0PSIwJSIvPiAgICAgICAgICAgIDxzdG9wIHN0b3AtY29sb3I9IiNGRkYiIHN0b3Atb3BhY2l0eT0iMCIgb2Zmc2V0PSIxMDAlIi8+ICAgICAgICA8L2xpbmVhckdyYWRpZW50PiAgICAgICAgPGxpbmVhckdyYWRpZW50IHgxPSItNS44ODElIiB5MT0iNDIuNzQzJSIgeDI9IjkyLjgyNyUiIHkyPSIwJSIgaWQ9Im1lZGlhLWlsbHVzdHJhdGlvbi1iIj4gICAgICAgICAgICA8c3RvcCBzdG9wLWNvbG9yPSIjRjk0MjVGIiBvZmZzZXQ9IjAlIi8+ICAgICAgICAgICAgPHN0b3Agc3RvcC1jb2xvcj0iI0Y5N0M1OCIgc3RvcC1vcGFjaXR5PSIwIiBvZmZzZXQ9IjEwMCUiLz4gICAgICAgIDwvbGluZWFyR3JhZGllbnQ+ICAgIDwvZGVmcz4gICAgPGcgZmlsbD0ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIj4gICAgICAgIDxjaXJjbGUgZmlsbD0idXJsKCNtZWRpYS1pbGx1c3RyYXRpb24tYSkiIGN4PSIyNzYiIGN5PSIxOTAiIHI9IjE5MCIvPiAgICAgICAgPHBhdGggZD0iTTU1MS41MzcgMjM3Ljg1N2MtNzMuNzg3IDYxLjgwMS0xMTcuMTk3IDkwLjY1Ny0xMzAuMjMgODYuNTY5LTE5LjU1Mi02LjEzMyA5LjE0LTE5LjUwNC0xNS4yMDQtNDIuMTc0LTE2LjIyOS0xNS4xMTMtODkuMDI3IDIuMzQyLTIxOC4zOTIgNTIuMzY1QzY0Ljg0NyAzNzMuNTE0IDIuMzA5IDM2MS41MTEuMDk1IDI5OC42MDctMi4xMTggMjM1LjcwNCAzNC4yMTIgMTg1LjE2OCAxMDkuMDg1IDE0N2wzNTMuNjMxIDQuMTY0IDg4LjgyIDY5LjczNnYxNi45NTd6IiBmaWxsPSJ1cmwoI21lZGlhLWlsbHVzdHJhdGlvbi1iKSIvPiAgICAgICAgPHBhdGggZmlsbD0iI0ZGRiIgZD0iTTMwOS4zOTIgMjgzbDMuNjI0IDEuNjY3Ljk4NCAzLjUzLTEuMTU4IDMuMzYtMy40NSAxLjQ0My0zLjI0OS0xLjYzOS0yLjE0My0zLjE2NSAxLjYyLTMuNjc0eiIvPiAgICAgICAgPHBhdGggZmlsbD0iIzU1NkI4QiIgZD0iTTM3MS42OTYgMjkybDEuODEyLjgzMy40OTIgMS43NjUtLjU3OSAxLjY4LTEuNzI1LjcyMi0xLjYyNC0uODItMS4wNzItMS41ODIuODEtMS44Mzd6TTMzNy42OTYgMzU5bDEuODEyLjgzMy40OTIgMS43NjUtLjU3OSAxLjY4LTEuNzI1LjcyMi0xLjYyNC0uODItMS4wNzItMS41ODIuODEtMS44Mzd6Ii8+ICAgICAgICA8cGF0aCBmaWxsPSIjNzQ4N0EzIiBkPSJNMzE1LjMxNCAzMTVsMi44OTkgMS4zMzQuNzg3IDIuODIzLS45MjYgMi42ODgtMi43NiAxLjE1NS0yLjYtMS4zMS0xLjcxNC0yLjUzMyAxLjI5NS0yLjk0ek0zNDYuMzE0IDMyMWwyLjg5OSAxLjMzNC43ODcgMi44MjMtLjkyNiAyLjY4OC0yLjc2IDEuMTU1LTIuNi0xLjMxLTEuNzE0LTIuNTMzIDEuMjk1LTIuOTR6Ii8+ICAgICAgICA8cGF0aCBmaWxsPSIjNTU2QjhCIiBkPSJNMzczLjY5NiAzNjRsMS44MTIuODMzLjQ5MiAxLjc2NS0uNTc5IDEuNjgtMS43MjUuNzIyLTEuNjI0LS44Mi0xLjA3Mi0xLjU4Mi44MS0xLjgzN3pNNDA5LjY5NiAzMjZsMS44MTIuODMzLjQ5MiAxLjc2NS0uNTc5IDEuNjgtMS43MjUuNzIyLTEuNjI0LS44Mi0xLjA3Mi0xLjU4Mi44MS0xLjgzN3pNMzc5LjY5NiAzMjZsMS44MTIuODMzLjQ5MiAxLjc2NS0uNTc5IDEuNjgtMS43MjUuNzIyLTEuNjI0LS44Mi0xLjA3Mi0xLjU4Mi44MS0xLjgzN3pNNDE5LjYxOCAzNDZsMS4wODcuNS4yOTUgMS4wNTktLjM0NyAxLjAwOC0xLjAzNS40MzMtLjk3NS0uNDkyLS42NDMtLjk1LjQ4Ni0xLjEwMXoiLz4gICAgPC9nPjwvc3ZnPg==);background-repeat:no-repeat;background-size:320px 230px}.media-control{position:absolute;top:calc(50% - 24px);left:calc(50% - 24px);cursor:pointer}.media-control svg{width:48px;height:48px;overflow:visible}@media (min-width: 641px){.media .section-inner{padding-bottom:144px}.media .section-paragraph{padding-left:72px;padding-right:72px;margin-bottom:80px}.media-canvas::before{width:530px;height:380px;bottom:-128px;left:calc(50% - 275px);background-size:530px 380px}.media-control{top:calc(50% - 48px);left:calc(50% - 48px)}.media-control svg{width:96px;height:96px}}.newsletter .section-paragraph{margin-bottom:32px}.newsletter-form{max-width:440px;margin:0 auto}@media (min-width: 641px){.newsletter .section-paragraph{margin-bottom:40px;padding-left:72px;padding-right:72px}}.is-boxed{background:#0b1524}.body-wrap{background:#06101F;overflow:hidden;display:flex;flex-direction:column;min-height:100vh}.boxed-container{max-width:1440px;margin:0 auto;box-shadow:0 16px 48px rgba(6,16,31,0.5)}main{flex:1 0 auto}.section-inner{position:relative;padding-top:48px;padding-bottom:48px}@media (min-width: 641px){.section-inner{padding-top:80px;padding-bottom:80px}}.site-footer{position:relative;font-size:14px;line-height:20px;letter-spacing:0px;color:#556B8B}.site-footer::before{content:'';position:absolute;bottom:0;left:calc(50% - 180px);width:297px;height:175px;background-image:url(data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjk3IiBoZWlnaHQ9IjE3NSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4gIDxkZWZzPiAgICA8bGluZWFyR3JhZGllbnQgeDE9Ijk5LjQzNSUiIHkxPSI4NS4wNzglIiB4Mj0iOC42ODUlIiB5Mj0iMjMuNzMzJSIgaWQ9ImEiPiAgICAgIDxzdG9wIHN0b3AtY29sb3I9IiMxRDMwNEIiIG9mZnNldD0iMCUiLz4gICAgICA8c3RvcCBzdG9wLWNvbG9yPSIjMUQzMDRCIiBzdG9wLW9wYWNpdHk9IjAiIG9mZnNldD0iMTAwJSIvPiAgICA8L2xpbmVhckdyYWRpZW50PiAgPC9kZWZzPiAgPHBhdGggZD0iTTMxOC4xNzEgNzA4LjY0YzE2MC4wODYgMCA3MDIuNTI3LTIyOC4yNiAyODkuODYyLTI5MC00MTIuNjY2LTYxLjczOC0xMjkuNzc2LTI5MC0yODkuODYyLTI5MFMyOC4zMSAyNTguNDc5IDI4LjMxIDQxOC42NGMwIDE2MC4xNjMgMTI5Ljc3NSAyOTAgMjg5Ljg2MSAyOTB6IiB0cmFuc2Zvcm09InJvdGF0ZSgtNiAtOTUwLjAxNiAxMDU2LjE0MykiIGZpbGw9InVybCgjYSkiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPjwvc3ZnPg==);background-repeat:no-repeat}.site-footer a{color:#556B8B;text-decoration:none}.site-footer a:hover,.site-footer a:active{text-decoration:underline}.site-footer-inner{position:relative;display:flex;flex-wrap:wrap;padding-top:48px;padding-bottom:48px}.footer-brand,.footer-links,.footer-social-links,.footer-copyright{flex:none;width:100%;display:inline-flex;justify-content:center}.footer-brand,.footer-links,.footer-social-links{margin-bottom:24px}.footer-links li+li,.footer-social-links li+li{margin-left:16px}.footer-social-links li{display:inline-flex}.footer-social-links li a{padding:8px}@media (min-width: 641px){.site-footer{margin-top:20px}.site-footer-inner{justify-content:space-between;padding-top:64px;padding-bottom:64px}.footer-brand,.footer-links,.footer-social-links,.footer-copyright{flex:50%}.footer-brand,.footer-copyright{justify-content:flex-start}.footer-links,.footer-social-links{justify-content:flex-end}.footer-links{order:1;margin-bottom:0}}
#pagewrapper {padding: 0; min-height: 100vh;}
body.has-navbar-fixed-top, html.has-navbar-fixed-top {padding-top: 0;}
#background {display: none;}
footer {font-size: 95%;}
kbd {padding: .2rem .4rem; font-size: 80%; color: #fff; background-color: #212529; border-radius: .2rem; word-break: break-all;}
form h3 {color: black;}
.navbar #navbarMain a.nav-link {color: white;}
h1, h2, h3, h4 {color: black;}
#welcome h1, #welcome h2, #welcome h3, #welcome h4 {color: white;}
.installmethod {height: 100%; word-break: break-all; background-color: #ecececf2; border-radius: 10px; padding: 4px 10px 4px 10px; color: black;}
.installmethod h4 {margin-top: 15px; color: black; margin-bottom: 15px; font-size: 26px;}
main {padding-top: 40px;}"""

  officialJs* = """!function(){
const $wel = document.querySelector("#welcome");
if ($wel != null) {  
  const t=window,e=document.documentElement;if(e.classList.remove("no-js"),e.classList.add("js"),document.body.classList.contains("has-animations")){const t=window.sr=ScrollReveal();t.reveal(".feature",{duration:600,distance:"20px",easing:"cubic-bezier(0.5, -0.01, 0, 1.005)",origin:"right",interval:100}),t.reveal(".media-canvas",{duration:600,scale:".95",easing:"cubic-bezier(0.5, -0.01, 0, 1.005)",viewFactor:.5})}const n=document.querySelector(".device-mockup");function i(){n.classList.add("has-loaded")}n.complete?i():n.addEventListener("load",i);const s=document.querySelector(".features"),a=s.querySelector(".section-title"),o=document.querySelector(".feature-inner");function r(){let t=s.querySelector(".features-inner").getBoundingClientRect().left,e=o.getBoundingClientRect().left,n=parseInt(e-t);a.style.marginLeft=e>t?`${n}px`:0}r(),t.addEventListener("resize",r);const c=document.querySelectorAll(".is-moving-object");let l=0,d=0,u=0,g=0,f=0,m=e.clientWidth,p=e.clientHeight;c&&t.addEventListener("mousemove",function(t,e){let n=null,i=e;return(...e)=>{let s=Date.now();(!n||s-n>=i)&&(n=s,t.apply(this,e))}}(function(e){!function(e,n){l=e.pageX,d=e.pageY,u=t.scrollY,g=m/2-l,f=p/2-(d-u);for(let t=0;t<n.length;t++){const e=n[t].getAttribute("data-translating-factor")||20,i=n[t].getAttribute("data-rotating-factor")||20,s=n[t].getAttribute("data-perspective")||500;let a=[];n[t].classList.contains("is-translating")&&a.push("translate("+g/e+"px, "+f/e+"px)"),n[t].classList.contains("is-rotating")&&a.push("perspective("+s+"px) rotateY("+-g/i+"deg) rotateX("+f/i+"deg)"),(n[t].classList.contains("is-translating")||n[t].classList.contains("is-rotating"))&&(a=a.join(" "),n[t].style.transform=a,n[t].style.transition="transform 1s ease-out",n[t].style.transformStyle="preserve-3d",n[t].style.backfaceVisibility="hidden")}}(e,c)},150))
}}();"""