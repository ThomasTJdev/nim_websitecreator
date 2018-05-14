import os, strutils, sequtils, asyncdispatch


import ../files/files_efs


proc filesListPrivate*(): seq[string] =
  ## Get all filenames for project files
  var filenames: seq[string] = @[""]

  for file in walkFiles(storageEFS & "/files/private/*.*"):
    filenames.add(file)

  return filenames



proc filesListPublic*(): seq[string] =
  ## Get all filenames for project files
  var filenames: seq[string] = @[""]

  for file in walkFiles(storageEFS & "/files/public/*.*"):
    filenames.add(file)

  return filenames


proc filesListPublicFolder*(): seq[string] =
  ## Get all filenames for project files
  var filenames: seq[string] = @[""]

  for file in walkFiles("public/files/*.*"):
    filenames.add(file)

  return filenames
