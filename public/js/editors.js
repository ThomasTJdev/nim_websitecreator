/*
    Change editor
*/
$(document).ready(function() {
  $( "a.switchEditorGrapesJS" ).click(function() {
    document.cookie = "editor=grape;path=/"
    window.location = window.location.pathname;
  });

  $( "a.switchEditorSummernote" ).click(function() {
    document.cookie = "editor=summernote;path=/";
    window.location = window.location.pathname;
  });

  $( "a.switchEditorRawHTML" ).click(function() {
    document.cookie = "editor=html;path=/";
    window.location = window.location.pathname;
  });
});


/*
    Blog post
*/
$(document).ready(function() {
  $( "a.blogOptions" ).click(function() {
    $("div.blogOptions.details").toggle();
  });

  $( ".newblogSave" ).click(function() {
    if($('#gjshidden').length > 0){
      $("#gjshidden").val(editor.getHtml() + "<style>" + editor.getCss() + "</style>")
    }
    if($('#summernote').length > 0) {
      $("#summernoteHidden").html($('#summernote').summernote('code'));
    }

    if ($("#name").val() != "" && $("#url").val() != "") {
      $("#blogData form").submit();
    }
  });

  $( ".blogSave" ).click(function() {
    savePage();
  });

  $( "span.blogDelete" ).click(function() {
    var result = confirm("Delete blogpost?");
    if (result) {
      window.location.href = $(this).attr("data-url");
    }
  });
});


/*
    Page
*/
$(document).ready(function() {
  $( "a.pageOptions" ).click(function() {
    $("div.pageOptions.details").toggle();
  });

  $( ".newpageSave" ).click(function() {
    if($('#gjshidden').length > 0){
      $("#gjshidden").val(editor.getHtml() + "<style>" + editor.getCss() + "</style>")
    }
    if($('#summernote').length > 0) {
      $("#summernoteHidden").html($('#summernote').summernote('code'));
    }

    if ($("#name").val() != "" && $("#url").val() != "") {
      $("#pageData form").submit();
    }
  });

  $( ".pageSave" ).click(function() {
    savePage();
  });

  $( "span.pageDelete" ).click(function() {
    var result = confirm("Delete page?");
    if (result) {
      window.location.href = $(this).attr("data-url");
    }
  });
});



/*
    Save page
*/
function savePage() {
  // Check for GrapeJS
  if($('#gjshidden').length > 0 ){
    $("#gjshidden").val(editor.getHtml() + "<style>" + editor.getCss() + "</style>")
  }
  // Check for summernote
  if($('#summernote').length > 0) {
    $("#summernoteHidden").html($('#summernote').summernote('code'));
    charCount = 0;
  }
  // Update preview link
  var previewUrl = "/p/" + $("#url").val();
  if ($(".preview").hasClass("isBlog")) {
    previewUrl = "/blog/" + $("#url").val();
  }
  $(".preview").attr("href", previewUrl);
  // Post data
  $.ajax({
    url: $("form.standard").attr("action") + "?inbackground=true",
    type: 'POST',
    data: $("form.standard").serialize(),
    success: function(response) {
      if (response == "OK") {
        $("#save").attr("data-ischanged", "0");
        $("#notifySaved").css("top", "50%");
        $("#notifySaved").text("Saved");
        $("#notifySaved").show(400);
        setTimeout(function(){
          $("#notifySaved").hide(400);
        }, 1200);
      } else {
        $("#notifySaved").css("background", "#cb274bde");
        $("#notifySaved").css("top", "50%");
        $("#notifySaved").text(response);
        $("#notifySaved").show(400);
        setTimeout(function(){
          $("#notifySaved").hide(400);
          $("#notifySaved").css("background", "#27cb4ede");
        }, 1700);
      }
    }
  });
}


/*
    When checkbox is changed
*/
$(".checkbox").change(function() {
  $("#save").attr("data-ischanged", "1")
});


/*
    Check if data is saved
*/
$(window).bind("beforeunload", function() {
  if ($("#save").attr("data-ischanged") == "1") {
    return "You have unsaved changes that is not saved. Change page?";
  }
});



