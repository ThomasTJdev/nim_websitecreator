import os

const
  filesListPrivatePath = "files/efs/files/private/*.*"
  filesListPublicPath  = "files/efs/files/public/*.*"


proc filesListPrivate*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  for file in walkFiles(filesListPrivatePath):
    result.add(file)


proc filesListPublic*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  for file in walkFiles(filesListPublicPath):
    result.add(file)


proc filesListPublicFolderFiles*(): seq[string] {.inline.} =
  ## Get all filenames for project files
  for file in walkFiles("public/images/*.*"):
    result.add(file)
