use juniper::*;
use juniper_from_schema::graphql_schema_from_file;

use diesel::prelude::*;
use rand::prelude::*;

use crate::db::{
    self,
    adapters::{
        self,
        Adapter,
    },
};
use crate::graphql::Context;

// TODO! THIS IS WIP FOR THE NEW GRAPHQL SCHEMA
// TODO! REFACTOR BLOCKS INTO HELPER METHODS

graphql_schema_from_file!("../schema.graphql");

pub struct Query;

impl QueryFields for Query {

    fn field_player (
        &self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, Player, Walked>,
        player_code: i32,
    ) -> FieldResult<Option<Player>> {
        use db::schema::players::dsl::{self, players};
        let db_conn = executor.context().db_conn();
        let mut p = players
            .filter(dsl::token.eq(&player_code))
            .load::<db::models::Player>(&**db_conn)?;
        if let Some(p) = p.pop() {
            Ok(Some(adapters::Player::adapt(p)))
        } else {
            Ok(None)
        }
    }
}

pub struct Mutation;

impl MutationFields for Mutation {

    fn field_new_room(&self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, Room, Walked>,
        name: String,
        players: i32
    ) -> FieldResult<Room> {
        let db_conn = executor.context().db_conn();
        let join_code: String = rand::thread_rng()
            .sample_iter(&rand::distributions::Alphanumeric)
            .take(8)
            .collect();
        let r = db::models::NewRoom {
            players,
            join_code: join_code.clone(),
        };
        let id = {
            use db::schema::rooms::dsl::*;
            diesel::insert_into(rooms)
                .values(r)
                .execute(&**db_conn)?;
            rooms.select(id)
                .filter(join_code.eq(join_code.clone()))
                .filter(state.eq(
                    <adapters::RoomState as Adapter<RoomState, i32>>::adapt(RoomState::Joining)))
                .load::<i32>(&**db_conn)?
                .pop()
                .expect("Empty query")
        };
        Ok(Room{
            id,
            name, 
            join_code,
            max_players: players,
            joined_players: 0,
            state: RoomState::Joining,
        })
    }

    fn field_join_room(&self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, User, Walked>,
        room_code: String,
        user_name: String
    ) -> FieldResult<Option<User>> {
        let db_conn = executor.context().db_conn();
        let room = {
            use db::schema::rooms::dsl::*;
            match rooms.filter(join_code.eq(room_code))
                .filter(state.eq(
                    <adapters::RoomState as Adapter<RoomState, i32>>::adapt(RoomState::Joining)))
                .load::<db::models::Room>(&**db_conn)?
                .pop() 
            {
                None => return Ok(None),
                Some(r) => r,
            }
        };
        {
            use db::schema::rooms::dsl::*;
            let target = rooms.filter(id.eq(room.id));
            if room.curr_players + 1 == room.players {
                diesel::update(target).set((
                    curr_players.eq(curr_players + 1),
                    state.eq(<adapters::RoomState as Adapter<RoomState, i32>>::adapt(RoomState::Dead))
                )).execute(&**db_conn)?;
            } else {
                diesel::update(target)
                    .set(curr_players.eq(curr_players + 1))
                    .execute(&**db_conn)?;
            }
        }
        let u = {
            use db::schema::users::dsl::*;
            let rng_token: String = rand::thread_rng()
                .sample_iter(&rand::distributions::Alphanumeric)
                .take(16)
                .collect();
            let u = db::models::NewUser{
                name: Some(user_name),
                token: rng_token,
                room_id: room.id,
            };
            diesel::insert_into(users)
                .values(u.clone())
                .execute(&**db_conn)?;
            u
        };
        Ok(Some(User{
            room_id: u.room_id,
            name: u.name,
            token: u.token,
        }))
    }
}

#[derive(Clone, Debug)]
pub struct Player {
    pub token: i32,
    pub name: String,
    pub room_id: i32,
    pub curr_answer_id: Option<i32>,
    pub points: i32,
}

impl PlayerFields for Player {
    fn field_token(&self, _: &Executor<'_, Context>) -> FieldResult<String> {
        Ok(self.token.clone())
    }

    fn field_name(&self, _: &Executor<'_, Context>) -> FieldResult<Option<String>> {
        Ok(self.name.clone())
    }

    fn field_room(&self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, Room, Walked>
    ) -> FieldResult<Room> {
        use db::schema::rooms;
        let db_conn = executor.context().db_conn();
        let room = rooms::dsl::rooms
            .filter(rooms::dsl::id.eq(self.room_id))
            .load::<db::models::Room>(&**db_conn)?
            .pop()
            .expect("Empty query result");
        Ok(adapters::Room::adapt(room))
    }
}

#[derive(Clone, Debug)]
pub struct Answer {
    pub id: i32,
    pub content: String,
    pub player_id: i32,
    pub question_id: i32,
}

#[derive(Clone, Debug)]
pub struct Question {
    pub content: String,
    pub player_id: i32,
    pub picked: bool,
}

#[derive(Clone, Debug)]
pub struct Room {
    pub name: String,
    pub join_code: String,
    pub max_players: i32,
    pub max_rounds: i32,
    pub curr_round: i32,
    pub state: RoomState,
    pub curr_player_id: Option<i32>,
    pub curr_question_id: Option<i32>,
}

impl RoomFields for Room {

    fn field_join_code(&self, _: &Executor<'_, Context>) -> FieldResult<String> {
        Ok(self.join_code.clone())
    }

    fn field_max_players(&self, _: &Executor<'_, Context>) -> FieldResult<i32> {
        Ok(self.max_players)
    }

    fn field_name(&self, _: &Executor<'_, Context>) -> FieldResult<String> {
        Ok(self.name.clone())
    }

    fn field_joined_players(&self, executor: &Executor<'_, Context>) -> FieldResult<i32> {
        let db_conn = executor.context().db_conn();
        use db::schema::users::dsl::*;
        let res = users
            .filter(room_id.eq(self.id))
            .count()
            .load::<i64>(&**db_conn)?
            .pop()
            .expect("Empty query result");
        Ok(res as i32)
    }

    fn field_state(&self, _: &Executor<'_, Context>) -> FieldResult<RoomState> {
        Ok(self.state)
    }

    fn field_players(&self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, User, Walked>
    ) -> FieldResult<Vec<User>> {
        let db_conn = executor.context().db_conn();
        use db::schema::users::dsl::*;
        let res = users
            .filter(room_id.eq(self.id))
            .load::<db::models::User>(&**db_conn)?;
        Ok(res
            .into_iter()
            .map(adapters::User::adapt)
            .collect())
    }
}