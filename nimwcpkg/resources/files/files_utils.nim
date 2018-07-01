import os, strutils, sequtils, asyncdispatch


import ../files/files_efs


proc filesListPrivate*(): seq[string] =
  ## Get all filenames for project files
  result = @[]

  for file in walkFiles(storageEFS & "/files/private/*.*"):
    result.add(file)

proc filesListPublic*(): seq[string] =
  ## Get all filenames for project files
  result = @[]

  for file in walkFiles(storageEFS & "/files/public/*.*"):
    result.add(file)

proc filesListPublicFolderFiles*(): seq[string] =
  ## Get all filenames for project files
  result = @[]

  for file in walkFiles("public/files/*.*"):
    result.add(file)

proc filesListPublicFolderImages*(): seq[string] =
  ## Get all filenames for project files
  result = @[]

  for file in walkFiles("public/images/*.*"):
    result.add(file)
