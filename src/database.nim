import db_sqlite
import times
import strutils

type
  Database* = ref object
    db: DbConn

proc newDatabase*(filename = "tweeter.db"): Database =
  new result
  result.db = open(filename, "", "", "")
  
type
  User* = object
    username*: string
    following*: seq[string]

  Message* = object
    username*: string
    time*: Time
    msg*: string

proc close*(database: Database) =
  database.db.close()

proc setup*(database: Database) =
  database.db.exec(sql"""
    CREATE TABLE IF NOT EXISTS User(
    username text PRIMARY KEY
  );
  """)
  database.db.exec(sql"""
  CREATE TABLE IF NOT EXISTS Following(
    follower text,
    followed_user text,
    PRIMARY KEY (follower, followed_user)
    FOREIGN KEY (follower) REFERENCES User(username),
    FOREIGN KEY (followed_user) REFERENCES User(username)
  );
  """)

  database.db.exec(sql"""
  CREATE TABLE IF NOT EXISTS Message(
    username text,
    time integer,
    msg text NOT NULL,
    FOREIGN KEY (username) REFERENCES User(username)
  );
  """)

proc post*(database: Database, message: Message) =
  if message.msg.len > 140:
    raise newException(ValueError, "Message has to be less than 140 characters.")

  database.db.exec(sql"INSERT INTO Message VALUES (?, ?, ?);",
    message.username, $message.time.toSeconds().int, message.msg)

proc follow*(database: Database, follower: User, user: User) =
  database.db.exec(sql"INSERT INTO Following VALUES (?, ?);",
    follower.username, user.username)

proc create*(database: Database, user: User) =
  database.db.exec(sql"INSERT INTO User VALUES (?);", user.username)

proc findUser*(database: Database, username: string, user: var User): bool =
  let row = database.db.getRow(
    sql"SELECT username FROM User WHERE username = ?;", username
  )
  if row[0].len == 0: return false
  else: user.username = row[0]

  let following = database.db.getAllRows(
    sql"SELECT followed_user FROM Following WHERE follower = ?;", username)
  user.following = @[]
  for row in following:
    if row[0].len != 0:
        user.following.add(row[0])
  return true

proc findMessages*(database: Database, usernames: seq[string], limit = 10): seq[Message] =
  result = @[]
  if usernames.len == 0: return
  var whereClause = " WHERE "
  for i in 0 .. <usernames.len:
    whereClause.add("username = ? ")
    if i != <usernames.len:
      whereClause.add(" or ")
  
  let messages = database.db.getAllRows(
    sql("SELECT username, time, msg FROM Message" &
      whereClause &
      "ORDER BY time DESC LIMIT " & $limit), usernames)
  for row in messages:
    result.add(Message(username: row[0], time: fromSeconds(row[1].parseInt),
      msg: row[2]))