
proc filesListPrivate*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  preconditions existsDir(storageEFS / "files/private/")
  for file in walkFiles(storageEFS / "files/private/*.*"):
    result.add(file)


proc filesListPublic*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  preconditions existsDir(storageEFS / "files/public/")
  for file in walkFiles(storageEFS / "files/public/*.*"):
    result.add(file)


proc filesListPublicFolderFiles*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  preconditions existsDir("public/images/")
  for file in walkFiles("public/images/*.*"):
    result.add(file)
