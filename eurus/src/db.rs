use diesel;
use rocket_contrib::database;

pub mod models;
pub mod schema;

#[database("eurus_db")]
pub struct Connection(diesel::SqliteConnection);
