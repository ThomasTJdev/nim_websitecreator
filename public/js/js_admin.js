/*
    Plugins
*/
const $btnEnablePlugin = document.querySelectorAll(".enablePlugin");
const $btnDisablePlugin = document.querySelectorAll(".disablePlugin");
if ($btnEnablePlugin.length) {
  $btnEnablePlugin.forEach( el => {
    el.addEventListener('click', function(event) {
      let elParent = event.srcElement.parentNode;
      let pluginName = elParent.getAttribute("data-plugin")
      let pluginStatus = elParent.getAttribute("data-enabled")
      pluginChangeStatus(pluginName, pluginStatus)
    });
  });
}
if ($btnDisablePlugin.length) {
  $btnDisablePlugin.forEach( el => {
    el.addEventListener('click', function(event) {
      let elParent = event.srcElement.parentNode;
      let pluginName = elParent.getAttribute("data-plugin")
      let pluginStatus = elParent.getAttribute("data-enabled")
      pluginChangeStatus(pluginName, pluginStatus)
    });
  });
}
function pluginChangeStatus(pluginName, pluginStatus) {
  window.location.href = "/plugins/status?pluginname=" + pluginName + "&status=" + pluginStatus;
}


/*
    Settings
*/
const btnTemplateCode = document.querySelector("button.templateCode");
if (btnTemplateCode != null) {
  btnTemplateCode.addEventListener('click', function () {
    document.querySelectorAll("pre.templateCode").forEach( el => {
      el.classList.toggle("hidden");
    });
  });
}



/*
    Files
*/
const btnFileAdd = document.querySelector("button.fileAdd");
const btnFileUpload = document.querySelector("button.fileUpload");
const $btnFileDelete = document.querySelectorAll("span.deleteFile");
if (btnFileAdd != null) {
  btnFileAdd.addEventListener('click', function () {
    document.querySelector("form#fileAdd").classList.toggle("hidden");
  });
  btnFileUpload.addEventListener('click', function () {
    uploadFile();
  });
}
if ($btnFileDelete.length) {
  $btnFileDelete.forEach( el => {
    el.addEventListener('click', function (event) {
      var result = confirm("Delete file?");
      if (result) {
        window.location.href = event.srcElement.getAttribute("data-url");
      }
    });
  });
}

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
const btnUserAdd = document.querySelector("button.usersAdd");
if (btnUserAdd != null) {
  btnUserAdd.addEventListener('click', function () {
    document.querySelector("form#usersAdd").classList.toggle("hidden");
  });
}


/*
  Users profile
*/

/*
    Modal: Profile picture
_____________________*/
const btnPictureEdit = document.querySelector("#userPictureEdit");
if (btnPictureEdit != null) {
  btnPictureEdit.addEventListener('click', function () {
    profilePictureUpdate(document.getElementById("userPictureEdit"));
  });
}

$(function() {
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