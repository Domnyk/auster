enum RoomState {
  /// 1st state - players can join to room
  JOINING,

  /// 2nd state - players can add question(s)
  COLLECTING,

  /// 3rd state, only in frontend - player has added his question but is still waiting for other players
  WAIT_FOR_OTHER_QUESTIONS,

  /// 4th state - players answer question
  ANSWERING,

  /// 5th state, only in frontend - player has added his answer and is waiting for other players' answers
  WAIT_FOR_OTHER_ANSWERS,

  /// 6th state - players try to guess how certain player answered
  POLLING,

  /// 7th state, only in frontend - player is waitng for other to vote
  WAIT_FOR_OTHER_POLLS,

  /// 8th state, only in frontend - player is seeing vote's results
  POLL_RESULT,

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
    } else if (this == RoomState.WAIT_FOR_OTHER_QUESTIONS) {
      return 'WaitForOtherQuestions';
    } else if (this == RoomState.WAIT_FOR_OTHER_ANSWERS) {
      return 'WaitForOtherAnswers';
    } else if (this == RoomState.WAIT_FOR_OTHER_POLLS) {
      return 'WaitForOtherPolls';
    } else if (this == RoomState.POLL_RESULT) {
      return 'PollResult';
    } else {
      throw Exception(
          'State ${this.toString()} is not covered by toMyString(). Fix the function');
    }
  }
}

class RoomStateUtils {
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
    } else if (roomState == 'WaitForOtherAnswers') {
      return RoomState.WAIT_FOR_OTHER_ANSWERS;
    } else if (roomState == 'WaitForOtherPolls') {
      return RoomState.WAIT_FOR_OTHER_POLLS;
    } else if (roomState == 'PollResult') {
      return RoomState.POLL_RESULT;
    } else {
      throw ArgumentError('Can\'t parse unkown room state: $roomState');
    }
  }

  /// Return true if according to game logic a should be before b
  static RoomState merge(RoomState fromDb, RoomState fromBackend) {
    if (fromBackend == RoomState.COLLECTING &&
        fromDb == RoomState.WAIT_FOR_OTHER_QUESTIONS) {
      return RoomState.WAIT_FOR_OTHER_QUESTIONS;
    } else if (fromBackend == RoomState.ANSWERING &&
        fromDb == RoomState.WAIT_FOR_OTHER_ANSWERS) {
      return RoomState.WAIT_FOR_OTHER_ANSWERS;
    } else if (fromBackend == RoomState.POLLING &&
        fromDb == RoomState.WAIT_FOR_OTHER_POLLS) {
      return RoomState.WAIT_FOR_OTHER_POLLS;
    } else if (fromBackend == RoomState.ANSWERING &&
        fromDb == RoomState.WAIT_FOR_OTHER_POLLS) {
      return RoomState.POLL_RESULT;
    } else {
      return fromBackend;
    }
  }
}
