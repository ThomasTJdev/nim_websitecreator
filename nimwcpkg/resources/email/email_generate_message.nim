import parsecfg, strutils, os


const
  mailStyleFrom = """
  <hr style="margin-top:40px;margin-bottom:20px">
    <div>
      <b>Kind regards</b>
    </div>
  """

  mailStyleHeaderMsg = """
  <!DOCTYPE html>
    <html lang=EN style="3D&quot;background:#FAFAFA;min-height:100%=">
      <head>
        <meta charset=UTF-8>
        <meta content="width=device-width, initial-scale=1.0" name=viewport>
        <title></title>
      </head>
      <body style="font-size:16px;font-family:'Roboto';font-style:normal;font-weight:400;src:local('Roboto'),local('Roboto-Regular'),url(https://fonts.gstatic.com/s/roboto/v18/CWB0XYA8bzo0kSThX0UTuA.woff2) format('woff2');unicode-range:U+0000-00FF,U+0131,U+0152-0153,U+02C6,U+02DA,U+02DC,U+2000-206F,U+2074,U+20AC,U+2212,U+2215">
        <div style=background:#171921;border-color:#123d6d;height:70px;width:100%;margin-bottom:20px;padding-top:5px;padding-bottom:5px;text-align:center>
          <a href="$1" style="color:white;font-size:22px;line-height:64px;"> $2 </a>
        </div>
        <div style="padding:0 10px">
  """

  mailStyleFooterMsg = """
      </div>
        <div style="background:#171921;border-color:#123d6d;height:35px;width:100%;margin-top:20px;text-align:center">
          <div style="height:100%;font-size:18px;margin-left:15px;line-height:36px">
            <a href="$1" style="color:white"> $2 </a>
          </div>
        </div>
    </body>
  </html>
  """


let
  dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
  title = dict.getSectionValue("Server","title")
  website = dict.getSectionValue("Server","website")
  mailStyleHeader = mailStyleHeaderMsg.format(website, title)
  mailStyleFooter = mailStyleFooterMsg.format(website, title)


proc genEmailMessage*(msgContent: string): string {.inline.} =
  ## Generate email content
  mailStyleHeader & msgContent & mailStyleFrom & mailStyleFooter
