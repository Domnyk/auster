table! {
    answers (id) {
        id -> Integer,
        answer -> Text,
        question_id -> Integer,
        player_id -> Integer,
    }
}

table! {
    players (id) {
        id -> Integer,
        token -> Integer,
        name -> Text,
        score -> Integer,
        room_id -> Integer,
        answer_id -> Nullable<Integer>,
    }
}

table! {
    questions (id) {
        id -> Integer,
        question -> Text,
        was_picked -> Bool,
        player_id -> Integer,
    }
}

table! {
    rooms (id) {
        id -> Integer,
        name -> Text,
        max_players -> Integer,
        state -> Integer,
        join_code -> Text,
        num_of_rounds -> Integer,
        curr_round -> Integer,
        curr_player_id -> Nullable<Integer>,
        curr_question_id -> Nullable<Integer>,
    }
}

joinable!(answers -> questions (question_id));
joinable!(questions -> players (player_id));
joinable!(rooms -> questions (curr_question_id));

allow_tables_to_appear_in_same_query!(
    answers,
    players,
    questions,
    rooms,
);
