from jester import Request


type
  Rank* = enum
    User
    Moderator
    Admin
    Deactivated
    NotLoggedin

type
  ## TSession - parent of TData
  TSession* = object of RootObj
    loggedIn*: bool
    username*, userpass*, email*: string
    
  TData* = ref object of TSession
    req*: Request
    startTime*: float
    urlpath*: string        # Url path (proxy + path)
    userid*: string         # User ID
    timezone*: string       # User timezone
    rank*: Rank             # User status (rank)