/*
    Navbar
*/

$(document).ready(function() {
  $("nav#navbar div.navbar-toggler.mainMenu").click(function() {
    $("nav#navbar div#mobileMenu").show(350);
    setTimeout(function(){
      $("nav#navbar div#mobileMenu").addClass("active");
    }, 350);
  });
  $("nav#navbar div#mobileMenu div.navbar-toggler").click(function() {
    $("nav#navbar div#mobileMenu").hide(350);
    $("nav#navbar div#mobileMenu").removeClass("active");
  });

});



/*
  Design / Animation
*/
$(function() {
  $('#background').fadeTo(1500, 0.50);
});
if ($('#frontpageContainer').length) {
  setTimeout(function(){
    $("#frontpageContainer .title h1").addClass("reveal-show");
  	$("#frontpageContainer .title h2").addClass("reveal-show");
  }, 600);
  
  $(window).scroll(function() {
     var hT = $('#frontpageContainer .text2').offset().top,
         hH = $('#frontpageContainer .text2').outerHeight(),
         wH = $(window).height(),
         wS = $(this).scrollTop();
     if (wS > (hT+hH-wH) && (hT > wS) && (wS+wH > hT+hH)){
        $('#frontpageContainer .text2').addClass('reveal-show')
     }
  });

  $(window).scroll(function() {
     var hT = $('#frontpageContainer .text5 .sub1').offset().top,
         hH = $('#frontpageContainer .text5 .sub1').outerHeight(),
         wH = $(window).height(),
         wS = $(this).scrollTop();
     if (wS > (hT+hH-wH) && (hT > wS) && (wS+wH > hT+hH)){
        $('#frontpageContainer .text5 .sub1').addClass('reveal-show')
     }
  });

  $(window).scroll(function() {
     var hT = $('#frontpageContainer .text5 .sub2').offset().top,
         hH = $('#frontpageContainer .text5 .sub2').outerHeight(),
         wH = $(window).height(),
         wS = $(this).scrollTop();
     if (wS > (hT+hH-wH) && (hT > wS) && (wS+wH > hT+hH)){
        $('#frontpageContainer .text5 .sub2').addClass('reveal-show')
     }
  });
}

if ($('#aboutContainer').length) {
  setTimeout(function(){
    $("#aboutContainer .title").addClass("reveal-show");
  }, 600);
}
      

$('a[href*="#"]:not([href="#"])').click(function() {
  if($(this).hasClass("jump")){
    var offset = -97; // <-- change the value here
    if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
        var target = $(this.hash);
        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
        if (target.length) {
            $('html, body').animate({
                scrollTop: target.offset().top + offset
            }, 800);
            return false;
        }
    }
  }
});

