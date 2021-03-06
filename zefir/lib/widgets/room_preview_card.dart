import 'package:flutter/material.dart';
import 'package:zefir/model/player_poll_result.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/add_question_screen.dart';
import 'package:zefir/screens/room/answering_screen.dart';
import 'package:zefir/screens/room/dead_screen.dart';
import 'package:zefir/screens/room/poll_result_screen.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen_for_question_owner.dart';
import 'package:zefir/screens/room/wait_for_other_answers.dart';
import 'package:zefir/screens/room/wait_for_other_polls.dart';
import 'package:zefir/screens/room/wait_for_other_questions_screen.dart';
import 'package:zefir/screens/room/wait_for_players_screen.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/storage/token.dart';
import 'package:zefir/zefir.dart';

class RoomPreviewCard extends StatelessWidget {
  final Eurus _eurus;
  final Room _room;

  RoomPreviewCard({@required Room room, @required Eurus eurus})
      : _room = room,
        _eurus = eurus;

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
      padding: EdgeInsets.fromLTRB(10, 12.5, 10, 12.5),
      child: row,
    );

    return InkWell(
      child: paddedRow,
      onTap: () => navigateToRoom(ctx),
    );
  }

  Future navigateToRoom(BuildContext ctx) {
    String url;
    Object arguments;

    switch (_room.state) {
      case RoomState.JOINING:
        url = '/waitForPlayers';
        arguments = WaitForPlayersRouteParams(_room, _eurus);
        break;
      case RoomState.COLLECTING:
        url = '/addQuestion';
        arguments = AddQuestionRouteParams(_room.deviceToken, _room.maxRounds);
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
        if (_room.deviceToken == _room.currPlayer.token) {
          url = '/pollingForQuestionOwner';
          arguments = PollingScreenForQuestionOwnerRouteParams(_room);
        } else {
          url = '/polling';
          arguments = PollingRouteParams(_room.deviceToken, room: _room);
        }
        break;
      case RoomState.WAIT_FOR_OTHER_POLLS:
        if (_room.deviceToken == _room.currPlayer.token) {
          url = '/pollingForQuestionOwner';
          arguments = PollingScreenForQuestionOwnerRouteParams(_room);
        } else {
          url = '/waitForOtherPolls';
          arguments = WaitForOtherPollsRouteParams(_room);
        }
        break;
      case RoomState.POLL_RESULT:
        url = '/pollResult';
        return Zefir.of(ctx)
            .eurus
            .storage
            .state
            .fetchPlayerPollResult(_room.deviceToken)
            .then((PlayerPollResult p) => Navigator.pushNamed(ctx, url,
                arguments: PollResultRouteParams(_room, p)));
      case RoomState.DEAD:
        url = '/dead';
        arguments = DeadRouteParams(_room);
        break;
      default:
    }

    return Navigator.pushNamed(ctx, url, arguments: arguments);
  }

  Widget _buildMoreAcctionsColumn(BuildContext ctx) {
    return Column(
      children: [
        FlatButton(
          child: Icon(Icons.more_vert),
          onPressed: () => showDialog(
              context: ctx,
              builder: (context) => _buildMoreActionsDialog(context)),
        )
      ],
    );
  }

  Widget _buildActionsInJoingingState(BuildContext ctx) {
    final TokenStorage tokenStorage = Zefir.of(ctx).eurus.storage.token;

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
