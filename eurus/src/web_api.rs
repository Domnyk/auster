use rocket::{
    get,
    post,
    State,
};

#[cfg(debug_assertions)]
use rocket::response;

use crate::graphql;

// TODO! Smth not working here

#[get("/")]
pub fn index() {}


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