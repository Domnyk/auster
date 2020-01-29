class SQL {
  static const String CREATE_ROOMS_TABLE = """
    CREATE TABLE rooms(token INTEGER PRIMARY KEY, state VARCHAR(50), pastpoints INTEGER, question VARCHAR(100), correctanswer VARCHAR(100), choosedanswer VARCHAR(100), wasowner VARCHAR(5));
    """;

  static const String CREATE_QUESTIONS_TABLE = """
    CREATE TABLE questions(id INTEGER PRIMARY KEY, question VARCHAR(100))
  """;
}
