enum RoomState {
  /// Players can join to room
  JOINING,

  /// Players can add question(s)
  COLLECTING,

  /// Player has added his question but is still waiting for other players
  WAIT_FOR_OTHER_QUESTIONS,

  /// Players answer question
  ANSWERING,

  /// Players try to guess how certain player answered
  POLLING,

  /// Game has ended
  DEAD
}

extension Stringer on RoomState {
  // TODO: I should override toString method of RoomState. Yet, for some reason dart throws syntax errors
  String toMyString() {
    if (this == RoomState.JOINING) {
      return 'Joining';
    } else if (this == RoomState.COLLECTING) {
      return 'Collecting';
    } else if (this == RoomState.ANSWERING) {
      return 'Answering';
    } else if (this == RoomState.POLLING) {
      return 'Polling';
    } else if (this == RoomState.DEAD) {
      return 'Dead';
    } else
      return 'WaitForOtherQuestions';
  }
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
    } else if (roomState == 'WaitForOtherQuestions') {
      return RoomState.WAIT_FOR_OTHER_QUESTIONS;
    } else {
      throw ArgumentError('Can\'t parse unkown room state: $roomState');
    }
  }
}
