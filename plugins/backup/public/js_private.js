/*
    New blog post
*/

$(document).ready(function() {
  $( "ul.backup a.load" ).click(function() {
    $(this).parent("li").children("a.loadSure").show();
    $(this).parent("li").children("a.download").hide();
    $(this).hide();
  });

  $( "div.backup.buttons a.backupTime" ).click(function() {
    $("form.backup").toggle();
  });
});