use diesel::{
    Queryable,
    Insertable,
};
use crate::db::schema::users;

#[derive(Queryable)]
pub struct User {
    pub id: i32, 
    pub token: String,
    pub name: Option<String>,
}

#[derive(Insertable)]
#[table_name="users"]
pub struct NewUser {
    pub name: Option<String>,
    pub token: String,
}