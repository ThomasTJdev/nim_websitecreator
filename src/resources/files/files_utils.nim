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

proc filesListPublicFolder*(): seq[string] =
  ## Get all filenames for project files
  result = @[]

  for file in walkFiles("public/files/*.*"):
    result.add(file)
