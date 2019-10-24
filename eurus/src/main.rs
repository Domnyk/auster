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
    rocket::ignite()
        .mount("/", routes![rest_api::index, rest_api::new_user,])
        .attach(db::Connection::fairing())
        .launch();
}
