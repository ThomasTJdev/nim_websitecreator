## Do NOT import this file directly, instead import ``html_utils.nim``
import asyncdispatch, logging, os, recaptcha, strutils, tables
import ../utils/configs, ../enums/enums


var
  useCaptcha*: bool
  captcha*: ReCaptcha

let
  dict = getConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg", cfgRecaptcha)
  recaptchaSecretKey = dict["Secretkey"]
  recaptchaSiteKey* = dict["Sitekey"]


proc setupReCaptcha*(recaptchaSiteKey = recaptchaSiteKey, recaptchaSecretKey = recaptchaSecretKey) =
  ## Activate Google reCAPTCHA
  if len(recaptchaSecretKey) > 0 and len(recaptchaSiteKey) > 0:
    useCaptcha = true
    captcha = initReCaptcha(recaptchaSecretKey, recaptchaSiteKey)
    info("Initialized ReCAPTCHA.")
  else:
    useCaptcha = false
    warn("Failed to initialize ReCAPTCHA.")

setupReCaptcha()


proc checkReCaptcha*(antibot, userIP: string): Future[bool] {.async.} =
  ## Check if Google reCAPTCHA is Valid
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
