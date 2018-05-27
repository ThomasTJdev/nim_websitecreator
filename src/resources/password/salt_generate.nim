import math, random, os
randomize()

var urandom: File
let useUrandom = urandom.open("/dev/urandom")

proc makeSalt*(): string =
  ## Generate random salt. Uses cryptographically secure /dev/urandom
  ## on platforms where it is available, and Nim's random module in other cases.
  result = ""
  if not useUrandom:
    var randomBytes: array[0..127, char]
    discard urandom.readBuffer(addr(randomBytes), 128)
    for ch in randomBytes:
      if ord(ch) in {32..126}:
        result.add(ch)
  else:
    for i in 0..127:
      result.add(chr(rand(94) + 32)) # Generate numbers from 32 to 94 + 32 = 126
