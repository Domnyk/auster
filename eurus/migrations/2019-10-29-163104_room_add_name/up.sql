DROP TABLE rooms;
-- State mapping 
-- 0 - joining
-- 1 - dead
CREATE TABLE rooms (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR NOT NULL DEFAULT '', 
    join_code VARCHAR NOT NULL,
    players INTEGER NOT NULL,
    curr_players INTEGER NOT NULL DEFAULT 0,
    state INTEGER NOT NULL DEFAULT 0
);
