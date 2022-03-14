
proc filesListPrivate*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  for file in walkFiles(storageEFS / "files/private/*.*"):
    result.add(file)


proc filesListPublic*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  for file in walkFiles(storageEFS / "files/public/*.*"):
    result.add(file)


proc filesListPublicFolderFiles*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  for file in walkFiles("public/images/*.*"):
    result.add(file)
