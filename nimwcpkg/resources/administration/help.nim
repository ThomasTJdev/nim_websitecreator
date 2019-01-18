# Copyright 2018 - Thomas T. Jarløv

func commandLineHelp*(): string {.inline.} =
  return """
  ∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽

    Nim Website Creator 👑 https://NimWC.org
    A quick website tool. Run the file and access your webpage.

    Commandline arguments:
      🔹newdb      = Generate the database with the standard tables.
                     Does not override or delete any tables.
                     Will be initialized automatically, if no database exists.
      🔹newuser    = Add 1 new Admin user to database.
      🔹insertdata = Insert standard data to database (overrides existing data)
      🔹help       = Help and info for users

  ∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽
  """
