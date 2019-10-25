#[cfg(debug_assertions)]
use diesel::prelude::*;

use rocket::{
    get,
    post,
    State,
};

#[cfg(debug_assertions)]
use rocket::response;

#[cfg(debug_assertions)]
use crate::db;
use crate::graphql;

// TODO! Smth not working here

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
fn get_all_users(db: &db::Connection) -> Vec<db::models::User> {
    use db::schema::users::dsl::*;
    let sql_db: &diesel::SqliteConnection = &*db;
    users
        .load::<db::models::User>(sql_db)
        .expect("Error loading posts")
}


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