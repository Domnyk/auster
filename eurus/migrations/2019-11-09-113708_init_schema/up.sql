-- Your SQL goes here-- tables
-- Table: answers
CREATE TABLE answers (
    id int NOT NULL CONSTRAINT answers_pk PRIMARY KEY,
    answer varchar(256) NOT NULL,
    question_id int NOT NULL,
    player_id int NOT NULL,
    CONSTRAINT answers_questions FOREIGN KEY (question_id)
    REFERENCES questions (id),
    CONSTRAINT answers_players FOREIGN KEY (player_id)
    REFERENCES players (id)
);

-- Table: players
CREATE TABLE players (
    id int NOT NULL CONSTRAINT players_pk PRIMARY KEY,
    token int NOT NULL,
    name varchar(256) NOT NULL,
    score int NOT NULL,
    room_id int NOT NULL,
    answer_id int,
    CONSTRAINT rooms_players FOREIGN KEY (room_id)
    REFERENCES rooms (id),
    CONSTRAINT players_answers FOREIGN KEY (answer_id)
    REFERENCES answers (id)
);

-- Table: questions
CREATE TABLE questions (
    id int NOT NULL CONSTRAINT questions_pk PRIMARY KEY,
    question varchar(512) NOT NULL,
    was_picked boolean NOT NULL,
    player_id int NOT NULL,
    CONSTRAINT questions_players FOREIGN KEY (player_id)
    REFERENCES players (id)
);

-- Table: rooms
CREATE TABLE rooms (
    id int NOT NULL CONSTRAINT rooms_pk PRIMARY KEY,
    name varchar(256) NOT NULL,
    max_players int NOT NULL,
    state int NOT NULL,
    join_code varchar(8) NOT NULL,
    num_of_rounds int NOT NULL,
    curr_round int NOT NULL CHECK (curr_round <= num_of_rounds),
    curr_player_id int,
    curr_question_id int,
    CONSTRAINT players_rooms FOREIGN KEY (curr_player_id)
    REFERENCES players (id),
    CONSTRAINT rooms_questions FOREIGN KEY (curr_question_id)
    REFERENCES questions (id)
);

-- End of file.
