import db_sqlite

var db = open("tweeter.db", "", "", "")

db.exec(sql"""
  CREATE TABLE IF NOT EXISTS User(
    username text PRIMARY KEY
  );
""")

db.exec(sql"""
  CREATE TABLE IF NOT EXISTS Following(
    follower text,
    followed_user text,
    PRIMARY KEY (follower, followed_user)
    FOREIGN KEY (follower) REFERENCES User(username),
    FOREIGN KEY (followed_user) REFERENCES User(username)
  );
""")

db.exec(sql"""
  CREATE TABLE IF NOT EXISTS Message(
    username text,
    time integer,
    msg text NOT NULL,
    FOREIGN KEY (username) REFERENCES User(username)
  );
""")

echo("Database created sucessfully!")

db.close()