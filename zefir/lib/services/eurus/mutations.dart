class Mutations {
  static const String CREATE_NEW_ROOM = """
    mutation newRoom(\$name: String!, \$rounds: Int!, \$players: Int!) {
      newRoom(name: \$name, players: \$players, rounds: \$rounds) {
        joinCode,
      }
    }
  """;

  static const String JOIN_ROOM = """
  mutation joinRoomM(\$roomCode: String!, \$playerName: String!) {
    joinRoom(roomCode:\$roomCode, playerName:\$playerName) {
      name,
      token
    }
  }
  """;
}
