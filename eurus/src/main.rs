#![feature(proc_macro_hygiene, decl_macro)]
use rocket::routes;
use dotenv;
#[macro_use] extern crate diesel;

pub mod db;
pub mod rest_api;

fn main() {
    dotenv::dotenv().ok();
    rocket::ignite()
        .mount("/", routes![rest_api::index])
        .attach(db::Connection::fairing())
        .launch();
}