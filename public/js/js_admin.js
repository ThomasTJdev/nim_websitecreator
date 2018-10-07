/*
    Plugins
*/
$(document).ready(function() {
  $( ".enablePlugin" ).click(function() {
    var pluginName = $(this).parent("li.pluginSettings").attr("data-plugin");
    var pluginStatus = $(this).parent("li.pluginSettings").attr("data-enabled");
    pluginChangeStatus(pluginName, pluginStatus)
  });
  $( ".disablePlugin" ).click(function() {
    var pluginName = $(this).parent("li.pluginSettings").attr("data-plugin");
    var pluginStatus = $(this).parent("li.pluginSettings").attr("data-enabled");
    pluginChangeStatus(pluginName, pluginStatus)
  });
});
function pluginChangeStatus(pluginName, pluginStatus) {
  window.location.href = "/plugins/status?pluginname=" + pluginName + "&status=" + pluginStatus;
}


/*
    Settings
*/
$(document).ready(function() {
  $( "button.settingsRestore" ).click(function() {
    if (!confirm("This will delete/restore the title, head, navbar and footer.\nAre you sure?")) e.preventDefault();
    window.location.href = "/settings/editrestore";
  });

  $("button.templateCode").click(function() {
    $("pre.templateCode").toggle();
  });
});




/*
    Files
*/
$(document).ready(function() {
  $( "button.fileAdd" ).click(function() {
    $("form#fileAdd").toggle();
  });
  $( "button.fileUpload" ).click(function() {
    uploadFile();
  });
  $( "span.deleteFile" ).click(function() {
    var result = confirm("Delete file?");
    if (result) {
      window.location.href = $(this).attr("data-url");
    }
  });

});

function uploadFile(projectID) {
  var access    = $('input[name=fileRadio]:checked').attr("data-value");
  var file      = $('#file').get(0).files[0];
  var filename  = file.name;
  var formData  = new FormData();
  formData.append('file', file);
  $.ajax({
    url: "/files/upload/" + access,
    data: formData,
    type: 'POST',
    cache: false,
    contentType: false,
    processData: false,
    success: function(response) {
      if (response.slice(0,5) == "Error") {
        alert(response)
      } else {
        window.location.href = "/files";
      }
    },
    error: function (e) {
      notifyError("Error: An error occurred");
    }
  });
  return false;
}



/*
  Users
*/
$(function() {
  $('button.usersAdd').click(function () {
    $("form#usersAdd").toggle();
  });
});



/*
  Users profile
*/

/*
    Modal: Profile picture
_____________________*/
$(function() {
  $('#userPictureEdit').click(function () {
    profilePictureUpdate($("#userPictureEditTemp"));
  });
  $('#userPictureSave').click(function () {
    var croppedCanvas = $("#userPictureEdit").cropper('getCroppedCanvas', {
      width: 80,
      height: 80,
      fillColor: '#fff',
      imageSmoothingEnabled: false,
      imageSmoothingQuality: 'medium',
    });

    var dataURL = croppedCanvas.toDataURL('image/png');
    $("#userProfilePicture").attr("src", dataURL);
    userUploadProfilePictures(dataURL);
  });

  $('#userPictureNewdata').click(function () {
    $("#userPictureEditTemp").trigger( "click" );
  });

  $("#userPictureEditTemp").change(function() {
    profilePictureUpdate(this);
  });
});

function profilePictureUpdate(obj) {
  $("#userPictureSave").show(200);
  $("#userPictureEdit").cropper("destroy");
  
  if (obj.files && obj.files[0]) {
    var reader = new FileReader();
    console.log("OK");
    reader.onload = function(e) {
      $('#userPictureEdit').attr("src", e.target.result);
    }
    reader.readAsDataURL(obj.files[0]);
  }
  setTimeout(function(){ 
    $("img#userPictureEdit").cropper({
      viewMode: 1,
      aspectRatio: 1 / 1
    });
   }, 1200);
}

function userUploadProfilePictures(dataURL) {
  $.ajax({
    url: "/users/photo/upload",
    data: dataURL,
    type: 'POST',
    cache: false,
    contentType: false,
    processData: false,
    success: function(response) {
      if (response.slice(0,5) == "Error") {
        console.log("Error: Uploading new image");
      } else {
        $(".alert").show(200);
      }
    }
  });
}