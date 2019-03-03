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
      try {
        document.querySelector(this.getAttribute('href')).scrollIntoView({
          behavior: 'smooth'
        });
      }
      catch(err) {
        console.log("Debug: Just a clickable element")
      }
  });
});


/*
  Animations
*/
var animation_elements = document.querySelectorAll('.reveal');
var web_window = window;

function parentOffsetTop( elem ) {
  var location = 0;
  if (elem.offsetParent) {
    do {
      location += elem.offsetTop;
      elem = elem.offsetParent;
    } while (elem);
  }
  return location >= 0 ? location : 0;
};

function check_if_in_view() {
  var window_height = web_window.innerHeight;
  var window_top_position = web_window.scrollY;
  var window_bottom_position = (window_top_position + window_height);

  Array.prototype.forEach.call(animation_elements, function(el, i){
    var element = el;
    var element_height = el.offsetHeight;
    var element_top_position = parentOffsetTop(el);
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
