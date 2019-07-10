import recaptcha, parsecfg, asyncdispatch, os, logging, contra

from strutils import replace

import ../utils/logging_nimwc


var
  useCaptcha*: bool
  captcha*: ReCaptcha

let
  dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
  recaptchaSecretKey = dict.getSectionValue("reCAPTCHA", "Secretkey")
  recaptchaSiteKey* = dict.getSectionValue("reCAPTCHA", "Sitekey")


proc setupReCapthca*() =
  ## Activate Google reCAPTCHA
  preconditions existsFile(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
  if len(recaptchaSecretKey) > 0 and len(recaptchaSiteKey) > 0:
    useCaptcha = true
    captcha = initReCaptcha(recaptchaSecretKey, recaptchaSiteKey)
    info("Initialized ReCAPTCHA.")
  else:
    useCaptcha = false
    warn("Failed to initialize ReCAPTCHA.")


proc checkReCaptcha*(antibot, userIP: string): Future[bool] {.async.} =
  preconditions antibot.len > 0, userIP.len > 0
  if useCaptcha:
    var captchaValid = false
    try:
      captchaValid = await captcha.verify(antibot, userIP)
    except:
      warn("Error checking captcha: " & getCurrentExceptionMsg())
      captchaValid = false

    if not captchaValid:
      debug("g-recaptcha-response", "Answer to captcha incorrect!")
      return false

    else:
      return true

  else:
    return true
