## Static integer constants, do NOT put any run-time logic here, only consts.
## Do NOT import this file directly, instead import ``constants.nim``


const  # nimwcpkg/database/create_adminuser.nim
  nameMinLen* = 3

  nameMaxLen* = 60

  emailMinLen* = 5

  emailMaxLen* = 255

  passwordMinLen* = 9

  passwordMaxLen* = 301
