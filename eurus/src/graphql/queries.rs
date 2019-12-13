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
        rooms.filter(
            dsl::join_code.eq(jc))
            .filter(dsl::state.eq(
                <adapters::RoomState as Adapter<RoomState, i32>>::adapt(RoomState::Joining)))
            .first(&**db_conn)
    }

    pub(crate) fn get(
        join_code: &str,
        state: RoomState,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Room> {
        use db::schema::rooms::dsl;
        dsl::rooms.filter(
            dsl::join_code.eq(join_code))
            .filter(dsl::state.eq(
                <adapters::RoomState as Adapter<RoomState, i32>>::adapt(state)))
            .first(&**db_conn)
    }

    // pub(crate) fn get_by_id(
    //     room_id: i32,
    //     room_state: RoomState,
    //     db_conn: &db::Connection
    // ) -> QueryResult<db::models::Room> {
    //     use db::schema::rooms::dsl::*;
    //     rooms.filter(id.eq(room_id))
    //         .filter(state.eq(
    //             <adapters::RoomState as Adapter<RoomState, i32>>::adapt(room_state)))
    //         .first(&**db_conn)
    // }

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
            .first(&**db_conn)?)
    }

    pub(crate) fn get_by_player(
        player: &db::models::Player,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Room> {
        use db::schema::rooms::dsl::*;
        rooms.filter(id.eq(player.room_id)).first(&**db_conn)
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
        players
            .filter(token.eq(p_tok))
            .first(&**db_conn)
    }

    pub(crate) fn answers(
        join_code: &str,
        db_conn: &db::Connection
    ) -> QueryResult<Vec<db::models::Answer>> {
        use db::schema::answers::dsl;
        let room = get(join_code, RoomState::Polling, db_conn)?;
        let players = db::models::Player::belonging_to(&room).load(&**db_conn)?;
        db::models::Answer::belonging_to(&players)
            .filter(dsl::question_id.eq(room.curr_question_id.unwrap()))
            .load(&**db_conn)
    }

    pub(crate) fn questions_count(
        join_code: &str,
        db_conn: &db::Connection
    ) -> QueryResult<i64> {
        let room = get(join_code, RoomState::Collecting, db_conn)?;
        let players = db::models::Player::belonging_to(&room).load(&**db_conn)?;
        db::models::Question::belonging_to(&players).count().first(&**db_conn)
    }

    pub(crate) fn not_picked_questions(
        room_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<Vec<db::models::Question>> {
        let room: db::models::Room = {
            use db::schema::rooms::dsl::*;
            rooms.filter(id.eq(room_id))
                .filter(state.eq::<i32>(adapters::RoomState::Collecting.into()))
                .or_filter(state.eq::<i32>(adapters::RoomState::Polling.into()))
                .first(&**db_conn)?
        };
        let players = db::models::Player::belonging_to(&room).load(&**db_conn)?;
        use db::schema::questions::dsl::*;
        db::models::Question::belonging_to(&players)
            .filter(was_picked.eq(false)).load(&**db_conn)
    }

    pub(crate) fn pick_question(
        room_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<i32> {
        let question_id = not_picked_questions(room_id, db_conn)?
            .first()
            .expect("No more questions to pick from")
            .id;
        use db::schema::rooms::dsl::*;
        diesel::update(rooms.find(room_id)).set(
            curr_question_id.eq(Some(question_id)))
            .execute(&**db_conn)?;
        Ok(question_id)
    }
}

pub mod player {
    use super::*;

    pub(crate) fn get(
        player_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Player> {
        use db::schema::players::dsl::*;
        players.find(player_id).first(&**db_conn)
    }

    pub(crate) fn get_by_tok(
        p_tok: i32,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Player> {
        use db::schema::players::dsl::*;
        players.filter(token.eq(p_tok)).first(&**db_conn)
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

    pub(crate) fn new(
        p_token: i32,
        content: &str,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Question> {
        unimplemented!("queries::question::new");
        // TODO: when picking a question remember to pick
        // a player to ask the question to.
        // Right now it just doesn't work
        let player = player::get_by_tok(p_token, db_conn)?;
        let room = room::get_by_player(&player, db_conn)?;
        let question = db::models::NewQuestion{
            question: String::from(content),
            player_id: player.id,
        };
        use db::schema::questions::dsl as qdsl;
        diesel::insert_into(qdsl::questions)
            .values(question)
            .execute(&**db_conn)?;
        let last_q: db::models::Question = qdsl::questions
            .filter(qdsl::player_id.eq(player.id))
            .filter(qdsl::question.eq(content))
            .first(&**db_conn)?;
        let q_count = room::questions_count(&room.join_code, db_conn)?;
        if q_count >= (room.max_players * room.num_of_rounds) as i64 {
            use db::schema::rooms::dsl::*;
            room::pick_question(room.id, db_conn)?;
            diesel::update(rooms.filter(id.eq(room.id))).set(
                state.eq::<i32>(adapters::RoomState::Answering.into())
            ).execute(&**db_conn)?;
        }
        Ok(last_q)
        
    }

}