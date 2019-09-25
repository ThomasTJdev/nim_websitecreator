import os, contra
from files_efs import storageEFS


template filesListPrivate*(): seq[string] =
  ## Get all filenames for project files
  preconditions existsDir(storageEFS / "files/private/")
  for file in walkFiles(storageEFS / "files/private/*.*"):
    result.add(file)


template filesListPublic*(): seq[string] =
  ## Get all filenames for project files
  preconditions existsDir(storageEFS / "files/public/")
  for file in walkFiles(storageEFS / "files/public/*.*"):
    result.add(file)


template filesListPublicFolderFiles*(): seq[string] =
  ## Get all filenames for project files
  preconditions existsDir("public/images/")
  for file in walkFiles("public/images/*.*"):
    result.add(file)
