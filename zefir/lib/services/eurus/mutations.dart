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

  static const String FETCH_ROOM = """
  query fetchRoom(\$token: Int!) {
    player(token: \$token) {
      room {
        name
      }
    }
  }
  """;

  static const String FETCH_ROOM_PREVIEW = """
  query fetchRoom(\$token: Int!) {
    player(token: \$token) {
      room {
        name,
        state
      }
    }
  }
  """;
}
