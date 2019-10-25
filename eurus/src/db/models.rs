use crate::db::schema::*;
use diesel::{Insertable, Queryable};

#[derive(Queryable)]
pub struct User {
    pub id: i32,
    pub token: String,
    pub name: Option<String>,
    pub room_id: i32,
}

#[derive(Insertable, Clone)]
#[table_name = "users"]
pub struct NewUser {
    pub name: Option<String>,
    pub token: String,
    pub room_id: i32,
}

#[derive(Queryable)]
pub struct Room {
    pub id: i32,
    pub join_code: String,
    pub players: i32,
    pub curr_players: i32,
    pub state: i32,
}

#[derive(Insertable)]
#[table_name = "rooms"]
pub struct NewRoom {
    pub join_code: String,
    pub players: i32,
}