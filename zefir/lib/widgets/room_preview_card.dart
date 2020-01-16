import 'package:flutter/material.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/add_question.dart';
import 'package:zefir/screens/room/answering_screen.dart';
import 'package:zefir/screens/room/dead.dart';
import 'package:zefir/screens/room/poll_result.dart';
import 'package:zefir/screens/room/polling/polling_screen.dart';
import 'package:zefir/screens/room/wait_for_other_answers.dart';
import 'package:zefir/screens/room/wait_for_other_polls.dart';
import 'package:zefir/screens/room/wait_for_other_questions/wait_for_other_questions_screen.dart';
import 'package:zefir/screens/room/wait_for_players.dart';
import 'package:zefir/services/storage/token.dart';

class RoomPreviewCard extends StatelessWidget {
  final Room _room;

  RoomPreviewCard({Key key, @required Room room})
      : _room = room,
        super(key: key);

  @override
  Widget build(BuildContext ctx) {
    Row row = Row(
      children: <Widget>[
        Expanded(child: _buildShortRoomDescription(ctx), flex: 8),
        Expanded(child: _buildMoreAcctionsColumn(ctx), flex: 2),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );

    Padding paddedRow = Padding(
      padding: EdgeInsets.all(10),
      child: row,
    );

    return Card(
      child: InkWell(
        child: paddedRow,
        onTap: () => navigateToRoom(ctx),
      ),
      margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
    );
  }

  Future navigateToRoom(BuildContext ctx) {
    String url;
    Object arguments;

    switch (_room.state) {
      case RoomState.JOINING:
        url = '/waitForPlayers';
        arguments = WaitForPlayersRouteParams(_room);
        break;
      case RoomState.COLLECTING:
        url = '/addQuestion';
        arguments = AddQuestionRouteParams(_room.deviceToken);
        break;
      case RoomState.WAIT_FOR_OTHER_QUESTIONS:
        url = '/waitForOtherQuestions';
        arguments = WaitForOtherQuestionsRouteParams(_room.deviceToken);
        break;
      case RoomState.ANSWERING:
        url = '/answering';
        arguments = AnsweringRouteParams(_room.deviceToken);
        break;
      case RoomState.WAIT_FOR_OTHER_ANSWERS:
        url = '/waitForOtherAnswers';
        arguments = WaitForOtherAnswersRouteParams(_room.deviceToken);
        break;
      case RoomState.POLLING:
        url = '/polling';
        arguments = PollingRouteParams(_room.deviceToken);
        break;
      case RoomState.WAIT_FOR_OTHER_POLLS:
        url = '/waitForOtherPolls';
        arguments = WaitForOtherPollsRouteParams(_room.deviceToken);
        break;
      case RoomState.POLL_RESULT:
        url = '/pollResult';
        arguments = PollResultRouteParams(_room);
        break;
      case RoomState.DEAD:
        url = '/dead';
        arguments = DeadRouteParams(_room);
        break;
      default:
    }

    return Navigator.pushNamed(ctx, url, arguments: arguments);
  }

  Widget _buildMoreAcctionsColumn(BuildContext ctx) {
    FlatButton btn = FlatButton(
      child: Icon(Icons.more_vert),
      onPressed: () => showDialog(
          context: ctx, builder: (context) => _buildMoreActionsDialog(context)),
    );

    return Column(
        children: _room.state == RoomState.JOINING
            ? [_buildActionsInJoingingState(ctx)]
            : [btn]);
  }

  Widget _buildActionsInJoingingState(BuildContext ctx) {
    final TokenStorage tokenStorage = Zefir.of(ctx).storage.token;

    Widget confirm = FlatButton(
      child: Text('Tak'),
      onPressed: () => tokenStorage
          .delete(_room.deviceToken)
          .then((_) => Navigator.pop(ctx)),
    );

    return FlatButton(
      child: Icon(Icons.clear),
      onPressed: () => showDialog(
          context: ctx,
          builder: (context) => AlertDialog(
                title: Text('Opuść pokój'),
                content: Text('Czy jesteś pewien, że chcesz opuścić pokój?'),
                actions: [confirm],
              )),
    );
  }

  Widget _buildMoreActionsDialog(BuildContext ctx) {
    Widget closeButton = FlatButton(
      child: Text('Zamknij'),
      onPressed: () => Navigator.pop(ctx),
    );

    return AlertDialog(
      title: Text('Dostępne akcje'),
      content: Text('Opuść pokój'),
      actions: <Widget>[closeButton],
    );
  }

  Widget _buildShortRoomDescription(BuildContext ctx) {
    return Column(
      children: [
        _buildRoomTitle(ctx, _room.name),
        _buildGameState(ctx, _room.state)
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _buildRoomTitle(BuildContext ctx, String roomTitle) {
    return Text(
      roomTitle,
      style: TextStyle(fontSize: Theme.of(ctx).textTheme.headline.fontSize),
    );
  }

  Widget _buildGameState(BuildContext ctx, RoomState state) {
    Text text = Text(
      'Stan gry: ${_describeRoomState(state)}',
      style: TextStyle(fontSize: Theme.of(ctx).textTheme.body1.fontSize),
    );

    return Padding(
      padding: EdgeInsets.only(left: 5),
      child: text,
    );
  }

  String _describeRoomState(final RoomState state) {
    switch (state) {
      case RoomState.JOINING:
        return 'oczekiwanie na graczy';
      case RoomState.COLLECTING:
        return 'dodawanie pytań';
      case RoomState.WAIT_FOR_OTHER_QUESTIONS:
        return 'oczekiwanie na pytania innych graczy';
      case RoomState.ANSWERING:
        return 'dodawanie odpowiedzi na pytanie';
      case RoomState.WAIT_FOR_OTHER_ANSWERS:
        return 'oczekiwanie na odpowiedzi innych graczy';
      case RoomState.POLLING:
        return 'głosowanie';
      case RoomState.WAIT_FOR_OTHER_POLLS:
        return 'oczekiwanie na głosy innych graczy';
      case RoomState.POLL_RESULT:
        return 'wyniki rundy';
      case RoomState.DEAD:
        return 'koniec gry';
      default:
        throw ArgumentError('Unknown state ${state.toString()}');
    }
  }
}
