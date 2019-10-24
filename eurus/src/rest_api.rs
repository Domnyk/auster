use rocket::get;
use diesel::prelude::*;

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

fn get_all_users(db: &db::Connection) -> Vec<db::models::User> {
    use db::schema::users::dsl::*;
    let sql_db: &diesel::SqliteConnection = &*db;
    users.load::<db::models::User>(sql_db)
        .expect("Error loading posts")
}  
