-- This file should undo anything in `up.sql`

DROP TABLE users;
DROP TABLE rooms;
CREATE TABLE users (
  id INTEGER NOT NULL PRIMARY KEY,
  token VARCHAR NOT NULL,
  name VARCHAR DEFAULT ''
);