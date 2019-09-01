import md5, bcrypt, contra, ../password/salt_generate


proc makeSessionKey*(): string {.inline.} =
  ## Creates a random key to be used to authorize a session.
  postconditions result.len > 0
  bcrypt.hash(makeSalt(), genSalt(8))


proc makePassword*(password, salt: string, comparingTo = ""): string {.inline.} =
  ## Creates an MD5 hash by combining password and salt.
  preconditions password.len > 3, password.len < 301
  postconditions result.len > 45
  result = hash(getMD5(salt & getMD5(password)), if comparingTo != "": comparingTo else: genSalt(8))
