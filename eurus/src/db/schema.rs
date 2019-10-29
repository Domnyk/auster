table! {
    rooms (id) {
        id -> Integer,
        name -> Text,
        join_code -> Text,
        players -> Integer,
        curr_players -> Integer,
        state -> Integer,
    }
}

table! {
    users (id) {
        id -> Integer,
        token -> Text,
        name -> Nullable<Text>,
        room_id -> Integer,
    }
}

joinable!(users -> rooms (room_id));

allow_tables_to_appear_in_same_query!(
    rooms,
    users,
);
