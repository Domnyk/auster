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
        name -> Text,
        score -> Integer,
        curr_answer_id -> Nullable<Integer>,
        room_id -> Integer,
        answer_id -> Integer,
    }
}

table! {
    questions (id) {
        id -> Integer,
        question -> Text,
        was_picked -> Bool,
        room_id -> Integer,
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
        round_num -> Integer,
        curr_player_id -> Integer,
        curr_question_id -> Integer,
    }
}

joinable!(answers -> questions (question_id));

allow_tables_to_appear_in_same_query!(
    answers,
    players,
    questions,
    rooms,
);
