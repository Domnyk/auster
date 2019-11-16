use juniper::*;
use juniper_from_schema::graphql_schema_from_file;

use diesel::prelude::*;
use rand::prelude::*;

use crate::db;
use crate::adapters::{
    self,
    Adapter,
};
use crate::graphql::{
    Context,
    models::{
        RoomState,
    },
};


pub mod room {
    use super::*;

    pub fn insert_and_return(
        v: db::models::NewRoom,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Room> {
        use db::schema::rooms::dsl::rooms;
        diesel::insert_into(rooms)
            .values(v)
            .execute(&**db_conn)?;
        last_inserted(&v.join_code, db_conn)
    }

    pub fn last_inserted(
        join_code: &str,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Room> {
        get(join_code, RoomState::Joining, db_conn)
    }

    pub fn get(
        join_code: &str,
        state: RoomState,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Room> {
        use db::schema::rooms::dsl::*;
        Ok(rooms.filter(join_code.eq(join_code))
            .filter(state.eq(
                <adapters::RoomState as Adapter<RoomState, i32>>::adapt(state)))
            .load::<db::models::Room>(&**db_conn)?
            .pop()
            .expect("Empty query"))
    }
}