/*
    Initialize summernote
*/
$(function() {
  if($('#summernote').length) {
    summernoteInit();
  }
});
var charCount = 0;
function summernoteInit() {
  console.log("Summernote initialize");

  var SaveButton = function (context) {
    var ui = $.summernote.ui;

    var button = ui.button({
      contents: '<i class="fa fa-floppy-o"></i> Save',
      click: function () {
        savePage();
      }
    });
    return button.render();
  };

  var CodeButton = function (context) {
    var ui = $.summernote.ui;

    var button = ui.buttonGroup([
      ui.button({
        contents: 'Code block',
        data: { toggle: 'dropdown' },
        click: function () {
          context.invoke('editor.saveRange');
        }
      }),
      ui.dropdown({
        className: 'drodown-style',
        contents: "<ol class='summernote-button'><li data-lang='html'>HTML</li><li data-lang='css'>CSS</li><li data-lang='javascript'>JS</li><li data-lang='nim'>Nim</li><li data-lang='python'>Python</li><li data-lang='bash'>Bash</li></ol>",
        callback: function ($dropdown) {
          $dropdown.find('li').each(function () {
            $(this).click(function(e) {
              context.invoke('editor.restoreRange');
              context.invoke('editor.focus');
              var lang = $(this).attr("data-lang");
              var codeBlock = '<pre><code class="prismOn language-' + lang + ' line-numbers">Place your code here.</code></pre>';
              context.invoke('editor.pasteHTML', '<span id="codeblockReplace"></span>');
              $("span#codeblockReplace").replaceWith(codeBlock);
              Prism.highlightAll();
            });
          });
        }
      })
    ]);
    return button.render();
  }

  var calHeight = 500;
  var gWindowHeight = $(window).height();
  if (gWindowHeight < 700) {
    calHeight = 200;
  } else if (gWindowHeight < 900) {
    calHeight = 450;
  } else if (gWindowHeight < 1200) {
    calHeight = 850;
  } else if (gWindowHeight < 1400) {
    calHeight = 1050;
  }

  $('#summernote').summernote({
    minHeight: 250,
    height: calHeight,
    width: "auto",
    focus: true,
    dialogsInBody: true,
    dialogsFade: true,
    toolbar: [
      ['custom', ['save', 'settings']],
      ['para', ['style']],
      ['fontsize', ['fontsize']],
      ['style', ['bold', 'italic', 'underline', 'clear']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['font', ['strikethrough', 'superscript']],
      ['color', ['color']],
      ['insert', ['picture', 'table', 'link', 'hr', 'codeblock', 'checkbox']],
      ['misc', ['print', 'codeview', 'fullscreen']]
    ],
    buttons: {
      codeblock: CodeButton,
      save: SaveButton
    },
    callbacks: {
      onKeydown: function (e) {
        if (e.keyCode != 116) {
          charCount += 1;
          if (charCount == 2) {
            $("#save").attr("data-ischanged", "1");
            //charCount = 0;
            //savePage();
          }
        }
      },
      onBlur: function () {
        Prism.highlightAll();
      },
      onInit: function () {
        Prism.highlightAll();
      }
    }
  });
}


/*
    Initialize Codemirror editor
*/
$(function() {
  if($('#editordataCodemirror').length > 0 ){
    var editor = CodeMirror.fromTextArea($('#editordataCodemirror')[0], {
      lineNumbers: true,
      lineWrapping: true,
      mode: "htmlmixed",
      autoCloseTags: true,
      tabSize: 2,
      indentWithTabs: false,
      matchTags: {bothTags: true},
      extraKeys: {"Ctrl-J": "toMatchingTag"}
    });
    editor.on('change', function () {
      $("#save").attr("data-ischanged", "1");
      editor.save();
    });

    CodeMirror.commands["selectAll"](editor);
    function getSelectedRange() {
      return { from: editor.getCursor(true), to: editor.getCursor(false) };
    }

    function autoFormatSelection() {
      var range = getSelectedRange();
      editor.autoFormatRange(range.from, range.to);
      $("#save").attr("data-ischanged", "0");
    }
  }


  if($('#htmlSettings1').length > 0 ){
    var settingsCode1 = CodeMirror.fromTextArea($('#htmlSettings1')[0], {
      lineNumbers: true,
      lineWrapping: true,
      mode: "htmlmixed",
      autoCloseTags: true,
      matchTags: {bothTags: true},
      extraKeys: {"Ctrl-J": "toMatchingTag"}
    });
    settingsCode1.on('change', function () {
      $("#save").attr("data-ischanged", "1");
      settingsCode1.save();
    });
  }

  if($('#htmlSettings2').length > 0 ){
    var settingsCode2 = CodeMirror.fromTextArea($('#htmlSettings2')[0], {
      lineNumbers: true,
      lineWrapping: true,
      mode: "htmlmixed",
      autoCloseTags: true,
      matchTags: {bothTags: true},
      extraKeys: {"Ctrl-J": "toMatchingTag"}
    });
    settingsCode2.on('change', function () {
      $("#save").attr("data-ischanged", "1");
      settingsCode2.save();
    });
  }

  if($('#htmlSettings3').length > 0 ){
    var settingsCode3 = CodeMirror.fromTextArea($('#htmlSettings3')[0], {
      lineNumbers: true,
      lineWrapping: true,
      mode: "htmlmixed",
      autoCloseTags: true,
      matchTags: {bothTags: true},
      extraKeys: {"Ctrl-J": "toMatchingTag"}
    });
    settingsCode3.on('change', function () {
      $("#save").attr("data-ischanged", "1");
      settingsCode3.save();
    });
  }

  if($('#settingsCode').length > 0 ){
    var settingsCode = CodeMirror.fromTextArea($('#settingsCode')[0], {
      lineNumbers: true,
      lineWrapping: true,
      autoCloseBrackets: true,
      matchTags: {bothTags: true},
      extraKeys: {"Ctrl-J": "toMatchingTag"}
    });
    settingsCode.on('change', function () {
      $("#save").attr("data-ischanged", "1");
      settingsCode.save();
    });
  }
});




/*!
* jquery.key.js 0.2 - https://github.com/yckart/jquery.key.js
* Copyright (c) 2013 Yannick Albert (http://yckart.com)
* Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php) - 2013/02/09
*/
(function($,document){var keys={a:65,b:66,c:67,d:68,e:69,f:70,g:71,h:72,i:73,j:74,k:75,l:76,m:77,n:78,o:79,p:80,q:81,r:82,s:83,t:84,u:85,v:86,w:87,x:88,y:89,z:90,"0":48,"1":49,"2":50,"3":51,"4":52,"5":53,"6":54,"7":55,"8":56,"9":57,f1:112,f2:113,f3:114,f4:115,f5:116,f6:117,f7:118,f8:119,f9:120,f10:121,f11:122,f12:123,shift:16,ctrl:17,control:17,alt:18,option:18,opt:18,cmd:224,command:224,fn:255,"function":255,backspace:8,osxdelete:8,enter:13,"return":13,space:32,spacebar:32,esc:27,escape:27,tab:9,capslock:20,capslk:20,"super":91,windows:91,insert:45,"delete":46,home:36,end:35,pgup:33,pageup:33,pgdn:34,pagedown:34,left:37,up:38,right:39,down:40,"!":49,"@":50,"#":51,"$":52,"%":53,"^":54,"&":55,"*":56,"(":57,")":48,"`":96,"~":96,"-":45,_:45,"=":187,"+":187,"[":219,"{":219,"]":221,"}":221,"\\":220,"|":220,";":59,":":59,"'":222,'"':222,",":188,"<":188,".":190,">":190,"/":191,"?":191};$.key=$.fn.key=function(code,fn){if(!(this instanceof $)){return $.fn.key.apply($(document),arguments)}
var i=0,cache=[];return this.on({keydown:function(e){var key=e.which;if(cache[cache.length-1]===key)return;cache.push(key);i=key===code[i]||(typeof code==='string'&&key===keys[code.split("+")[i]])?i+1:0;if(i===code.length||(typeof code==='string'&&code.split('+').length===i)){fn(e,cache);i=0}},keyup:function(){i=0;cache=[]}})}})(jQuery,document)

/*
    Key bindings
*/
$(function() {
  $.key('ctrl+s', function() {
    if($('#settingsCode').length > 0 || $('#htmlSettings1').length > 0 || $('#gls').length > 0 || $('#editordataCodemirror').length > 0 || $('#summernote').length > 0){
      event.preventDefault();

      savePage();
    }
  });

});
