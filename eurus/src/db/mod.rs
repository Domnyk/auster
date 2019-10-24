use rocket_contrib::database;
use diesel;

pub mod schema;
pub mod models;

#[database("eurus_db")]
pub struct Connection(diesel::SqliteConnection);
