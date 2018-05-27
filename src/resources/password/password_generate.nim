import md5, bcrypt


import ../password/salt_generate


proc makeSessionKey*(): string =
  ## Creates a random key to be used to authorize a session.
  let random = makeSalt()
  return bcrypt.hash(random, genSalt(8))


proc makePassword*(password, salt: string, comparingTo = ""): string =
  ## Creates an MD5 hash by combining password and salt
  let bcryptSalt = if comparingTo != "": comparingTo else: genSalt(8)
  result = hash(getMD5(salt & getMD5(password)), bcryptSalt)