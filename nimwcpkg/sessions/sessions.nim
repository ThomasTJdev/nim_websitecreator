

when NimMajor > 2:
  from jester_fork import Request
else:
  from jester import Request

type
  Rank* = enum                ## Rank for the User.
    User
    Moderator
    Admin
    Deactivated
    NotLoggedin

  Session* = object of RootObj
    loggedIn*: bool
    username*, userpass*, email*: string

  TData* = ref object of Session
    req*: Request
    userid*: string           ## User ID
    timezone*: string         ## User timezone
    rank*: Rank               ## User status (rank)
