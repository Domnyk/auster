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
    queries,
    Context,
};

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
        Ok(p.pop().map(adapters::Player::adapt))
    }
}

pub struct Mutation;

impl Mutation {

    fn gen_join_code() -> String {
        rand::thread_rng()
            .sample_iter(&rand::distributions::Alphanumeric)
            .take(8)
            .collect()
    }
}

impl MutationFields for Mutation {

    fn field_new_room(&self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, Room, Walked>,
        name: String,
        players: i32,
        rounds: i32
    ) -> FieldResult<Room> {
        let db_conn = executor.context().db_conn();
        let r = db::models::NewRoom {
            name,
            max_players: players,
            join_code: Self::gen_join_code(),
            num_of_rounds: rounds,
        };
        let r = queries::room::insert_and_return(r, db_conn)?;
        Ok(adapters::Room::adapt(r))
    }

    fn field_join_room(&self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, Player, Walked>,
        room_code: String,
        player_name: String
    ) -> FieldResult<Option<Player>> {
        let db_conn = executor.context().db_conn();
        // XXX: match on error and return none
        let room = queries::room::get(
            &room_code, RoomState::Joining, db_conn)?;
        let player = queries::room::add_player(
            room,
            player_name,
            db_conn)?;
        Ok(Some(adapters::Player::adapt(player)))
    }

    fn field_send_question(&self,
        _: &Executor<'_, Context>,
        _: &QueryTrail<'_, Question, Walked>,
        _token: i32,
        _content: String
    ) -> FieldResult<Option<Question>> {
        unimplemented!("Mutation send_question")
    }

    fn field_send_answer(&self,
        _: &Executor<'_, Context>,
        _: &QueryTrail<'_, Answer, Walked>,
        _token: i32,
        _content: String
    ) -> FieldResult<Option<Answer>> {
        unimplemented!("mutation send_answer")
    }

    fn field_poll_answer(&self,
        _: &Executor<'_, Context>,
        _: &QueryTrail<'_, Answer, Walked>,
        _token: i32,
        _answer: i32
    ) -> FieldResult<Option<Answer>> {
        unimplemented!("mutation poll asnwer")
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
    fn field_token(&self, _: &Executor<'_, Context>) -> FieldResult<i32> {
        Ok(self.token)
    }

    fn field_name(&self, _: &Executor<'_, Context>) -> FieldResult<Option<String>> {
        Ok(Some(self.name.clone()))
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

    fn field_polled_answer(&self,
        _: &Executor<'_, Context>,
        _: &QueryTrail<'_, Answer, Walked>
    ) -> FieldResult<Option<Answer>> {
        unimplemented!("player polled_answer");
    }

    fn field_points(&self, _: &Executor<'_, Context>) -> FieldResult<i32> {
        Ok(self.points)
    }
}

#[derive(Clone, Debug)]
pub struct Answer {
    pub id: i32,
    pub content: String,
    pub player_id: i32,
    pub question_id: i32,
}

impl AnswerFields for Answer {
    
    fn field_id(&self, _: &Executor<'_, Context>) -> FieldResult<i32> {
        Ok(self.id)
    }

    fn field_content(&self, _: &Executor<'_, Context>) -> FieldResult<String> {
        Ok(self.content.clone())
    }

    fn field_player(&self,
        _: &Executor<'_, Context>,
        _: &QueryTrail<'_, Player, Walked>
    ) -> FieldResult<Player> {
        unimplemented!("Answer player")
    }

    fn field_question(&self,
        _: &Executor<'_, Context>,
        _: &QueryTrail<'_, Question, Walked>
    ) -> FieldResult<Question> {
        unimplemented!("Answer question")
    }
}

#[derive(Clone, Debug)]
pub struct Question {
    pub content: String,
    pub player_id: i32,
    pub picked: bool,
}

impl QuestionFields for Question {

    fn field_content(&self, _: &Executor<'_, Context>) -> FieldResult<String> {
        Ok(self.content.clone())
    }

    fn field_player(&self,
        _: &Executor<'_, Context>,
        _: &QueryTrail<'_, Player, Walked>
    ) -> FieldResult<Player> {
        unimplemented!("question player")
    }

    fn field_picked(&self, _: &Executor<'_, Context>) -> FieldResult<bool> {
        Ok(self.picked)
    }

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

    fn field_max_rounds(&self, _: &Executor<'_, Context>) -> FieldResult<i32> {
        Ok(self.max_rounds)
    }

    fn field_curr_round(&self, _: &Executor<'_, Context>) -> FieldResult<i32> {
        Ok(self.curr_round)
    }

    fn field_state(&self, _: &Executor<'_, Context>) -> FieldResult<RoomState> {
        Ok(self.state)
    }


    fn field_curr_player(&self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, Player, Walked>
    ) -> FieldResult<Option<Player>> {
        let db_conn = executor.context().db_conn();
        Ok(self.curr_player_id.map(|player_id| {
            use db::schema::players::dsl::*;
            let p = players
                .filter(id.eq(player_id))
                .load::<db::models::Player>(&**db_conn)
                .expect("Couldn't execute query")
                .pop()
                .expect("Empty query result");
            adapters::Player::adapt(p)
        }))
    }


    fn field_players(&self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, Player, Walked>
    ) -> FieldResult<Vec<Player>> {
        let db_conn = executor.context().db_conn();
        use db::schema::players::dsl::*;
        let r_id = queries::room::get_id(
            &self.join_code,
            &self.name,
            self.state,
            db_conn
        )?;
        let res = players
            .filter(room_id.eq(r_id))
            .load::<db::models::Player>(&**db_conn)?;
        Ok(res
            .into_iter()
            .map(adapters::Player::adapt)
            .collect())
    }

    fn field_curr_answers(&self,
        _: &Executor<'_, Context>,
        _: &QueryTrail<'_, Answer, Walked>
    ) -> FieldResult<Option<Vec<Answer>>> {
        unimplemented!("Room Curr Answer");
    }

    fn field_curr_question(&self,
        _: &Executor<'_, Context>,
        _: &QueryTrail<'_, Question, Walked>
    ) -> FieldResult<Option<Question>> {
        unimplemented!("Romm Curr Question");
    }
}