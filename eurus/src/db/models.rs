use crate::db::schema::users;
use diesel::{Insertable, Queryable};

#[derive(Queryable)]
pub struct User {
    pub id: i32,
    pub token: String,
    pub name: Option<String>,
}

#[derive(Insertable)]
#[table_name = "users"]
pub struct NewUser {
    pub name: Option<String>,
    pub token: String,
}
