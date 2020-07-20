import macros


template hardenedBuild*() =
  ## See: http:wiki.debian.org/Hardening & http:wiki.gentoo.org/wiki/Hardened_Gentoo
  ## http:security.stackexchange.com/questions/24444/what-is-the-most-hardened-set-of-options-for-gcc-compiling-c-c
  when defined(hardened) and defined(gcc) and not defined(objc) and not defined(js):
    when defined(danger): {.fatal: "-d:hardened is incompatible with -d:danger".}
    {.hint: "Security Hardened mode is enabled.".}
    const hf = "-fstack-protector-all -Wstack-protector --param ssp-buffer-size=4 -pie -fPIE -Wformat -Wformat-security -D_FORTIFY_SOURCE=2 -Wall -Wextra -Wconversion -Wsign-conversion -mindirect-branch=thunk -mfunction-return=thunk -fstack-clash-protection -Wl,-z,relro,-z,now -Wl,-z,noexecstack -fsanitize=signed-integer-overflow -fsanitize-undefined-trap-on-error -fno-common"
    {.passC: hf, passL: hf, assertions: on, checks: on.}


template getLibravatarUrl*(email: string, size: range[1..512] = 100, default = "robohash", forceDefault = false,
    baseUrl = (when defined(ssl): "https://seccdn.libravatar.org/avatar/" else: "http://cdn.libravatar.org/avatar/")): string =
  ## https://wiki.libravatar.org/api & https://wiki.libravatar.org/features
  assert email.len > 5, "email must not be empty string"
  assert email.len < 255, "email must be <255 characters long string"
  assert '@' in email, "email must be a valid standard email address string"
  assert baseUrl.len > 5, "baseUrl must be a valid HTTP URL string"
  (baseUrl & getMD5(email.strip.toLowerAscii) & "?s=" & $size &
    (if unlikely(default != ""): "&d=" & default else: "") &
    (when defined(release): "" else: (if unlikely(forceDefault): "&f=y" else: ""))
  )


template cwebp*(inputFilename: string, outputFilename = "", preset = "drawing",
    verbose = false, threads = true, lossless = false, noalpha = false,
    quality: range[0..100] = 75): tuple[output: TaintedString, exitCode: int] =
  ## Compress an image file to a WebP file. Input format can be either PNG, JPEG, TIFF, WebP.
  assert inputFilename.len > 0, "inputFilename must not be empty string"
  assert preset in ["default", "photo", "picture", "drawing", "icon", "text"]
  execCmdEx(
    (if unlikely(verbose): "cwebp -v " else: "cwebp -quiet ") &
    (if likely(threads): "-mt " else: "") &
    (if unlikely(lossless): "-lossless " else: "") &
    (if unlikely(noalpha): "-noalpha " else: "") &
    "-preset " & preset & " -q " & $quality & " -o " &
    (if outputFilename.len == 0: quoteShell(inputFilename & ".webp") else: quoteShell(outputFilename)) &
    " " & quoteShell(inputFilename)
  )


template `:=`*(name: untyped; value: any) =
  ## Assistent for variables at compile-time. Uses system.nim
  ##
  ## expandMacros:
  ##   foo := 42
  ##
  ## var foo = create(int, sizeOf int)
  ## foo[] = 42
  ##
  ## expandMacros:
  ##   bar := "Hello"
  ##
  ## var bar = create(string, sizeOf string)
  ## bar[] = "Hello"
  ##
  ## https://nim-lang.github.io/Nim/system.html#create%2Ctypedesc
  var name {.inject.} = create(type(value), sizeOf type(value))
  name[] = value


macro deallocs*(variables: varargs[typed]) =
  ## This unrolls destruction of several variables at compile-time. Uses system.nim
  ##
  ## expandMacros:
  ##   deallocs foo, bar, baz
  ##
  ## dealloc foo
  ## dealloc bar
  ## dealloc baz
  ##
  ## https://nim-lang.github.io/Nim/system.html#dealloc.t%2Cpointer
  result = newStmtList() # Creates a list of lines of code to be run.
  for it in variables: result.add newCall(bindSym"dealloc", it) # Fills the list.


macro creates*(value: any; variables: varargs[untyped]) =
  ## This unrolls creation of several variables at compile-time. Uses system.nim
  ##
  ## expandMacros:
  ##   creates 42, foo, bar, baz
  ##
  ## var foo = create(int, sizeOf int)
  ## foo[] = 42
  ## var bar = create(int, sizeOf int)
  ## bar[] = 42
  ## var baz = create(int, sizeOf int)
  ## baz[] = 42
  ##
  ## expandMacros:
  ##   creates "", foo, bar, baz
  ##
  ## var foo = create(string, sizeOf string)
  ## foo[] = ""
  ## var bar = create(string, sizeOf string)
  ## bar[] = ""
  ## var baz = create(string, sizeOf string)
  ## baz[] = ""
  ##
  ## https://nim-lang.github.io/Nim/system.html#create%2Ctypedesc
  result = newStmtList() # Creates a list of lines of code to be run.
  for it in variables: result.add quote do: # Fills the list with code.
    var `it` = create(type(`value`), sizeOf type(`value`))
    `it`[] = `value`
