#[cfg(debug_assertions)]
use diesel::prelude::*;
#[cfg(debug_assertions)]
use rand::prelude::*;

use rocket::{
    get,
    post,
    State,
};

#[cfg(debug_assertions)]
use rocket::{
    http::Status,
    response,
};

#[cfg(debug_assertions)]
use crate::db;
use crate::graphql;

#[cfg(debug_assertions)]
#[get("/")]
pub fn index(db: db::Connection) -> String {
    let mut res = String::from("Writing users: \n");
    let users = get_all_users(&db);
    for user in users {
        res += &format!("user {}: {}\n", user.id, user.token);
    }
    res
}

#[cfg(not(debug_assertions))]
#[get("/")]
pub fn index() {}

#[cfg(debug_assertions)]
#[post("/new", data = "<user_name>")]
pub fn new_user(user_name: Option<String>, db: db::Connection) -> Status {
    use db::schema::users::dsl::*;
    let rnd_tok: String = thread_rng()
        .sample_iter(&rand::distributions::Alphanumeric)
        .take(64)
        .collect();
    diesel::insert_into(users)
        .values(db::models::NewUser {
            token: rnd_tok,
            name: user_name,
        })
        .execute(&*db)
        .expect("Error while creating new user");
    Status::Accepted
}

#[cfg(debug_assertions)]
fn get_all_users(db: &db::Connection) -> Vec<db::models::User> {
    use db::schema::users::dsl::*;
    let sql_db: &diesel::SqliteConnection = &*db;
    users
        .load::<db::models::User>(sql_db)
        .expect("Error loading posts")
}

#[cfg(not(debug_assertions))]
#[post("/new")]
pub fn new_user() {}

#[cfg(debug_assertions)]
#[get("/graphiql")]
pub fn graphiql() -> response::content::Html<String> {
    juniper_rocket::graphiql_source("/graphql")
}

#[cfg(not(debug_assertions))]
#[get("/graphiql")]
pub fn graphiql() {}

#[get("/graphql?<request>")]
pub fn graphql_query(
    context: graphql::Context,
    request: juniper_rocket::GraphQLRequest,
    schema: State<graphql::models::Schema>
) -> juniper_rocket::GraphQLResponse {
    request.execute(&schema, &context)
}

#[post("/graphql", data = "<request>")]
pub fn graphql_mutation(
    context: graphql::Context,
    request: juniper_rocket::GraphQLRequest,
    schema: State<graphql::models::Schema>
) -> juniper_rocket::GraphQLResponse {
    request.execute(&schema, &context)
}