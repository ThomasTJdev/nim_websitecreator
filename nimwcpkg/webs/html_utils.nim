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
  if status == "0" and value == "0":   "selected"
  elif status == "1" and value == "1": "selected"
  elif status == "2" and value == "2": "selected"
  else:                                ""


template currentDatetime*(formatting: string): string =
  ## Getting the current local time
  case formatting
  of "full": format(local(getTime()), "yyyy-MM-dd HH:mm:ss")
  of "date": format(local(getTime()), "yyyy-MM-dd")
  of "year": format(local(getTime()), "yyyy")
  of "month": format(local(getTime()), "MM")
  of "day": format(local(getTime()), "dd")
  of "time": format(local(getTime()), "HH:mm:ss")
  else: format(local(getTime()), "yyyyMMdd")


template getDaysInMonthU*(month: range[1..12], year: Positive): int =
  ## Gets the number of days in the month and year
  getDaysInMonth(Month(month), year)


template dateEpoch*(date, format: string): int =
  ## Transform a date in user format to epoch. Does not utilize timezone.
  assert date.len > 0, "date must not be empty string"
  assert format.len > 0, "format must not be empty string"
  assert format in ["YYYYMMDD", "YYYY-MM-DD", "YYYY-MM-DD HH:mm", "DD-MM-YYYY"]
  case format
  of "YYYYMMDD": toUnix(toTime(parse(date, "yyyyMMdd"))).int
  of "YYYY-MM-DD": toUnix(toTime(parse(date, "yyyy-MM-dd"))).int
  of "YYYY-MM-DD HH:mm": toUnix(toTime(parse(date, "yyyy-MM-dd HH:mm"))).int
  of "DD-MM-YYYY": toUnix(toTime(parse(date, "dd-MM-yyyy"))).int
  else: 0


template epochDate*(epochTime, format: string, timeZone: Natural = 0): string =
  ## Transform epoch to user formatted date
  assert epochTime.len > 0, "epochTime must not be empty string"
  const monthNames = [
    "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ]
  let t = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours = timeZone))
  case format
  of "YYYY":
    t.substr(0, 3)
  of "YYYY_MM_DD-HH_mm":
    t.substr(0, 3) & "_" & t.substr(5, 6) & "_" & t.substr(8, 9) & "-" & t.substr(11, 12) & "_" & t.substr(14, 15)
  of "YYYY MM DD":
    t.substr(0, 3) & " " & t.substr(5, 6) & " " & t.substr(8, 9)
  of "YYYY-MM-DD":
    t.substr(0, 9)
  of "YYYY-MM-DD HH:mm":
    t.substr(0, 9) & " - " & t.substr(11, 15)
  of "DD MM YYYY":
    t.substr(8, 9) & " " & t.substr(5, 6) & " " & t.substr(0, 3)
  of "DD":
    t.substr(8, 9)
  of "MMM DD":
    monthNames[parseInt(t.substr(5, 6))] & " " & t.substr(8, 9)
  of "MMM":
    monthNames[parseInt(t.substr(5, 6))]
  else:
    t.substr(0, 9)


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
