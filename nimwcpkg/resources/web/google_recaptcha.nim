import recaptcha, parsecfg, asyncdispatch, os, logging

from strutils import replace

import ../utils/logging_nimwc


var
  useCaptcha*: bool
  captcha*: ReCaptcha


# Using config.ini
let dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")

# Web settings
let recaptchaSecretKey = dict.getSectionValue("reCAPTCHA","Secretkey")
let recaptchaSiteKey* = dict.getSectionValue("reCAPTCHA","Sitekey")


proc setupReCapthca*() =
  # Activate Google reCAPTCHA
  if len(recaptchaSecretKey) > 0 and len(recaptchaSiteKey) > 0:
    useCaptcha = true
    captcha = initReCaptcha(recaptchaSecretKey, recaptchaSiteKey)
    info("Initialized reCAPTCHA.")

  else:
    useCaptcha = false
    error("setupReCapthca(): Failed to initialize reCAPTCHA.")


proc checkReCaptcha*(antibot, userIP: string): Future[bool] {.async.} =
  if useCaptcha:
    var captchaValid: bool = false
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
