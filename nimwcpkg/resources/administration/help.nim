# Copyright 2018 - Thomas T. Jarløv

proc commandLineHelp*(): string =
  return """
  _____________________________________
  
    Nim Website Creator
    A quick website tool. Run the file and access your webpage.

    Commandline arguments:
      - newdb       = Generates the database with standard tables (does **not** override or delete tables). `newdb` will be initialized automatic, if the no database exists.
      - newuser     = Add the Admin user
      - insertdata  = Insert standard data (this will override existing data)
      - help
  _____________________________________
  """