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

# Web API endpoints


| method 	|  endpoint 	|         arguments         	|                              description                             	|
|:------:	|:---------:	|:-------------------------:	|:--------------------------------------------------------------------:	|
|   GET  	|     /dev     	|    --------------------   	| Temporary main page listing all the users                            	|
|   GET  	| /dev/graphiql |    --------------------   	| Web application to send graphql requests to the api                  	|
|   GET  	|  /graphql 	|      graphql request      	| GET graphql endpoint                                                 	|
|  POST  	|  /graphql 	|      graphql request      	| POST graphql endpoint                                                	|
|  POST  	|   /dev/new   	| user_name:: Maybe\<String\> 	| Creates new user with the given name or empty name if none were sent 	|

`/dev` endpoints are only available in the debug builds of the `eurus` (`cargo build`, `cargo run`).
If building for release (`cargo build --release`, `cargo run --release`) no development endpoints will be dispatched
(they won't even be compiled).