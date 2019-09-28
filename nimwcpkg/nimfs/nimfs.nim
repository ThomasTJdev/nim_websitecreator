
# Order is important here.
include
  "utils/_utils.nimf",              # Utils should be first.
  "utils/_navbars.nimf",
  "utils/_editors.nimf",
  "utils/_profiles.nimf",
  "utils/_main_new_editors.nimf",
  "utils/_main_edit_editors.nimf",
  "utils/_editor_imports.nimf",

  "blogs/_blogs.nimf",              # Blogs
  "blogs/_edits.nimf",
  "blogs/_creates.nimf",

  "pages/_pages.nimf",              # Pages
  "pages/_edits.nimf",
  "pages/_creates.nimf",

  "_delayredirects.nimf",           # Everthing else
  "_configs.nimf",
  "_files.nimf",
  "_logs.nimf",
  "_mains.nimf",
  "_plugins.nimf",
  "_statuspages.nimf",
  "_settings.nimf",
  "_sitemaps.nimf",
  "_users.nimf"


when defined(firejail):
  include "_firejails.nimf"         # Firejail
