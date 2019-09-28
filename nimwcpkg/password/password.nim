import md5, bcrypt, contra, random


var urandom: File
let useUrandom = urandom.open("/dev/urandom")


# Order is important here.
include
  "_salt_generate",
  "_password_generate"
