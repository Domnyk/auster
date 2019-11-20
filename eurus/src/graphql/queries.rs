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

    pub fn add_player(
        room: db::models::Room,
        player_name: String,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Player> {
        // XXX: Can be a race when 2 players
        // want to join a near full room
        use db::schema::players::dsl::*;
        let players_count = players
            .filter(room_id.eq(room.id))
            .count()
            .load::<i64>(&**db_conn)?
            .pop()
            .expect("Empty count query");
        if players_count == ((room.max_players-1) as i64) {
            use db::schema::rooms::dsl::*;
            diesel::update(rooms.filter(id.eq(room.id))).set(
                state.eq(adapters::RoomState::Collecting.into())
            ).execute(&**db_conn);
        }
        let p_tok = rand::thread_rng().gen::<i32>();
        let player = db::models::NewPlayer {
            name: player_name,
            room_id: room.id,
            token: p_tok,
        }
        diesel::insert_into(players)
            .values(player)
            .execute(&**db_conn)?;
        Ok(players
            .filter(token.eq(p_tok))
            .load::<db::models::Player>(&**db_conn)?
            .pop()
            .expect("Empty query")))
    }
}
