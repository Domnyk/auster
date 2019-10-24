use diesel::Queryable;

#[derive(Queryable)]
pub struct User {
    pub id: i32, 
    pub token: String,
    pub name: Option<String>,
}