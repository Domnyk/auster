import 'package:flutter/foundation.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/question.dart';
import 'package:zefir/model/room_state.dart';

import 'answer.dart';

class Room {
  RoomState state;
  String name;
  String joinCode;
  int maxRounds;
  int maxPlayers;
  int currRound;
  Player currPlayer;
  List<Answer> currAnswers;
  Question currQuestion;
  List<Player> players;
  int deviceToken;

  Room.fromGraphQL(dynamic data, int deviceToken)
      : state = RoomStateUtils.parse(data['state']),
        name = data['name'],
        joinCode = data['joinCode'],
        maxRounds = data['maxRounds'],
        maxPlayers = data['maxPlayers'],
        currRound = data['currRound'],
        deviceToken = deviceToken {
    if (state == RoomState.JOINING ||
        state == RoomState.COLLECTING ||
        state == RoomState.WAIT_FOR_OTHER_QUESTIONS ||
        state == RoomState.DEAD) {
      currPlayer = null;
      currAnswers = null;
      currQuestion = null;
      players = (data['players'] as List<dynamic>)
          .map((p) => Player.fromGraphQL(p))
          .toList();
    } else {
      currPlayer = Player.fromGraphQL(data['currPlayer']);

      if (data['currAnswers'] != null) {
        currAnswers = (data['currAnswers'] as List<dynamic>)
            .map((a) => Answer.fromGraphQl(a))
            .toList();
      } else {
        currAnswers = [];
      }

      currQuestion = Question.fromGraphQl(data['currQuestion']);
    }
  }

  @override
  String toString() {
    return 'Room[name=$name, state=${state.toString()}, joinCode=$joinCode, maxRounds=$maxRounds, currRound=$currRound' +
        'currPlayer=${currPlayer.toString()}, currAnswers=$currAnswers, currQuestion=$currQuestion, players=$players';
  }
}
