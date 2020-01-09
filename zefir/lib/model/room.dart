import 'package:zefir/model/player.dart';
import 'package:zefir/model/room_state.dart';

class Room {
  RoomState state;
  String name;
  String joinCode;
  int maxRounds;
  int maxPlayers;
  int currRound;
  Player currPlayer;
  dynamic currAnswers;
  dynamic currQuestion;
  List<Player> players;
  int deviceToken;

  Room.fromGraphQL(dynamic data, int deviceToken)
      : state = RoomStateParser.parse(data['state']),
        name = data['name'],
        joinCode = data['joinCode'],
        maxRounds = data['maxRounds'],
        maxPlayers = data['maxPlayers'],
        currRound = data['currRound'],
        deviceToken = deviceToken {
    if (state == RoomState.JOINING ||
        state == RoomState.COLLECTING ||
        state == RoomState.DEAD) {
      currPlayer = null;
      currAnswers = null;
      currQuestion = null;
      players = (data['players'] as List<dynamic>)
          .map((p) => Player.fromGraphQL(p))
          .toList();
    } else {
      currPlayer = Player.fromGraphQL(data['currPlayer']);
      currAnswers = data['currAnswers'];
      currQuestion = data['currQuestion'];
    }
  }

  @override
  String toString() {
    return 'Room[name=$name, state=${state.toString()}, joinCode=$joinCode, maxRounds=$maxRounds, currRound=$currRound' +
        'currPlayer=${currPlayer.toString()}, currAnswers=$currAnswers, currQuestion=$currQuestion, players=$players';
  }
}
