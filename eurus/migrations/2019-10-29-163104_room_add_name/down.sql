-- This file should undo anything in `up.sql`
DROP TABLE rooms;
CREATE TABLE rooms (
    id INTEGER NOT NULL PRIMARY KEY,
    join_code VARCHAR NOT NULL,
    players INTEGER NOT NULL,
    curr_players INTEGER NOT NULL DEFAULT 0,
    state INTEGER NOT NULL DEFAULT 0
);
