## Static string URL Encoded constants, do NOT put any run-time logic here, only consts.
## Do NOT import this file directly, instead import ``constants.nim``
## These are used on ``nimwcpkg/webs/routes.nim``.
from uri import encodeUrl


const
  errNeedToVerifyRecaptcha* =  encodeUrl("You need to verify that you are not a robot!.")

  msgInstallingPlugin* =  encodeUrl("Please wait, installing 1 new Plugin!.")

  msgUninstallingPlugin* =  encodeUrl("Please wait, uninstalling a Plugin!.")

  errGitClonError* = encodeUrl("Unknown Git error while cloning the Plugin repository!.")

  errGitPullError* = encodeUrl("Unknown Git error while pulling the Plugin repository!.")

  errPluginDeleteError* = encodeUrl("Unknown Git error while disabling and deleting the Plugin!. Please ensure that you have disabled the plugin at: ./plugins/")

  errUserAndEmailRequired* = encodeUrl("Name and email are required!.")

  errEmailWrongFormat* = encodeUrl("The email provided has a wrong format!.")

  errPasswordsDontMatch* = encodeUrl("The passwords provided do not match!.")

  errCantDeleteSelf* = encodeUrl("You can not delete yourself!.")

  errUnkownStatusUser* = encodeUrl("Unkown or missing status of the user!.")

  errCantDeleteAdmin* = encodeUrl("You can not delete an Admin user!.")

  errCantDeleteUser* = encodeUrl("Could not delete user!.")

  errCantAddUserWithStat* = encodeUrl("You are not allowed to add a user with this status!.")

  errNameEmailStatusRequired* = encodeUrl("Name, email and status are required!.")

  errTestuserReserved* = encodeUrl("The user with email 'test@test.com' is reserved internally by the system and can not be used!.")

  errUserAlreadyExists* = encodeUrl("A user with that email address already exists!.")

  errBadLink* = encodeUrl("The link provided has a wrong format or has expired!.")

  msgAccountActivated* = encodeUrl("Your user account is now activated!.")

  msgPleaseLogin* = encodeUrl("Please login using your user and password!.")

  errBlogpostAlreadyExists* = encodeUrl("A blogpost with that URL address already exists!.")
