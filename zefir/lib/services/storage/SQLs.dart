class SQL {
  static const String CREATE_ROOMS_TABLE = """
    CREATE TABLE rooms(token INTEGER PRIMARY KEY, state VARCHAR(50));
    """;
}
