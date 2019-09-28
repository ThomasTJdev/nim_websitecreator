
include
  "utils.nimf",  # Utils should be first.
  "blogs/blogs.nimf",
  "blogs/edits.nimf",
  "blogs/creates.nimf",
  "delayredirects.nimf",
  "configs.nimf",
  "files.nimf",
  "logs.nimf",
  "mains.nimf",
  "pages/pages.nimf",
  "pages/edits.nimf",
  "pages/creates.nimf",
  "plugins.nimf",
  "statuspages.nimf",
  "settings.nimf",
  "sitemaps.nimf",
  "users.nimf"


when defined(firejail): include "firejails.nimf"
