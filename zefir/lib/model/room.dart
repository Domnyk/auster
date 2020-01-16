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

  static List<Answer> parseCurrAnswers(List<dynamic> data) {
    return data.map((a) => Answer.fromGraphQl(a)).toList();
  }

  static List<Player> parsePlayers(List<dynamic> data) {
    return data.map((a) => Player.fromGraphQl(a)).toList();
  }

  Room(
    this.state,
    this.name,
    this.joinCode,
    this.maxRounds,
    this.maxPlayers,
    this.currRound,
    this.currPlayer,
    this.currAnswers,
    this.currQuestion,
    this.players,
    this.deviceToken,
  );

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
        state == RoomState.WAIT_FOR_OTHER_QUESTIONS) {
      currPlayer = null;
      currAnswers = null;
      currQuestion = null;
      players = null;
    } else if (state == RoomState.ANSWERING ||
        state == RoomState.WAIT_FOR_OTHER_ANSWERS) {
      currPlayer = Player.fromGraphQl(data['currPlayer']);
      currQuestion = Question.fromGraphQl(data['currQuestion']);
      players = Room.parsePlayers(data['players']);
    } else if (state == RoomState.POLLING ||
        state == RoomState.WAIT_FOR_OTHER_POLLS ||
        state == RoomState.POLL_RESULT) {
      currPlayer = Player.fromGraphQl(data['currPlayer']);
      currQuestion = Question.fromGraphQl(data['currQuestion']);
      currAnswers = Room.parseCurrAnswers(data['currAnswers']);
      players = Room.parsePlayers(data['players']);
    } else if (state == RoomState.DEAD) {
      players = Room.parsePlayers(data['players']);
    } else {
      throw Exception('Unkown state when parsing room info $state');
    }
  }

  @override
  String toString() {
    return 'Room[name=$name, state=${state.toString()}, joinCode=$joinCode, maxRounds=$maxRounds, currRound=$currRound' +
        'currPlayer=${currPlayer.toString()}, currAnswers=$currAnswers, currQuestion=$currQuestion, players=$players';
  }
}
