use juniper::*;
use juniper_from_schema::graphql_schema_from_file;

use diesel::prelude::*;
use rand::prelude::*;

use crate::db::{
    self,
    adapters,
};
use crate::graphql::Context;

// TODO! THIS IS WIP FOR THE NEW GRAPHQL SCHEMA

graphql_schema_from_file!("../schema.graphql");

pub struct Query;

impl QueryFields for Query {

    fn field_user(
        &self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, User, Walked>,
        token: String,
    ) -> FieldResult<Option<User>> {
        use db::schema::users::dsl::{self, users};
        let db_conn = executor.context().db_conn();
        let mut u = users
            .filter(dsl::token.eq(&token))
            .load::<db::models::User>(&**db_conn)
            .expect("Couldn't load users from the database");
        let u = u.pop();
        if let Some(u) = u {
            Ok(Some(User {
                token: u.token,
                name: u.name,
                room_id: u.room_id,
            }))
        } else {
            Ok(None)
        }
    }
}

pub struct Mutation;

impl MutationFields for Mutation {
    fn field_new_user(
        &self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, User, Walked>,
        name: Option<String>,
    ) -> FieldResult<User> {
        use db::schema::users::dsl::users;
        let db_conn = executor.context().db_conn();
        let rnd_tok: String = rand::thread_rng()
            .sample_iter(&rand::distributions::Alphanumeric)
            .take(64)
            .collect();
        diesel::insert_into(users)
            .values(db::models::NewUser {
                token: rnd_tok.clone(),
                name: name.clone(),
            })
            .execute(&**db_conn)
            .expect("Error while creating new user");
        Ok(User {
            token: rnd_tok,
            name,
        })
    }
}

#[derive(Clone, Debug)]
pub struct User {
    pub token: String,
    pub name: Option<String>,
    pub room_id: i32,
}

impl UserFields for User {
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
        let mut room = rooms::dsl::rooms
            .filter(rooms::dsl::id.eq(self.room_id))
            .load::<db::models::Room>(&**db_conn)
            .expect("Couldn't get the room information for the user");
        let room: adapters::Room = room.pop()
            .expect("Got empty rooms vector for the player")
            .into();
        Ok(room.into())
    }
}

#[derive(Clone, Debug)]
pub struct Room {
    pub join_code: String,
    pub max_players: i32,
    pub joined_players: i32,
    pub state: RoomState,
}