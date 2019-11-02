/*
  Core
*/
const btnRestart = document.querySelector("a.restartServer");
if (btnRestart != null) {
  btnRestart.addEventListener('click', function () {
    var result = confirm("This will restart NimWC. Are you sure?");
    if (result) {
      var xmlHttp = new XMLHttpRequest();
      xmlHttp.open( "GET", "/settings/forcerestart", false ); // false for synchronous request
      try {
        xmlHttp.send( null );
      }
      catch(err) {
        alert("Restart in progress. Wait a few seconds and then reload the page.");
      }
    }
  });
}


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
    Files
*/
const $btnFileDelete = document.querySelectorAll("span.deleteFile");
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
  var access    = $("input[name=fileRadio]:checked").attr("data-value");
  var webp      = $("#webpstatus").is(":checked");
  var norm      = $("#lowercase").is(":checked");
  var chks      = $("#checksum").is(":checked");
  var file      = $("#file").get(0).files[0];
  var filename  = file.name;
  var formData  = new FormData();
  formData.append('file', file);
  $.ajax({
    url: "/files/upload/" + access + "?webpstatus=" + webp + "&lowercase=" + norm + "&checksum=" + chks,
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

const $btnUserDelete = document.querySelectorAll("span.deleteUser");
if ($btnUserDelete.length) {
  $btnUserDelete.forEach(el => {
    el.addEventListener('click', function (event) {
      var result = confirm("Delete user?");
      if (result) {
        window.location.href = event.srcElement.getAttribute("data-url");
      }
    });
  });
}



/*
  Users profile
*/
/*
    2FA
_____________________*/
$(function() {
  $(".show2fa").click(function () {
    $(".twofa-container").css("display", "inline-block");
    $(".show2fa").hide();
  });
  $(".test2fa").click(function () {
    var twofaTest = $("#twofa-testcode").val();
    var twofaKey = $("#twofa-key").val();
    twoFAtest(twofaTest, twofaKey);
  });
  $(".save2fa").click(function () {
    var twofaKey = $("#twofa-key").val();
    twoFAsave(twofaKey);
  });
  $(".disable2fa").click(function () {
    twoFAdisable();
  });
});

function twoFAtest(twofaTest, twofaKey) {
  $.ajax({
    url: "/users/profile/update/test2fa?twofakey=" + twofaKey + "&testcode=" + twofaTest,
    type: 'POST',
    success: function(response) {
      if (response.slice(0,5) == "Error") {
        alert("WARNING: The code did not match!");
        $("#twofa-testcode").css("background-color", "#ff6363");
        $(".save2fa").hide();
      } else {
        $("#twofa-testcode").css("background-color", "#a1ffb1");
        $(".save2fa").show();
      }
    }
  });
}
function twoFAsave(twofaKey) {
  $.ajax({
    url: "/users/profile/update/save2fa?twofakey=" + twofaKey,
    type: 'POST',
    success: function(response) {
      if (response.slice(0,5) == "Error") {
        alert("Error, something went wrong");
      } else {
        location.reload();
      }
    }
  });
}
function twoFAdisable() {
  $.ajax({
    url: "/users/profile/update/disable2fa",
    type: 'POST',
    success: function(response) {
      if (response.slice(0,5) == "Error") {
        alert("Error, something went wrong");
      } else {
        location.reload();
      }
    }
  });
}


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
        location.reload();
      }
    }
  });
}
