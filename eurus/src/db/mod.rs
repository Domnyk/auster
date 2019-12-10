use diesel;
use rocket_contrib::database;

pub mod models;
pub mod schema;

pub(crate) type ConnectionType = diesel::SqliteConnection;

#[database("eurus_db")]
pub struct Connection(ConnectionType);