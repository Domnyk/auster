# building

* `rustup update && cargo update`
* install database drivers which diesel supports (`libsqlite3-dev`, `libpq-dev`, `libmysql-dev`).
* install diesel cli `cargo install diesel_cli`
* fill environmental variables in the `.env` file in the
**Auster** root directory
* If you are using sqlite as your database make sure
that the path where the file will be created is present.

# running project

### update database and generate schema

* `diesel setup`
* `diesel migration run`

### run server

* `cargo run`
