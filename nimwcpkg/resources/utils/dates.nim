import strutils, times


import ../utils/logging_nimwc


const monthNames = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


proc currentDatetime*(formatting: string): string=
  ## Getting the current local time

  if formatting == "full":
    result = format(local(getTime()), "yyyy-MM-dd HH:mm:ss")
  elif formatting == "date":
    result = format(local(getTime()), "yyyy-MM-dd")
  elif formatting == "compact":
    result = format(local(getTime()), "yyyyMMdd")
  elif formatting == "year":
    result = format(local(getTime()), "yyyy")
  elif formatting == "month":
    result = format(local(getTime()), "MM")
  elif formatting == "day":
    result = format(local(getTime()), "dd")
  elif formatting == "time":
    result = format(local(getTime()), "HH:mm:ss")



proc getDaysInMonthU*(month, year: int): int =
  ## Gets the number of days in the month and year
  ##
  ## Examples:
  ##
  runnableExamples:
    doAssert getDaysInMonthU(02, 2018) == 28
    doAssert getDaysInMonthU(10, 2020) == 31
  if month notin {1..12}:
    dbg("WARNING", "getDaysInMonthU() wrong format input")
  else:
    result = getDaysInMonth(Month(month), year)




proc dateEpoch*(date, format: string): int64 =
  ## Transform a date in user format to epoch
  ## Does not utilize timezone
  ##
  ## Examples:
  ##
  runnableExamples:
    doAssert dateEpoch("2018-02-18", "YYYY-MM-DD") == "1518908400"

  try:
    case format
    of "YYYYMMDD":
      return toUnix(toTime(parse(date, "yyyyMMdd")))
    of "YYYY-MM-DD":
      return toUnix(toTime(parse(date, "yyyy-MM-dd")))
    of "YYYY-MM-DD HH:mm":
      return toUnix(toTime(parse(date, "yyyy-MM-dd HH:mm")))
    of "DD-MM-YYYY":
      return toUnix(toTime(parse(date, "dd-MM-yyyy")))
    else:
      dbg("WARNING", "dateEpoch() wrong format input")
      return 0
  except:
    dbg("WARNING", "dateEpoch() failed")

    return 0



proc epochDate*(epochTime, format: string, timeZone = "0"): string =
  ## Transform epoch to user formatted date
  ##
  ## Examples:
  ##
  runnableExamples:
    doAssert epochDate("1522995050", "YYYY-MM-DD HH:mm", "2") == "2018-04-06 - 08:10"


  if epochTime == "":
    return ""

  try:
    case format
    of "YYYY":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      return toTime.substr(0, 3)

    of "YYYY_MM_DD-HH_mm":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      return toTime.substr(0, 3) & "_" & toTime.substr(5, 6) & "_" & toTime.substr(8, 9) & "-" & toTime.substr(11, 12) & "_" & toTime.substr(14, 15)

    of "YYYY MM DD":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      return toTime.substr(0, 3) & " " & toTime.substr(5, 6) & " " & toTime.substr(8, 9)

    of "YYYY-MM-DD":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      return toTime.substr(0, 9)

    of "YYYY-MM-DD HH:mm":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      return toTime.substr(0, 9) & " - " & toTime.substr(11, 15)

    of "DD MM YYYY":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      return toTime.substr(8, 9) & " " & toTime.substr(5, 6) & " " & toTime.substr(0, 3)

    of "DD":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      return toTime.substr(8, 9)

    of "MMM DD":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      return monthNames[parseInt(toTime.substr(5, 6))] & " " & toTime.substr(8, 9)

    of "MMM":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      return monthNames[parseInt(toTime.substr(5, 6))]

    else:
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initTimeInterval(hours=parseInt(timeZone)))
      dbg("WARNING", "epochDate() no input specified")
      return toTime.substr(0, 9)

  except:
    dbg("ERROR", "epochDate() failed")
    return ""
