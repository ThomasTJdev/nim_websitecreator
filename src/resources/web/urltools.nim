# Copyright 2018 - Thomas T. Jarløv

import strutils

proc urlEncoderCustom*(s: string): string =
  result = newStringOfCap(s.len + s.len shr 2) # assume 12% non-alnum-chars
  for i in 0..s.len-1:
    case s[i]
    of 'a'..'z', 'A'..'Z', '0'..'9', '_', '/': add(result, s[i])
    of ' ': add(result, '+')
    else:
      add(result, '%')
      add(result, toHex(ord(s[i]), 2))
