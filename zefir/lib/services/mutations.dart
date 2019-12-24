class Mutations {
  static const String JOIN_ROOM = """
  mutation joinRoomM(\$roomCode: String!, \$playerName: String!) {
    joinRoom(roomCode:\$roomCode, playerName:\$playerName) {
      name,
      token
    }
  }
  """;
}
