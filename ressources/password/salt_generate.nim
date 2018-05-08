import math, random


randomize()


proc randomSalt*(): string =
  ## Generate a random salt
  ## Seconf priority salting

  result = ""
  for i in 0..127:
    var r = rand(225)
    if r >= 32 and r <= 126:
      result.add(chr(rand(225)))


proc devRandomSalt*(): string =
  ## Generate random salt
  ## First priority salting

  when defined(posix):
    result = ""
    var f = open("/dev/urandom")
    var randomBytes: array[0..127, char]
    discard f.readBuffer(addr(randomBytes), 128)
    for i in 0..127:
      if ord(randomBytes[i]) >= 32 and ord(randomBytes[i]) <= 126:
        result.add(randomBytes[i])
    f.close()
  else:
    result = randomSalt()


proc makeSalt*(): string =
  ## Creates a salt using a cryptographically secure random number generator.
  ##
  ## Ensures that the resulting salt contains no ``\0``.

  try:
    result = devRandomSalt()
  except IOError:
    result = randomSalt()

  var newResult = ""
  for i in 0..<result.len:
    if result[i] != '\0':
      newResult.add result[i]
  return newResult