import
  asyncdispatch, logging, os, parsecfg, recaptcha, strutils


template checkboxToInt*(checkboxOnOff: string): string =
  ## When posting checkbox data from HTML form
  ## an "on" is sent when true. Convert to 1 or 0.
  if checkboxOnOff == "on": "1" else: "0"


template checkboxToChecked*(checkboxOnOff: string): string =
  ## When parsing DB data on checkboxes convert
  ## 1 or 0 to HTML checked to set checkbox
  if checkboxOnOff == "1": "checked" else: ""


template statusIntToText*(status: string): string =
  ## When parsing DB status convert 0, 1 and 3 to human names
  case status
  of "0": "Development"
  of "1": "Private"
  of "2": "Public"
  else:   "Error"


template statusIntToCheckbox*(status, value: string): string =
  ## When parsing DB status convert to HTML selected on selects
  if status == "0" and value == "0":
    "selected"
  elif status == "1" and value == "1":
    "selected"
  elif status == "2" and value == "2":
    "selected"
  else:
    ""


when defined(recaptcha):
  var
    useCaptcha*: bool
    captcha*: ReCaptcha

  let
    dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
    recaptchaSecretKey = dict.getSectionValue("reCAPTCHA", "Secretkey")
    recaptchaSiteKey* = dict.getSectionValue("reCAPTCHA", "Sitekey")

  proc setupReCapthca*(recaptchaSiteKey = recaptchaSiteKey, recaptchaSecretKey = recaptchaSecretKey) =
    ## Activate Google reCAPTCHA
    preconditions recaptchaSiteKey.len > 0, recaptchaSecretKey.len > 0
    if len(recaptchaSecretKey) > 0 and len(recaptchaSiteKey) > 0:
      useCaptcha = true
      captcha = initReCaptcha(recaptchaSecretKey, recaptchaSiteKey)
      info("Initialized ReCAPTCHA.")
    else:
      useCaptcha = false
      warn("Failed to initialize ReCAPTCHA.")


  proc checkReCaptcha*(antibot, userIP: string): Future[bool] {.async.} =
    ## Check if Google reCAPTCHA is Valid
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