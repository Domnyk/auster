use crate::db;
use crate::graphql;

use std::convert::{
    From,
    Into,
};

pub enum RoomState {
    Joining,
    Dead,
}

// TODO: USER ADAPTERS!

impl From<i32> for RoomState {
    fn from(val: i32) -> Self {
        use RoomState::*;
        match val {
            0 => Joining,
            1 => Dead,
            // TODO: error not panic!
            _ => panic!("Unknown room state {}", val),
        }
    }
}

impl Into<i32> for RoomState {
    fn into(self) -> i32 {
        use RoomState::*;
        match self {
            Joining => 0,
            Dead => 1,
        }
    }
}

impl Into<graphql::models::RoomState> for RoomState {
    fn into(self) -> graphql::models::RoomState {
        match self {
            RoomState::Joining => graphql::models::RoomState::Joining,
            RoomState::Dead => graphql::models::RoomState::Dead,
        }
    }
}

pub struct Room {
    pub id: i32,
    pub join_code: String,
    pub players: i32,
    pub curr_players: i32,
    pub state: RoomState,
}

impl From<db::models::Room> for Room {
    fn from(room: models::Room) -> Self {
        Self {
            id: room.id,
            join_code: room.join_code,
            players: room.players,
            curr_players: room.curr_players,
            state: RoomState::from(room.state),
        }
    }
}

impl Into<db::models::Room> for Room {
    fn into(self) -> db::models::Room {
        db::models::Room {
            id: self.id,
            join_code: self.join_code,
            players: self.players,
            curr_players: self.curr_players,
            state: self.state.into(),
        }
    }
}


impl Into<graphql::models::Room> for Room {
    fn into(self) -> graphql::models::Room {
        graphql::models::Room {
            join_code: self.join_code,
            max_players: self.players,
            joined_players: self.curr_players,
            state: self.state.into(),
        }
    }
}

