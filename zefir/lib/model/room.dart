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
  List<Question> allQuestions;
  int deviceToken;

  static List<Answer> parseCurrAnswers(List<dynamic> data) {
    return data.map((a) => Answer.fromGraphQl(a)).toList();
  }

  static List<Player> parsePlayers(List<dynamic> data) {
    return data.map((a) => Player.fromGraphQl(a)).toList();
  }

  static bool isDead(Room room) {
    return room.state == RoomState.DEAD;
  }

  // TODO: Not tested. Use only in PollingScreenForQuestionOwner
  static bool isNextRoundStarted(Room room) {
    return room.state == RoomState.ANSWERING &&
        room.deviceToken != room.currPlayer.token;
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
    this.allQuestions,
    this.deviceToken,
  );

  Room.fromGraphQL(dynamic data, int deviceToken)
      : state = RoomStateUtils.parse(data['state']),
        name = data['name'],
        joinCode = data['joinCode'],
        maxRounds = data['maxRounds'],
        maxPlayers = data['maxPlayers'],
        currRound = data['currRound'],
        deviceToken = deviceToken,
        players = Room.parsePlayers(data['players']) {
    if (state == RoomState.JOINING ||
        state == RoomState.COLLECTING ||
        state == RoomState.WAIT_FOR_OTHER_QUESTIONS) {
      currPlayer = null;
      currAnswers = null;
      currQuestion = null;
      allQuestions = null;
    } else if (state == RoomState.ANSWERING ||
        state == RoomState.WAIT_FOR_OTHER_ANSWERS) {
      currPlayer = Player.fromGraphQl(data['currPlayer']);
      currQuestion = Question.fromGraphQl(data['currQuestion']);
      allQuestions = null;
    } else if (state == RoomState.POLLING ||
        state == RoomState.WAIT_FOR_OTHER_POLLS ||
        state == RoomState.POLL_RESULT) {
      currPlayer = Player.fromGraphQl(data['currPlayer']);
      currQuestion = Question.fromGraphQl(data['currQuestion']);
      currAnswers = Room.parseCurrAnswers(data['currAnswers']);
      allQuestions = null;
    } else if (state == RoomState.DEAD) {
      // TODO: Uncomment after recompilation of eurus
      // final questions = data['allQuestions'] as List<dynamic>;
      // allQuestions = questions.map((q) => Question.fromGraphQl(q));
      allQuestions = [Question('To jest pytanie testowe!1!one', false)];
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
