import strutils, times 


import ../utils/logging


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



proc getDaysInMonthU*(month, year: int): int=
  ## Gets the number of days in the month and year
  ##
  ## Examples:
  ##
  runnableExamples:
    doAssert getDaysInMonthU(02, 2018) == 28
    doAssert getDaysInMonthU(10, 2020) == 31

  case month
  of 01:
    return getDaysInMonth(mJan, year)
  of 02:
    return getDaysInMonth(mFeb, year)
  of 03:
    return getDaysInMonth(mMar, year)
  of 04:
    return getDaysInMonth(mApr, year)
  of 05:
    return getDaysInMonth(mMay, year)
  of 06:
    return getDaysInMonth(mJun, year)
  of 07:
    return getDaysInMonth(mJul, year)
  of 08:
    return getDaysInMonth(mAug, year)
  of 09:
    return getDaysInMonth(mSep, year)
  of 10:
    return getDaysInMonth(mOct, year)
  of 11:
    return getDaysInMonth(mNov, year)
  of 12:
    return getDaysInMonth(mDec, year)
  else:
    dbg("WARNING", "getDaysInMonthU() wrong format input")
    discard



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
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initInterval(hours=parseInt(timeZone)))
      return toTime.substr(0, 3)

    of "YYYY MM DD":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initInterval(hours=parseInt(timeZone)))
      return toTime.substr(0, 3) & " " & toTime.substr(5, 6) & " " & toTime.substr(8, 9)

    of "YYYY-MM-DD":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initInterval(hours=parseInt(timeZone)))
      return toTime.substr(0, 9)

    of "YYYY-MM-DD HH:mm":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initInterval(hours=parseInt(timeZone)))
      return toTime.substr(0, 9) & " - " & toTime.substr(11, 15)

    of "DD MM YYYY":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initInterval(hours=parseInt(timeZone)))
      return toTime.substr(8, 9) & " " & toTime.substr(5, 6) & " " & toTime.substr(0, 3)

    of "DD":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initInterval(hours=parseInt(timeZone)))
      return toTime.substr(8, 9)

    of "MMM DD":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initInterval(hours=parseInt(timeZone)))
      return monthNames[parseInt(toTime.substr(5, 6))] & " " & toTime.substr(8, 9)

    of "MMM":
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initInterval(hours=parseInt(timeZone)))
      return monthNames[parseInt(toTime.substr(5, 6))]

    else:
      let toTime = $(utc(fromUnix(parseInt(epochTime))) + initInterval(hours=parseInt(timeZone)))
      dbg("WARNING", "epochDate() no input specified")
      return toTime.substr(0, 9)

  except:
    dbg("ERROR", "epochDate() failed")
    return ""



#[
proc DEPRECATEDdateDiff*(date1, date2: TimeInterval, checkType: string): int=
  ## Checking the difference between two dates
  ## date1 = current date
  ## date2 = date to check against
  if checkType == "year":
    return date1.years - date2.years
  elif checkType == "month":
    return date1.months - date2.months
  elif checkType == "day":
    return date1.days - date2.days
  elif checkType == "dayDiff":
    var days = 0
    # If there's more than > 1 month between the two dates
    if date1.months - date2.months > 1:
      for i in date2.months .. date1.months:
        if i == date2.months:
          days += getDaysInMonthU(date2.months, date2.years) - date2.days
        elif i == date1.months:
          days += date1.days
        else:
          days += getDaysInMonthU(i, date2.years)
    # If the date1 month is next in sequence
    elif date1.months - date2.months == 1:
      days = getDaysInMonthU(date2.months, date2.years) - date2.days + date1.days
    # If the dates days is in the same month
    elif date1.months - date2.months == 0:
      days = date1.days - date2.days
    else:
      days = -1
    return days
  elif checkType == "date1Larger":
    var diff = date1 - date2
    if date1.years - date2.years >= 0 and date1.months - date2.months >= 0:
      if diff.months > 0:
        return 1
      else:
        if diff.days > 0:
          return 1
        else:
          return 0
]#