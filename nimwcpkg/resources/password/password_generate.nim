import md5, bcrypt, ../password/salt_generate


proc makeSessionKey*(): string {.inline.} =
  ## Creates a random key to be used to authorize a session.
  bcrypt.hash(makeSalt(), genSalt(8))


proc makePassword*(password, salt: string, comparingTo = ""): string {.inline.} =
  ## Creates an MD5 hash by combining password and salt.
  assert password.len > 0, "password must not be empty string"
  assert salt.len > 0, "salt must not be empty string"
  hash(getMD5(salt & getMD5(password)), if comparingTo != "": comparingTo else: genSalt(8))
