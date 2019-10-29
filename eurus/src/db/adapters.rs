use crate::db;
use crate::graphql;

use std::convert::{
    From,
    Into,
};


// TODO: Refactor adapters to higher module
// it doesn't operate on db types only anymore

pub trait Adapter<T, U> {
    fn adapt(t: T) -> U;
}

impl<A, T, U> Adapter<T, U> for A
where
    A: From<T> + Into<U>
{
    fn adapt(t: T) -> U {
        A::from(t).into()
    }
}


pub enum RoomState {
    Joining,
    Dead,
}

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


impl From<graphql::models::RoomState> for RoomState {
    fn from(s: graphql::models::RoomState) -> Self {
        use graphql::models::RoomState::*;
        match s {
            Joining => Self::Joining,
            Dead => Self::Dead,
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
    pub name: String,
    pub join_code: String,
    pub players: i32,
    pub curr_players: i32,
    pub state: RoomState,
}

impl From<db::models::Room> for Room {
    fn from(room: db::models::Room) -> Self {
        Self {
            id: room.id,
            name: room.name,
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
            name: self.name,
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
            id: self.id,
            name: self.name,
            join_code: self.join_code,
            max_players: self.players,
            joined_players: self.curr_players,
            state: self.state.into(),
        }
    }
}


pub struct User {
    pub id: i32, 
    pub token: String,
    pub name: Option<String>,
    pub room_id: i32,
}

impl From<db::models::User> for User {
    fn from(u: db::models::User) -> Self {
        Self {
            id: u.id,
            token: u.token,
            name: u.name,
            room_id: u.room_id,
        }
    }
}

impl Into<db::models::User> for User {
    fn into(self) -> db::models::User {
        db::models::User {
            id: self.id,
            token: self.token,
            name: self.name,
            room_id: self.room_id,
        }
    } 
}

impl Into<graphql::models::User> for User {
    fn into(self) -> graphql::models::User {
        graphql::models::User {
            token: self.token,
            name: self.name,
            room_id: self.room_id,
        }
    }
}