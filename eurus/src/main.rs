#![feature(proc_macro_hygiene, decl_macro)]
use dotenv;
use rocket::routes;
#[macro_use]
extern crate diesel;

pub mod db;
pub mod graphql;
pub mod rest_api;

fn main() {
    dotenv::dotenv().ok();
    let mut r = rocket::ignite()
        .manage(graphql::models::Schema::new(
            graphql::models::Query,
            graphql::models::Mutation))
        .mount("/", routes![
            rest_api::graphql_query,
            rest_api::graphql_mutation])
        .attach(db::Connection::fairing());
    if cfg!(debug_assertions) {
        r = r.mount("/dev", routes![
            rest_api::graphiql,
            rest_api::new_user,
            rest_api::index,
        ]);
    }
    r.launch();
}
