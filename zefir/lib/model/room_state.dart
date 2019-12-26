enum RoomState {
  /// Players can join to room
  JOINING,

  /// Players can add question(s)
  COLLECTING,

  /// Players answer question
  ANSWERING,

  /// Players try to guess how certain player answered
  POLLING,

  /// Game has ended
  DEAD
}

class RoomStateParser {
  static RoomState parse(final String roomState) {
    if (roomState == 'Joining') {
      return RoomState.JOINING;
    } else if (roomState == 'Collecting') {
      return RoomState.COLLECTING;
    } else if (roomState == 'Answering') {
      return RoomState.ANSWERING;
    } else if (roomState == 'Polling') {
      return RoomState.POLLING;
    } else if (roomState == 'Dead') {
      return RoomState.DEAD;
    } else {
      throw ArgumentError('Can\'t parse unkown room state: $roomState');
    }
  }
}
