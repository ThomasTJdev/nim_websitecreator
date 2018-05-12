
/*
    Check if data is saved
*/
$(function() {
  $(window).bind("beforeunload", function() {
    if ($("#save").attr("data-ischanged") == "1") {
      return "You have unsaved changes that is not saved. Change page?";
    }
  });

  $(document).submit(function(){
    $("#save").attr("data-ischanged", "0")
  });
});


/*
    Submit form
    - Disable codeview to get container data
*/
$(function() {
  $( ".settingsSaveCode" ).click(function() {
    $(".btn-codeview").click();
    $("#settingsEdit").submit();
  });

  $( ".settingsSave" ).click(function() {
    $(".btn-codeview").click();
    $("#settingsEdit").submit();
  });
});



/*
    Summernote initialize
*/
$(function() {
  $('#summernote').summernote({
    minHeight: 300,
    toolbar: [
      // [groupName, [list of button]]
      ['insert', ['bricks']],
      ['style', ['style', 'fontname', 'fontsize', 'bold', 'italic', 'underline']],
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




  $('#summernoteSettings1').summernote({
    height: 300,
    minHeight: null,
    maxHeight: null,
    //focus: true
    toolbar: [
      ['misc', ['codeview', 'fullscreen']]
    ],
    codemirror: { 
      theme: 'monokai'
    },
    callbacks: {
      onInit: function() {
        $('#summernoteSettings1').summernote('codeview.activate');
      },
      onKeydown: function(e) {
        $("#save").attr("data-ischanged", "1");
      }
    }
  });
  $('#summernoteSettings2').summernote({
    height: 300,
    minHeight: null,
    maxHeight: null,
    //focus: true
    toolbar: [
      ['misc', ['codeview', 'fullscreen']]
    ],
    codemirror: { 
      theme: 'monokai'
    },
    callbacks: {
      onInit: function() {
        $('#summernoteSettings2').summernote('codeview.activate');
      },
      onKeydown: function(e) {
        $("#save").attr("data-ischanged", "1");
      }
    }
  });
  $('#summernoteSettings3').summernote({
    height: 300,
    minHeight: null,
    maxHeight: null,
    toolbar: [
      ['misc', ['codeview', 'fullscreen']]
    ],
    codemirror: { 
      theme: 'monokai'
    },
    callbacks: {
      onInit: function() {
        $('#summernoteSettings3').summernote('codeview.activate');
      },
      onKeydown: function(e) {
        $("#save").attr("data-ischanged", "1");
      }
    }
  });


  $('#summernoteSettingsCode').summernote({
    minHeight: 300,
    toolbar: [
      ['misc', ['codeview', 'fullscreen']]
    ],
    codemirror: { 
      theme: 'monokai'
    },
    callbacks: {
      onInit: function() {
        $('#summernoteSettingsCode').summernote('codeview.activate');
      },
      onKeydown: function(e) {
        $("#save").attr("data-ischanged", "1");
      }
    }
  });
});