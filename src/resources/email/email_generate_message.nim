
import parsecfg

let dict = loadConfig("config/config.cfg")
let title = dict.getSectionValue("Server","title")
let website = dict.getSectionValue("Server","website")

let mailStyleHeader = """<!DOCTYPE html><html lang=EN style="3D&quot;background:#FAFAFA;min-height:100%="><head><meta charset=UTF-8><meta content="width=device-width, initial-scale=1.0" name=viewport><title></title></head><body style="font-size: 16px;font-family:'Roboto';font-style:normal;font-weight:400;src:local('Roboto'),local('Roboto-Regular'),url(https://fonts.gstatic.com/s/roboto/v18/CWB0XYA8bzo0kSThX0UTuA.woff2) format('woff2');unicode-range:U+0000-00FF,U+0131,U+0152-0153,U+02C6,U+02DA,U+02DC,U+2000-206F,U+2074,U+20AC,U+2212,U+2215"><div style=background:#171921;border-color:#123d6d;height:70px;width:100%;margin-bottom:20px;padding-top:5px;padding-bottom:5px;text-align:center><a href=""""" & website & """" style="color:white;font-size:22px;line-height:64px;">""" & title & """</a></div><div style="padding:0 10px">"""
let mailStyleFrom = """<hr style="margin-top: 40px;margin-bottom:20px;"><div><b>Kind regards</b></div>"""
let mailStyleFooter = """</div><div style="background:#171921;border-color:#123d6d;height:35px;width:100%;margin-top:20px;text-align:center"><div style="height:100%;font-size:18px;margin-left:15px;line-height:36px"><a href="""" & website & """" style="color:white">""" & website & """</a></div></div></body></html>"""


proc genEmailMessage*(msgContent: string): string =
  ## Generate email content

  return mailStyleHeader & msgContent & mailStyleFrom & mailStyleFooter
