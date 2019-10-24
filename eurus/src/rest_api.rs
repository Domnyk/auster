use rocket::{
    get,
    post,
    http::Status,
};
use diesel::prelude::*;
use rand::prelude::*;

use crate::db;

#[get("/")]
pub fn index(db: db::Connection) -> String {
    let mut res = String::from("Writing users: \n");
    let users = get_all_users(&db);
    for user in users {
        res += &format!("user {}: {}\n", user.id, user.token);
    }
    res
}

#[post("/new")]
pub fn new_user(db: db::Connection) -> Status {
    use db::schema::users::dsl::*;
    let rnd_tok: String = thread_rng()
        .sample_iter(&rand::distributions::Alphanumeric)
        .take(64)
        .collect();
    diesel::insert_into(users)
        .values(db::models::NewUser {
            token: rnd_tok,
            name: None,
        })
        .execute(&*db)
        .expect("Error while creating new user");
    Status::Accepted
}

fn get_all_users(db: &db::Connection) -> Vec<db::models::User> {
    use db::schema::users::dsl::*;
    let sql_db: &diesel::SqliteConnection = &*db;
    users.load::<db::models::User>(sql_db)
        .expect("Error loading posts")
}
