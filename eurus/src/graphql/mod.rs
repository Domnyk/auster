use rocket::request::{self, FromRequest, Request};
use rocket::State;

use crate::db;
use std::sync::{Arc, Mutex};
use std::clone::Clone;

pub mod models;
mod queries;

use crate::Lock;

pub struct Context {
    db: db::Connection,
    lock: Lock,
}

impl Context {
    pub fn db_conn(&self) -> &db::Connection {
        &self.db
    }

    pub fn get_lock(&self) -> &Mutex<i32> {
        &self.lock.mutex
    }
}

impl juniper::Context for Context {}

impl<'a, 'r> FromRequest<'a, 'r> for Context {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<Context, ()> {
        let db = request.guard::<db::Connection>()?;
        let lock = request.guard::<State<Lock>>()?;
        rocket::Outcome::Success(Context { 
            db,
            lock: (*lock).clone(),
        })
    }
}
