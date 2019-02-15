import os, strutils, sequtils, asyncdispatch, ../files/files_efs

const
  filesListPrivatePath = storageEFS & "/files/private/*.*"
  filesListPublicPath  = storageEFS & "/files/public/*.*"


proc filesListPrivate*(): seq[string] =
  ## Get all filenames for project files
  for file in walkFiles(filesListPrivatePath):
    result.add(file)


proc filesListPublic*(): seq[string] =
  ## Get all filenames for project files
  for file in walkFiles(filesListPublicPath):
    result.add(file)


proc filesListPublicFolderFiles*(): seq[string] =
  ## Get all filenames for project files
  for file in walkFiles("public/images/*.*"):
    result.add(file)


proc fileSize*(sizeInBytes: BiggestInt): string =
  ## Converts a byte size to kB or MB

  if ($sizeInBytes).len() <= 6:
    $(toBiggestFloat(sizeInBytes)/1_024) & " kB"
  else:
    $(toBiggestFloat(sizeInBytes)/1_000_024) & " MB"
