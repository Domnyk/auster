-- Your SQL goes here-- tables
-- Table: answers
CREATE TABLE answers (
    id INTEGER CONSTRAINT answers_pk PRIMARY KEY,
    answer varchar(256) NOT NULL,
    question_id INTEGER NOT NULL,
    player_id  INTEGER NOT NULL,
    CONSTRAINT answers_questions FOREIGN KEY (question_id)
    REFERENCES questions (id),
    CONSTRAINT answers_players FOREIGN KEY (player_id)
    REFERENCES players (id)
);

-- Table: players
CREATE TABLE players (
    id INTEGER CONSTRAINT players_pk PRIMARY KEY,
    token  INTEGER NOT NULL,
    name varchar(256) NOT NULL,
    score  INTEGER NOT NULL DEFAULT 0,
    room_id INTEGER NOT NULL,
    answer_id  INTEGER DEFAULT NULL,
    was_picked BOOLEAN NOT NULL DEFAULT 0,
    CONSTRAINT rooms_players FOREIGN KEY (room_id)
    REFERENCES rooms (id),
    CONSTRAINT players_answers FOREIGN KEY (answer_id)
    REFERENCES answers (id)
);

-- Table: questions
CREATE TABLE questions (
    id INTEGER CONSTRAINT questions_pk PRIMARY KEY,
    question varchar(512) NOT NULL,
    was_picked boolean NOT NULL DEFAULT 0,
    player_id  INTEGER NOT NULL,
    CONSTRAINT questions_players FOREIGN KEY (player_id)
    REFERENCES players (id)
);

-- Table: rooms
CREATE TABLE rooms (
    id INTEGER CONSTRAINT rooms_pk PRIMARY KEY,
    name varchar(256) NOT NULL,
    max_players INTEGER NOT NULL,
    state  INTEGER NOT NULL DEFAULT 0,
    join_code varchar(8) NOT NULL,
    num_of_rounds  INTEGER NOT NULL,
    curr_round INTEGER NOT NULL CHECK (curr_round <= num_of_rounds) DEFAULT 0,
    curr_player_id INTEGER DEFAULT NULL,
    curr_question_id INTEGER DEFAULT NULL,
    CONSTRAINT players_rooms FOREIGN KEY (curr_player_id)
    REFERENCES players (id),
    CONSTRAINT rooms_questions FOREIGN KEY (curr_question_id)
    REFERENCES questions (id)
);

-- End of file.
