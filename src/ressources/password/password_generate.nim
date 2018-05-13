import md5, bcrypt


proc makePassword*(password, salt: string, comparingTo = ""): string =
  ## Creates an MD5 hash by combining password and salt

  when defined(windows):
    result = getMD5(salt & getMD5(password))
  else:
    let bcryptSalt = if comparingTo != "": comparingTo else: genSalt(8)
    result = hash(getMD5(salt & getMD5(password)), bcryptSalt)