use crate::db::schema::*;
use diesel::{
    Insertable,
    Queryable,
    Identifiable,
};

#[derive(Queryable, Identifiable, Associations)]
#[belongs_to(Room)]
pub struct Player {
    pub id: i32,
    pub token: i32,
    pub name: String,
    pub score: i32,
    pub room_id: i32,
    pub answer_id: Option<i32>,
}

#[derive(Insertable, Clone)]
#[table_name = "players"]
pub struct NewPlayer {
    pub name: String,
    pub token: i32,
    pub room_id: i32,

}

#[derive(Queryable, Identifiable, Associations)]
#[belongs_to(Player)]
pub struct Answer {
    pub id: i32,
    pub answer: String,
    pub player_id: i32,
    pub question_id: i32,
}

#[derive(Insertable, Clone)]
#[table_name = "answers"]
pub struct NewAnswer {
    pub answer: String,
    pub question_id: i32,
    pub player_id: i32,
}

#[derive(Queryable, Identifiable, Associations)]
#[belongs_to(Player)]
pub struct Question {
    pub id: i32,
    pub question: String,
    pub was_picked: bool,
    pub player_id: i32,
}

#[derive(Insertable, Clone)]
#[table_name = "questions"]
pub struct NewQuestion {
    pub question: String,
    pub player_id: i32,
}


#[derive(Queryable, Identifiable, Associations)]
pub struct Room {
    pub id: i32,
    pub name: String,
    pub max_players: i32,
    pub state: i32,
    pub join_code: String,
    pub num_of_rounds: i32,
    pub curr_round: i32,
    pub curr_player_id: Option<i32>,
    pub curr_question_id: Option<i32>,
}

#[derive(Insertable, Clone)]
#[table_name = "rooms"]
pub struct NewRoom {
    pub name: String,
    pub max_players: i32,
    pub join_code: String,
    pub num_of_rounds: i32,
}