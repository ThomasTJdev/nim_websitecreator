import md5, random

var urandom: File
let useUrandom = urandom.open("/dev/urandom")


{.compile: "bcrypt/arc4random.c", compile: "bcrypt/blowfish.c", compile: "bcrypt/crypt-blowfish.c", pragma: mydll.}

func bcrypt_gensalt(rounds: int8): cstring        {.cdecl, mydll, importc: "bcrypt_gensalt".}
func blowfish(key, salt, encrypted: cstring): int {.cdecl, mydll, importc: "crypt_blowfish".}
func compare_string(s1, s2: cstring): int         {.cdecl, mydll, importc: "compare_string".}

func genSalt*(rounds: int8): string {.inline.} =  $(bcrypt_gensalt(rounds))

func compare*(s1, s2: string): bool {.inline.} =  compare_string(s1, s2) != 0

func hash*(key, salt: string): string =
  var encrypted = newString(60)
  var ret {.used.} = blowfish(key, salt, encrypted.cstring)
  result = $encrypted


proc makeSalt*(): string =
  ## Generate random salt. Uses cryptographically secure /dev/urandom
  if likely(useUrandom):
    var randomBytes: array[0..127, char]
    discard urandom.readBuffer(addr(randomBytes), 128)
    for ch in randomBytes:
      if ord(ch) in {32..126}:
        result.add(ch)
  else:  # Fallback to Nim random when no /dev/urandom
    for i in 0..127:
      result.add(chr(rand(94) + 32)) # Generate numbers from 32 to 94 + 32 = 126


proc makeSessionKey*(): string =
  ## Creates a random key to be used to authorize a session.
  hash(makeSalt(), genSalt(8))


proc makePassword*(password, salt: string, comparingTo = ""): string =
  ## Creates an MD5 hash by combining password and salt.
  assert password.len > 3 and password.len < 301
  hash(getMD5(salt & getMD5(password)), if comparingTo != "": comparingTo else: genSalt(8))
