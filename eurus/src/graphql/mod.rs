use rocket::request::{self, FromRequest, Request};

use crate::db;

pub mod models;
mod queries;

pub struct Context {
    db: db::Connection,
}

impl Context {
    pub fn db_conn(&self) -> &db::Connection {
        &self.db
    }
}

impl juniper::Context for Context {}

impl<'a, 'r> FromRequest<'a, 'r> for Context {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<Context, ()> {
        let db = request.guard::<db::Connection>()?;
        rocket::Outcome::Success(Context { db })
    }
}
