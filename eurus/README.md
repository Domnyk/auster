# Installation tips

* `rustup update && cargo update`
* before building remember to install database drivers
which diesel supports (`libsqlite3-dev`, `libpq-dev`, `libmysql-dev`).
* install diesel cli (`cargo install diesel_cli`)
* fill environmental variables in the `.env` file in the
**Auster** root directory
* If you are using sqlite as your database make sure
that the path were the file will be created is created.

# running project

### update database and generate schema

* `diesel setup`
* `diesel migration run`

### run server

* `cargo run`
