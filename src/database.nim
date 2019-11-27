import times

type
  User* = object
    username*: string
    following*: seq[string]

  Message* = object
    username*: string
    time*: Time
    msg*: string