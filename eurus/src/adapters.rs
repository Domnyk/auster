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
	Collecting,
	Answering,
	Polling,
	Dead,
}

impl From<i32> for RoomState {
    fn from(val: i32) -> Self {
        use RoomState::*;
        match val {
            0 => Joining,
            1 => Collecting,
            2 => Answering,
            3 => Polling,
            4 => Dead,
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
            Answering => Self::Answering,
            Polling => Self::Polling,
            Collecting => Self::Collecting,
        }
    }
}

impl Into<i32> for RoomState {
    fn into(self) -> i32 {
        use RoomState::*;
        match self {
            Joining => 0,
            Collecting => 1,
            Answering => 2,
            Polling => 3,
            Dead => 4,
        }
    }
}

impl Into<graphql::models::RoomState> for RoomState {
    fn into(self) -> graphql::models::RoomState {
        match self {
            RoomState::Joining => graphql::models::RoomState::Joining,
            RoomState::Dead => graphql::models::RoomState::Dead,
            RoomState::Collecting => graphql::models::RoomState::Collecting,
            RoomState::Polling => graphql::models::RoomState::Polling,
            RoomState::Answering => graphql::models::RoomState::Answering,
        }
    }
}


pub struct Room(db::models::Room);

impl From<db::models::Room> for Room {
    fn from(room: db::models::Room) -> Self {
        Self(room)
    }
}

impl Into<graphql::models::Room> for Room {
    fn into(self) -> graphql::models::Room {
        graphql::models::Room {
            name: self.0.name,
            join_code: self.0.join_code,
            max_players: self.0.max_players,
            max_rounds: self.0.num_of_rounds,
            curr_round: self.0.curr_round,
            state: RoomState::adapt(self.0.state),
            curr_player_id: self.0.curr_player_id,
            curr_question_id: self.0.curr_question_id,
        }
    }
}


pub struct Player(db::models::Player);

impl From<db::models::Player> for Player {
    fn from(p: db::models::Player) -> Self {
        Self(p)
    }
}

impl Into<graphql::models::Player> for Player {
    fn into(self) -> graphql::models::Player {
        graphql::models::Player {
            token: self.0.token,
            name: self.0.name,
            points: self.0.score,
            curr_answer_id: self.0.answer_id,
            room_id: self.0.room_id,
        }
    }
}

pub struct Answer(db::models::Answer);

impl From<db::models::Answer> for Answer {
    fn from(a: db::models::Answer) -> Self {
        Self(a)
    }
}

impl Into<graphql::models::Answer> for Answer {
    fn into(self) -> graphql::models::Answer {
        graphql::models::Answer {
            id: self.0.id,
            content: self.0.answer,
            player_id: self.0.id,
            question_id: self.0.question_id,
        }
    }
}

pub struct Question(db::models::Question);

impl From<db::models::Question> for Question {
    fn from(q: db::models::Question) -> Self {
        Self(q)
    }
}

impl Into<graphql::models::Question> for Question {
    fn into(self) -> graphql::models::Question {
        graphql::models::Question {
            content: self.0.question,
            player_id: self.0.id,
            picked: self.0.was_picked,
        }
    }
}