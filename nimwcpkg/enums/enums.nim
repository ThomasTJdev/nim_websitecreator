## This file constains Enums, mostly for options, for compile-time type-safe choices.
## So we dont have to do ``if $option in ["foo", "bar"]: doStuff()`` everywhere.
## Its imposible for an enum to not be one of its members and is faster.
## This is the recommended/safe way of doing options instead of strings, AFAIK.
## Only put Enums here, no code logic, keep it compile-time static.


type
  CSSFramework* = enum          ## CSS Frameworks enumeration.
    cssBulma = "bulma"
    cssBootstrap = "bootstrap"
    cssWater = "water"
    cssOfficial = "official"

  ConfigSections* = enum        ## Configuration Sections.
    cfgDatabase = "Database"
    cfgStorage = "Storage"
    cfgLogging = "Logging"
    cfgServer = "Server"
    cfgProxy = "Proxy"
    cfgRecaptcha = "reCAPTCHA"
    cfgSmtp = "SMTP"
    cfgFirejail = "firejail"