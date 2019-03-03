import os, strutils, sequtils, asyncdispatch

const
  filesListPrivatePath = "files/efs" & "/files/private/*.*"
  filesListPublicPath  = "files/efs" & "/files/public/*.*"


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
