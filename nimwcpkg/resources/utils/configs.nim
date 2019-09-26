import parsecfg, tables, os


proc getConfig*(configPath, section: string): Table[string, string] =
  ## Take file path & section,return Table of config,to access using cfg["key"]
  assert configPath.len > 0, "configPath must not be empty string"
  assert section.len > 0, "section must not be empty string"
  assert configPath[^4..^1] == ".cfg", "configPath must be .cfg file extension"
  assert existsFile(configPath), "configPath file not found"
  assert section in ["Database", "Storage", "Logging", "Server", "Proxy",
    "reCAPTCHA", "SMTP", "firejail"], "section must be a valid CFG section"
  let dict = loadConfig(configPath)
  case section
  of "Database":
    result = {
      "folder": dict.getSectionValue("Database", "folder"),
      "host": dict.getSectionValue("Database", "host"),
      "name": dict.getSectionValue("Database", "name"),
      "user": dict.getSectionValue("Database", "user"),
      "pass": dict.getSectionValue("Database", "pass"),
      "port": dict.getSectionValue("Database", "port"),
    }.toTable
  of "Storage":
    result = {
      "storagedev": dict.getSectionValue("Storage", "storagedev"),
      "storage": dict.getSectionValue("Storage", "storage"),
    }.toTable
  of "Logging":
    result = {
      "logfiledev": dict.getSectionValue("Logging", "logfiledev"),
      "logfile": dict.getSectionValue("Logging", "logfile"),
    }.toTable
  of "Server":
    result = {
      "website": dict.getSectionValue("Server", "website"),
      "title": dict.getSectionValue("Server", "title"),
      "url": dict.getSectionValue("Server", "url"),
      "port": dict.getSectionValue("Server", "port"),
      "appname": dict.getSectionValue("Server", "appname"),
    }.toTable
  of "Proxy":
    result = {
      "url": dict.getSectionValue("Proxy", "url"),
      "path": dict.getSectionValue("Proxy", "path"),
    }.toTable
  of "reCAPTCHA":
    result = {
      "Sitekey": dict.getSectionValue("reCAPTCHA", "Sitekey"),
      "Secretkey": dict.getSectionValue("reCAPTCHA", "Secretkey"),
    }.toTable
  of "SMTP":
    result = {
      "SMTPAddress": dict.getSectionValue("SMTP", "SMTPAddress"),
      "SMTPPort": dict.getSectionValue("SMTP", "SMTPPort"),
      "SMTPUser": dict.getSectionValue("SMTP", "SMTPUser"),
      "SMTPPassword": dict.getSectionValue("SMTP", "SMTPPassword"),
      "SMTPFrom": dict.getSectionValue("SMTP", "SMTPFrom"),
      "SMTPEmailAdmin": dict.getSectionValue("SMTP", "SMTPEmailAdmin"),
      "SMTPEmailSupport": dict.getSectionValue("SMTP", "SMTPEmailSupport"),
    }.toTable
  of "firejail":
    result = {
      "folder": dict.getSectionValue("firejail", "folder"),
      "host": dict.getSectionValue("firejail", "host"),
      "name": dict.getSectionValue("firejail", "name"),
      "user": dict.getSectionValue("firejail", "user"),
      "pass": dict.getSectionValue("firejail", "pass"),
      "port": dict.getSectionValue("firejail", "port"),
    }.toTable
  else: discard
