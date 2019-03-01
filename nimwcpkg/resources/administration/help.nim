func commandLineHelp*(): string {.inline.} =
  return """
  ∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽

    Nim Website Creator 👑 https://NimWC.org
    2-Factor-Auth Self-Firejailing C-Speed Web Framework thats simple to use.
    Run it, access your web, customize, add plugins, deploy today anywhere.

    Commandline arguments:
      🔹 newdb      = Generate the database with the standard tables.
                      Does not override or delete any tables.
                      Will be initialized automatically, if no database exists.
      🔹 newuser    = Add 1 new Admin user to database.
      🔹 insertdata = Insert standard data to database (overrides existing data)
      🔹 help       = Help and info for users.

  ∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽∿∽
  """
