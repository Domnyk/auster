#![feature(proc_macro_hygiene, decl_macro)]
use rocket::{
    get, 
    routes,
};
use rocket_contrib::{
    database,
};

#[macro_use] extern crate diesel;
use diesel::prelude::*;

pub mod schema;
pub mod models;

#[database("eurus_db")]
struct DBConnection(diesel::SqliteConnection);

#[get("/")]
fn index(db: DBConnection) -> String {
    let mut res = String::from("Writing posts: \n");
    let posts = get_all_posts(&*db);
    for post in posts {
        res += &format!("Post {}: {}\n", post.id, post.title);
    }
    res
}

fn get_all_posts(db: &diesel::SqliteConnection) -> Vec<models::Post> {
    use schema::posts::dsl::*;
    let result = posts.load::<models::Post>(db).expect("Error loading posts");
    result
}  

fn main() {
    rocket::ignite()
        .mount("/", routes![index])
        .attach(DBConnection::fairing())
        .launch();
}