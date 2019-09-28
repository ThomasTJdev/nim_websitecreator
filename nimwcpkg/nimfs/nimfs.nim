
include
  "utils.nimf",  # Utils should be first.
  "blog.nimf",
  "blogedit.nimf",
  "blognew.nimf",
  "delayredirect.nimf",
  "editconfig.nimf",
  "files.nimf",
  "logs.nimf",
  "main.nimf",
  "page.nimf",
  "pageedit.nimf",
  "pagenew.nimf",
  "plugins.nimf",
  "serverinfo.nimf",
  "settings.nimf",
  "sitemap.nimf",
  "user.nimf"

when defined(firejail): include "firejail.nimf"
