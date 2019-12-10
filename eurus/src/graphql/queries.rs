use diesel::prelude::*;
use rand::prelude::*;

use crate::db;
use crate::adapters::{
    self,
    Adapter,
};
use crate::graphql::models::RoomState;


pub mod room {
    use super::*;

    pub(crate) fn insert_and_return(
        v: db::models::NewRoom,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Room> {
        use db::schema::rooms::dsl::{rooms, self};
        let jc = v.join_code.clone();
        diesel::insert_into(rooms)
            .values(v)
            .execute(&**db_conn)?;
        Ok(rooms.filter(
            dsl::join_code.eq(jc))
            .filter(dsl::state.eq(
                <adapters::RoomState as Adapter<RoomState, i32>>::adapt(RoomState::Joining)))
            .first::<db::models::Room>(&**db_conn)?)
    }

    pub(crate) fn get(
        join_code: &str,
        state: RoomState,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Room> {
        use db::schema::rooms::dsl;
        Ok(dsl::rooms.filter(
            dsl::join_code.eq(join_code))
            .filter(dsl::state.eq(
                <adapters::RoomState as Adapter<RoomState, i32>>::adapt(state)))
            .first::<db::models::Room>(&**db_conn)?)
    }

    pub(crate) fn get_id(
        join_code: &str,
        name: &str,
        state: RoomState,
        db_conn: &db::Connection
    ) -> QueryResult<i32> {
        use db::schema::rooms::dsl;
        Ok(dsl::rooms
            .select(dsl::id)
            .filter(dsl::join_code.eq(join_code))
            .filter(dsl::state.eq(
                <adapters::RoomState as Adapter<RoomState, i32>>::adapt(state)))
            .filter(dsl::name.eq(name))
            .first::<i32>(&**db_conn)?)
    }

    pub(crate) fn add_player(
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
            .first::<i64>(&**db_conn)?;
        if players_count == ((room.max_players-1) as i64) {
            use db::schema::rooms::dsl::*;
            diesel::update(rooms.filter(id.eq(room.id))).set(
                state.eq::<i32>(adapters::RoomState::Collecting.into())
            ).execute(&**db_conn)?;
        }
        let p_tok = rand::thread_rng().gen::<i32>();
        let player = db::models::NewPlayer {
            name: player_name,
            room_id: room.id,
            token: p_tok,
        };
        diesel::insert_into(players)
            .values(player)
            .execute(&**db_conn)?;
        Ok(players
            .filter(token.eq(p_tok))
            .first::<db::models::Player>(&**db_conn)?)
    }

    pub(crate) fn answers(
        join_code: &str,
        db_conn: &db::Connection
    ) -> QueryResult<Vec<db::models::Answer>> {
        use db::schema::answers::dsl;
        let room = get(join_code, RoomState::Polling, db_conn)?;
        let players = db::models::Player::belonging_to(&room)
            .load::<db::models::Player>(&**db_conn)?;
        db::models::Answer::belonging_to(&players)
            .filter(dsl::question_id.eq(room.curr_question_id.unwrap()))
            .load::<db::models::Answer>(&**db_conn)

    }
}

pub mod player {
    use super::*;

    pub(crate) fn get(
        player_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Player> {
        use db::schema::players::dsl::*;
        players.filter(id.eq(player_id)).first(&**db_conn)
    }
}

pub mod question {
    use super::*;

    pub(crate) fn get(
        question_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Question> {
        use db::schema::questions::dsl::*;
        questions.filter(id.eq(question_id)).first(&**db_conn)
    }

}