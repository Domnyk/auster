use juniper::*;
use juniper_from_schema::graphql_schema_from_file;

use diesel::prelude::*;
use rand::prelude::*;

use crate::db;
use crate::graphql::Context;

graphql_schema_from_file!("../schema.graphql");

pub struct Query;

impl QueryFields for Query {
    fn field_users(
        &self,
        executor: &Executor<'_, Context>,
        _: &QueryTrail<'_, User, Walked>,
    ) -> FieldResult<Vec<User>> {
        use db::schema::users::dsl::*;
        let db_conn = executor.context().db_conn();
        let u = users
            .load::<db::models::User>(&**db_conn)
            .expect("Couldn't load users from the db");
        Ok(u.into_iter()
            .map(|user| User {
                token: user.token,
                name: user.name,
            })
            .collect())
    }

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
}

impl UserFields for User {
    fn field_token(&self, _: &Executor<'_, Context>) -> FieldResult<String> {
        Ok(self.token.clone())
    }

    fn field_name(&self, _: &Executor<'_, Context>) -> FieldResult<Option<String>> {
        Ok(self.name.clone())
    }
}
