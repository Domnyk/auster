use std::collections::HashMap;

use diesel::prelude::*;
use rand::prelude::*;

use crate::db;
use crate::adapters::{
    self,
    Adapter,
};
use crate::graphql::models::RoomState;
use crate::data;

pub(crate) mod room {
    use super::*;

    pub fn insert_and_return(
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

    pub fn get(
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

    pub fn get_id(
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

    pub fn get_by_player(
        player: &db::models::Player,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Room> {
        use db::schema::rooms::dsl::*;
        rooms.filter(id.eq(player.room_id)).first(&**db_conn)
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
            .first::<i64>(&**db_conn)?;
        if players_count == ((room.max_players-1) as i64) {
            use db::schema::rooms::dsl::*;
            diesel::update(&room).set(
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

    pub fn answers(
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

    pub fn questions_count(
        join_code: &str,
        db_conn: &db::Connection
    ) -> QueryResult<i64> {
        let room = get(join_code, RoomState::Collecting, db_conn)?;
        let players = db::models::Player::belonging_to(&room).load(&**db_conn)?;
        db::models::Question::belonging_to(&players).count().first(&**db_conn)
    }

    pub fn not_picked_questions(
        room_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<Vec<db::models::Question>> {
        println!("Getting not picked questions");
        let room: db::models::Room = {
            use db::schema::rooms::dsl::*;
            let q = rooms.find(room_id)
                .filter(
                    state.eq::<i32>(adapters::RoomState::Collecting.into())
                    .or(state.eq::<i32>(adapters::RoomState::Polling.into())));
            println!("Query for getting the room: {}", diesel::debug_query::<diesel::sqlite::Sqlite, _>(&q));
            q.first(&**db_conn)?
        };
        println!("Room is {}: {}", room.id, room.join_code);
        let players: Vec<db::models::Player> = 
            db::models::Player::belonging_to(&room).load(&**db_conn)?;
        println!("Printing rooms players");
        for p in &players {
            println!("Picked player {}: {}", p.id, p.name);
        }
        use db::schema::questions::dsl::*;
        db::models::Question::belonging_to(&players)
            .filter(was_picked.eq(false)).load(&**db_conn)
    }

    pub fn pick_question(
        room_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<i32> {
        let questions = not_picked_questions(room_id, db_conn)?;
        let question_id = questions.first()
            .expect("No more questions to pick from")
            .id;
        {
            use db::schema::rooms::dsl::*;
            diesel::update(rooms.find(room_id))
                .set(curr_question_id.eq(Some(question_id)))
                .execute(&**db_conn)?;
        }
        {
            use db::schema::questions::dsl::*;
            diesel::update(questions.find(question_id))
                .set(was_picked.eq(true))
                .execute(&**db_conn)?;
        }
        Ok(question_id)
    }

    pub fn pick_player(
        room_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<i32> {
        let player_id = not_picked_players(room_id, db_conn)?
            .first()
            .expect("No more players to pick from")
            .id;
        {
            use db::schema::rooms::dsl::*;
            diesel::update(rooms.find(room_id)).set(
                curr_player_id.eq(Some(player_id)))
                .execute(&**db_conn)?;
        }
        {
            use db::schema::players::dsl::*;
            diesel::update(players.find(player_id))
                .set(was_picked.eq(true))
                .execute(&**db_conn)?;
        }
        Ok(player_id)
    }

    pub fn not_picked_players(
        room_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<Vec<db::models::Player>> {
        use db::schema::rooms::dsl::*;
        let room = rooms.filter(id.eq(room_id)).load(&**db_conn)?;
        {
            use db::schema::players::dsl::*;
            db::models::Player::belonging_to(&room)
                .filter(was_picked.eq(false))
                .load(&**db_conn)
        }
    }

    pub fn not_picked_players_count(
        room: &db::models::Room,
        db_conn: &db::Connection
    ) -> QueryResult<i64> {
        use db::schema::players::dsl::*;
        db::models::Player::belonging_to(room)
            .filter(was_picked.eq(false))
            .count()
            .get_result(&**db_conn)
    }

    pub fn increment_round(
        room: &db::models::Room,
        db_conn: &db::Connection
    ) -> QueryResult<usize> {
        use db::schema::rooms::dsl::*;
        diesel::update(room)
            .set(curr_round.eq(curr_round + 1))
            .execute(&**db_conn)
    }

    // TODO: Delete this query in future release
    // It's buggy as hell
    pub fn all_questions(
        room_code: &str,
        db_conn: &db::Connection
    ) -> QueryResult<Vec<db::models::Question>> {
        let room = {
            use db::schema::rooms::dsl::*;
            room.filter(
                join_code.eq(room_code))
                .first(&**db_conn)?
        };
        let players: Vec<db::models::Player> = 
            db::models::Player::belonging_to(&room).load(&**db_conn)?;
        let questions: Vec<db::models::Question> =
            db::models::Question::belonging_to(&players).load(&**db_conn)?;
        Ok(questions)
    }
}

pub(crate) mod player {
    use super::*;

    pub fn get(
        player_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Player> {
        use db::schema::players::dsl::*;
        players.find(player_id).first(&**db_conn)
    }

    pub fn get_by_tok(
        p_tok: i32,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Player> {
        use db::schema::players::dsl::*;
        players.filter(token.eq(p_tok)).first(&**db_conn)
    }

    pub fn poll_ans(
        p_tok: i32,
        ans_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Answer> {
        let p = player::get_by_tok(p_tok, db_conn)?;
        let r = {
            use db::schema::rooms::dsl::*;
            rooms.find(p.room_id)
                .filter(state.eq::<i32>(adapters::RoomState::Polling.into()))
                .first(&**db_conn)?
        };
        answer::can_be_polled(&r, ans_id, db_conn)?;
        {
            use db::schema::players::dsl::*;
            let p: db::models::Player = players
                .filter(token.eq(p_tok))
                .filter(answer_id.is_null())
                .filter(id.ne(r.curr_player_id.unwrap()))
                .first(&**db_conn)?;
            diesel::update(&p)
                .set(answer_id.eq(ans_id))
                .execute(&**db_conn)?;
        };
        let a_count: i64 = {
            use db::schema::players::dsl::*;
            db::models::Player::belonging_to(&r)
                .filter(answer_id.is_not_null())
                .count()
                .get_result(&**db_conn)?
        };
        let mut game_ended = false;
        if (a_count + 1) == r.max_players as i64 {
            allocate_points(&r, db_conn)?;
            clear_players_answers(&r, db_conn)?;
            if room::not_picked_players_count(&r, db_conn)? == 0 {
                room::increment_round(&r, db_conn)?;
                clear_players_picked(&r, db_conn)?;
                if (r.curr_round+1) == r.num_of_rounds {
                    use db::schema::rooms::dsl::*;
                    diesel::update(&r).set(
                        state.eq::<i32>(adapters::RoomState::Dead.into()))
                        .execute(&**db_conn)?;
                    game_ended = true;
                }
            }
            if !game_ended {
                use db::schema::rooms::dsl::*;
                room::pick_question(r.id, db_conn)?;
                room::pick_player(r.id, db_conn)?;
                diesel::update(&r).set(
                    state.eq::<i32>(adapters::RoomState::Answering.into())
                ).execute(&**db_conn)?;
            }
        }
        use db::schema::answers::dsl as adsl;
        adsl::answers.find(ans_id).first(&**db_conn)
    }

    pub fn allocate_points(
        r: &db::models::Room,
        db_conn: &db::Connection
    ) -> QueryResult<()> {
        let mut ps: Vec<db::models::Player> = 
            db::models::Player::belonging_to(r).load(&**db_conn)?;
        let ans: db::models::Answer = {
            use db::schema::answers::dsl::*;
            answers
                .filter(question_id.eq(r.curr_question_id.unwrap()))
                .filter(player_id.eq(r.curr_player_id.unwrap()))
                .first(&**db_conn)?
        };
        let mut points_delta: HashMap<i32, i32> = HashMap::new();
        for p in ps.iter().filter(|player| player.id != r.curr_player_id.unwrap()) {
            if p.answer_id.unwrap() == ans.id {
                let delta = points_delta.entry(p.id).or_default();
                *delta += data::points::CORRECT_ANS;
            } else {
                use db::schema::answers::dsl::*;
                let a: db::models::Answer = answers.find(p.answer_id.unwrap()).first(&**db_conn)?;
                let delta = points_delta.entry(a.player_id).or_default();
                *delta += data::points::ANSWER_CHOSEN;
            }
        }
        for p in &mut ps {
            use db::schema::players::dsl::*;
            diesel::update(players.find(p.id))
                .set(score.eq(score + *points_delta.entry(p.id).or_default()))
                .execute(&**db_conn)?;
        }
        Ok(())
    }

    pub fn clear_players_answers(
        r: &db::models::Room,
        db_conn: &db::Connection
    ) -> QueryResult<usize> {
        use db::schema::players::dsl::*;
        diesel::update(players.filter(room_id.eq(r.id)))
            .set(answer_id.eq::<Option<i32>>(None))
            .execute(&**db_conn)
    }

    pub fn clear_players_picked(
        r: &db::models::Room,
        db_conn: &db::Connection
    ) -> QueryResult<usize> {
        use db::schema::players::dsl::*;
        diesel::update(players.filter(room_id.eq(r.id)))
            .set(was_picked.eq(false))
            .execute(&**db_conn)
    }
}


pub(crate) mod question {
    use super::*;

    pub fn get(
        question_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Question> {
        use db::schema::questions::dsl::*;
        questions.filter(id.eq(question_id)).first(&**db_conn)
    }

    pub fn new(
        p_token: i32,
        content: &str,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Question> {
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
            room::pick_player(room.id, db_conn)?;
            diesel::update(&room).set(
                state.eq::<i32>(adapters::RoomState::Answering.into())
            ).execute(&**db_conn)?;
        }
        Ok(last_q)
        
    }

}

pub(crate) mod answer {
    use super::*;

    pub fn new(
        p_tok: i32,
        content: &str,
        db_conn: &db::Connection
    ) -> QueryResult<db::models::Answer> {
        let player: db::models::Player = {
            use db::schema::players::dsl::*;
            players.filter(token.eq(p_tok)).first(&**db_conn)?
        };
        let room: db::models::Room = {
            use db::schema::rooms::dsl::*;
            rooms
                .find(player.room_id)
                .filter(state.eq::<i32>(adapters::RoomState::Answering.into()))
                .first(&**db_conn)?
        };
        let curr_question_id = room.curr_question_id
            .expect("Question id shouldn't be empty");
        let answers_count: i64 = {
            use db::schema::answers::dsl::*;
            db::models::Answer::belonging_to(&player)
                .filter(question_id.eq(curr_question_id))
                .count()
                .get_result(&**db_conn)?
        };
        if answers_count > 0 {
            return Err(diesel::result::Error::NotFound);
        }
        let answer: db::models::Answer = {
            use db::schema::answers::dsl::*;
            diesel::insert_into(answers)
                .values(db::models::NewAnswer{
                    answer: String::from(content),
                    player_id: player.id,
                    question_id: curr_question_id,
                })
                .execute(&**db_conn)?;
            answers.filter(player_id.eq(player.id))
                .filter(question_id.eq(curr_question_id))
                .first(&**db_conn)?
        };
        let players_left = {
            use db::schema::answers::dsl::*;
            let ps = db::models::Player::belonging_to(&room)
                .load(&**db_conn)?;
            let ans: i64 = db::models::Answer::belonging_to(&ps)
                .filter(question_id.eq(curr_question_id))
                .count()
                .get_result(&**db_conn)?;
            room.max_players as i64 - ans 
        };
        if players_left == 0 {
            use db::schema::rooms::dsl::*;
            diesel::update(&room)
                .set(state.eq::<i32>(adapters::RoomState::Polling.into()))
                .execute(&**db_conn)?;
        }
        Ok(answer)
    }

    pub fn can_be_polled(
        r: &db::models::Room,
        ans_id: i32,
        db_conn: &db::Connection
    ) -> QueryResult<()> {
        use db::schema::answers::dsl::*;
        let ps: Vec<db::models::Player> = 
            db::models::Player::belonging_to(r).load(&**db_conn)?;
        db::models::Answer::belonging_to(&ps)
            .filter(question_id.eq(r.curr_question_id.unwrap()))
            .filter(id.eq(ans_id))
            .first::<db::models::Answer>(&**db_conn)?;
        Ok(())
    }
}