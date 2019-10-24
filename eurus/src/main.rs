#![feature(proc_macro_hygiene, decl_macro)]
use rocket::{
    get, 
    routes,
};
#[macro_use] extern crate diesel;
use diesel::prelude::*;
use dotenv;

pub mod db;

#[get("/")]
fn index(db: db::Connection) -> String {
    let mut res = String::from("Writing users: \n");
    let users = get_all_users(&db);
    for user in users {
        res += &format!("user {}: {}\n", user.id, user.token);
    }
    res
}

fn get_all_users(db: &db::Connection) -> Vec<db::models::User> {
    use db::schema::users::dsl::*;
    let sql_db: &diesel::SqliteConnection = &*db;
    let result = users.load::<db::models::User>(sql_db).expect("Error loading posts");
    result
}  

fn main() {
    dotenv::dotenv().ok();
    rocket::ignite()
        .mount("/", routes![index])
        .attach(db::Connection::fairing())
        .launch();
}