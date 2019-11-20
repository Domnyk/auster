# Auster project

## Prequisitions

Remember to create `.env` file defining enviromental 
variables for the **eurus** and **zefir** to use.

Eurus uses:
```
DATABASE_URL = url/to/your/database
ROCKET_DATABASES = '{dictionary_with_db_definitions}'
```
so for example for the sqlite database:
```
DATABASE_URL = ~/auster/resources/db/eurus.db
ROCKET_DATABASES = '{eurus_db={url="~/auster/resources/db/eurus.db"}}'
```

You could skip `DATABASE_URL` value if you are not
using a `diesel_cli` tool for managing your database
and schema files but you probably should.

## Building

**Zefir** and **Eurus**, for now, build separetly. 
Building instructions for the **Eurus** can be found in
the `README.md` file inside the **Eurus**es root directiory. 

## Test
