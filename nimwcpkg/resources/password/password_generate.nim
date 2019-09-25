import md5, bcrypt, contra, ../password/salt_generate


template makeSessionKey*(): string =
  ## Creates a random key to be used to authorize a session.
  bcrypt.hash(makeSalt(), genSalt(8))


template makePassword*(password, salt: string, comparingTo = ""): string =
  ## Creates an MD5 hash by combining password and salt.
  preconditions password.len > 3, password.len < 301
  hash(getMD5(salt & getMD5(password)), if comparingTo != "": comparingTo else: genSalt(8))
