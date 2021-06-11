
proc filesListPrivate*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  preconditions dirExists(storageEFS / "files/private/")
  for file in walkFiles(storageEFS / "files/private/*.*"):
    result.add(file)


proc filesListPublic*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  preconditions dirExists(storageEFS / "files/public/")
  for file in walkFiles(storageEFS / "files/public/*.*"):
    result.add(file)


proc filesListPublicFolderFiles*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  preconditions dirExists("public/images/")
  for file in walkFiles("public/images/*.*"):
    result.add(file)
