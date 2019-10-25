-- State mapping 
-- 0 - joining
-- 1 - dead
CREATE TABLE rooms (
    id INTEGER NOT NULL PRIMARY KEY, 
    join_code VARCHAR NOT NULL,
    players INTEGER NOT NULL,
    curr_players INTEGER NOT NULL DEFAULT 0,
    state INTEGER NOT NULL DEFAULT 0
);
DROP TABLE users;
CREATE TABLE users (
  id INTEGER NOT NULL PRIMARY KEY,
  token VARCHAR NOT NULL,
  name VARCHAR DEFAULT '',
  room_id INTEGER NOT NULL,
  FOREIGN KEY(room_id) REFERENCES rooms(id)
);