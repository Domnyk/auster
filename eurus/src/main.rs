#![feature(proc_macro_hygiene, decl_macro)]
use dotenv;
use rocket::routes;
#[macro_use]
extern crate diesel;

pub mod db;
pub mod graphql;
pub mod web_api;

fn main() {
    dotenv::dotenv().ok();
    let mut r = rocket::ignite()
        .manage(graphql::models::Schema::new(
            graphql::models::Query,
            graphql::models::Mutation))
        .mount("/", routes![
            web_api::graphql_query,
            web_api::graphql_mutation])
        .attach(db::Connection::fairing());
    if cfg!(debug_assertions) {
        r = r.mount("/dev", routes![
            web_api::graphiql,
            web_api::index,
        ]);
    }
    r.launch();
}
