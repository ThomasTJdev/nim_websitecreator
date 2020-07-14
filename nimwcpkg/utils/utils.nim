
template hardenedBuild*() =
  ## Optional Security Hardened mode (Based from Debian Hardened & Gentoo Hardened).
  ## See: http:wiki.debian.org/Hardening & http:wiki.gentoo.org/wiki/Hardened_Gentoo
  ## http:security.stackexchange.com/questions/24444/what-is-the-most-hardened-set-of-options-for-gcc-compiling-c-c
  when defined(hardened) and defined(gcc) and not defined(objc) and not defined(js):
    when defined(danger): {.fatal: "-d:hardened is incompatible with -d:danger".}
    {.hint: "Security Hardened mode is enabled.".}
    const hf = "-fstack-protector-all -Wstack-protector --param ssp-buffer-size=4 -pie -fPIE -Wformat -Wformat-security -D_FORTIFY_SOURCE=2 -Wall -Wextra -Wconversion -Wsign-conversion -mindirect-branch=thunk -mfunction-return=thunk -fstack-clash-protection -Wl,-z,relro,-z,now -Wl,-z,noexecstack -fsanitize=signed-integer-overflow -fsanitize-undefined-trap-on-error -fno-common"
    {.passC: hf, passL: hf, assertions: on, checks: on.}
