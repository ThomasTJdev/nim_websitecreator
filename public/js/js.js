/*
  Navbar
*/
// Bulma
const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
if ($navbarBurgers.length > 0) {
  $navbarBurgers.forEach( el => {
    el.addEventListener('click', () => {
      const target = el.dataset.target;
      const $target = document.getElementById(target);
      el.classList.toggle('is-active');
      $target.classList.toggle('is-active');

      var element = document.getElementById("navbarSettings")
      if (element != null) {
        element.classList.toggle("is-invisible");
      }
    });
  });
}

// Boostrap
const $bsNavMobile = document.querySelector("nav#navbar div#mobileMenu");
if ($bsNavMobile != null) {
  document.querySelector("nav#navbar div.navbar-toggler.mainMenu").addEventListener('click', function () {
    $bsNavMobile.classList.remove("hidden");
  });
  document.querySelector("nav#navbar #mobileMenu div.navbar-toggler").addEventListener('click', function () {
    $bsNavMobile.classList.add("hidden");
  });
}


/*
  Smooth scroll on anchor links
*/
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
      e.preventDefault();

      document.querySelector(this.getAttribute('href')).scrollIntoView({
          behavior: 'smooth'
      });
  });
});


/*
  Load JS and CSS files dynamic
*/
// Load JS
function loadScript(content) {
  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = content;
  document.body.appendChild(script);
}
// Load CSS style
function loadStyle(content) {
  var fileref = document.createElement("link");
  fileref.rel = "stylesheet";
  fileref.type = "text/css";
  fileref.href = content;
  document.getElementsByTagName("head")[0].appendChild(fileref)
}
window.onload = function(){
  const $prism = document.querySelector("prismOn");
  if ($prism != null) {
    loadStyle("https://cdnjs.cloudflare.com/ajax/libs/prism/1.15.0/themes/prism.min.css")
    loadScript("https://cdnjs.cloudflare.com/ajax/libs/prism/1.15.0/prism.min.js")

    loadStyle("https://cdnjs.cloudflare.com/ajax/libs/prism/1.15.0/plugins/line-numbers/prism-line-numbers.min.css")
    loadScript("https://cdnjs.cloudflare.com/ajax/libs/prism/1.15.0/plugins/line-numbers/prism-line-numbers.min.js")

    loadScript("https://cdnjs.cloudflare.com/ajax/libs/prism/1.15.0/components/prism-nim.min.js")
    loadScript("https://cdnjs.cloudflare.com/ajax/libs/prism/1.15.0/components/prism-css.min.js")
    loadScript("https://cdnjs.cloudflare.com/ajax/libs/prism/1.15.0/components/prism-javascript.min.js")
    loadScript("https://cdnjs.cloudflare.com/ajax/libs/prism/1.15.0/components/prism-python.min.js")
    loadScript("https://cdnjs.cloudflare.com/ajax/libs/prism/1.15.0/components/prism-bash.min.js")
  }
}


/*
  Animations
*/
var animation_elements = document.querySelectorAll('.reveal');
var animation_elements_bottom = document.querySelectorAll('.reveal-bottom');
var animation_elements_left = document.querySelectorAll('.reveal-left');
var animation_elements_right = document.querySelectorAll('.reveal-right');
var web_window = window;

function check_if_in_view() {
  var window_height = web_window.innerHeight;
  var window_top_position = web_window.scrollY;
  var window_bottom_position = (window_top_position + window_height);

  Array.prototype.forEach.call(animation_elements, function(el, i){
    var element = el;
    var element_height = el.offsetHeight;
    var element_top_position = el.offsetTop;
    var element_bottom_position = (element_top_position + element_height);

    if ((element_bottom_position >= window_top_position) && (element_top_position <= window_bottom_position)) {
      if (el.classList.contains("reveal-bottom")) {
          el.classList.add('slide-bottom');
      } else if (el.classList.contains("reveal-right")) {
          el.classList.add('slide-right');
      } else if (el.classList.contains("reveal-left")) {
          el.classList.add('slide-left');
      }
    }
  });
}

window.addEventListener("scroll", check_if_in_view);
check_if_in_view();
