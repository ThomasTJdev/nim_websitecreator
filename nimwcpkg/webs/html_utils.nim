import strutils

from strtabs import newStringTable, modeStyleInsensitive
from packages/docutils/rstgen import rstToHtml
from packages/docutils/rst import RstParseOption

when defined(recaptcha): include captchas


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


template inputNumberHtml*(value="", name="", class="input", id="", placeholder="0", required=true, min:byte=0.byte, max:int=byte.high.int, maxlenght=3): string =
  ## HTML Input Number, no Negative, maxlenght enforced, dir auto, etc.
  inputNumber.format(value, name, class, id, placeholder, if required: "required" else: "", min, max, maxlenght)


template inputFileHtml*(name="", class="input", id="", required=true, fileExtensions=[".jpg", ".jpeg", ".gif", ".png", ".webp"]): string =
  ## HTML Input File, by default for Images but you can customize, validates **before** Upload.
  inputFile.format(name, class, id, if required: "required" else: "", fileExtensions.join(","), fileExtensions.join("|").replace(".", ""))


template imgLazyLoadHtml*(src, id: string, width="", heigth="", class="", alt=""): string =
  ## HTML Image LazyLoad. https://codepen.io/FilipVitas/pen/pQBYQd (Must have ID!)
  imageLazy.format(src, id, width, heigth, class,  alt)


template notifyHtml*(message: string, title="NimWC 👑", iconUrl="/favicon.ico", timeout: byte = 3): string =
  ("Notification.requestPermission(()=>{const n=new Notification('" &
    title & "',{body:'" & message.strip & "',icon:'" & iconUrl &
    "'});setTimeout(()=>{n.close()}," & $timeout & "000)});")


template minifyHtml*(htmlstr: string): string =
  when defined(release): htmlstr.unindent.strip.replace(">\n", ">") else: htmlstr


template rst2html*(stringy: string, options={roSupportMarkdown}): string =
  ## RST/Markdown to HTML using std lib.
  try:
    rstToHtml(stringy.strip, options, newStringTable(modeStyleInsensitive))
  except:
    stringy
