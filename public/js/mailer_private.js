/* This plugin js_private.js file will be added to the public folder, but no automated import of the file will be generated */

$(function() {
  $('#summernoteMailer').summernote({
    minHeight: 300,
    toolbar: [
      ['insert', ['bricks']],
      ['style', ['fontname', 'fontsize', 'bold', 'italic', 'underline']],
      ['font', ['strikethrough', 'superscript', 'subscript']],
      ['color', ['color']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['height', ['height']],
      ['misc', ['codeview', 'fullscreen']]
    ],
    codemirror: { 
      theme: 'monokai'
    },
    callbacks: {
      onKeydown: function(e) {
        $("#save").attr("data-ischanged", "1");
      }
    }
  });

  if ($("form.mailerForm").length > 0) {
    var actionurl = $("form.mailerForm").attr("action");
    $("form.mailerForm").attr("action", actionurl + "&timezone=" + getTimeZone());
  };

});

function getTimeZone() {
  var offset = new Date().getTimezoneOffset(),
      o = Math.abs(offset);
  return (offset < 0 ? "+" : "-") + ("00" + Math.floor(o / 60)).slice(-2);
}