import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/model/answer.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/question.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/dead_screen.dart';
import 'package:zefir/screens/room/poll_result_screen.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'dart:developer' as developer;

// TODO: Change name to something shorter
class PollingScreenForQuestionOwner extends StatefulWidget {
  static const String _nextScreenText = 'Przejdź do listy wyników';

  final Eurus _eurus;
  final Room _room;

  const PollingScreenForQuestionOwner(this._eurus, this._room);

  @override
  _PollingScreenForQuestionOwnerState createState() =>
      _PollingScreenForQuestionOwnerState();
}

class _PollingScreenForQuestionOwnerState
    extends State<PollingScreenForQuestionOwner> {
  dynamic _observableQuery;
  StreamSubscription _roomSubscription;
  Room _room;
  Room _roomForNextScreen;
  _NextScreen _nextScreen;

  _PollingScreenForQuestionOwnerState();

  @override
  void initState() {
    super.initState();

    _room = widget._room;

    _observableQuery = widget._eurus.roomStreamService
        .createWatchableQueryFor(token: widget._room.deviceToken);

    _roomSubscription = widget._eurus.roomStreamService
        .createStreamFrom(_observableQuery, token: widget._room.deviceToken)
        .listen((newRoom) {
      _showNavigationControlsIfNecessary(newRoom);
      _updateRoomIfNecessary(newRoom);
    });
  }

  @override
  void dispose() {
    _roomSubscription.cancel().then((_) => _observableQuery.close(force: true));
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Głosowanie'),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuestion(context, _room.currQuestion),
          Divider(),
          _buildCurrentAnswers(ctx, _room.currAnswers),
          if (_nextScreen != null) _buildNextScreenButton(ctx),
        ].map((w) => Padding(child: w, padding: EdgeInsets.all(10))).toList(),
      )),
    );
  }

  Widget _buildQuestion(BuildContext ctx, Question q) {
    return Row(
      children: [
        Expanded(
          child: Text('Twoje pytanie:'),
        ),
        Expanded(child: Text(q.content)),
      ],
    );
  }

  Widget _buildCurrentAnswers(BuildContext ctx, List<Answer> allAnswers) {
    return Row(
      children: [
        Expanded(
          child: Text('Odpowiedzi jakie zostały dodane:'),
        ),
        Expanded(child: _buildCurrentAnswersList(allAnswers)),
      ],
    );
  }

  Widget _buildCurrentAnswersList(List<Answer> answers) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: answers.length,
      itemBuilder: (BuildContext ctx, int index) {
        return Text(answers[index].content);
      },
    );
  }

  Widget _buildNextScreenButton(BuildContext ctx) {
    if (_nextScreen == null) throw Exception('_nextScreen is null');

    final void Function() onPressed = _nextScreen == _NextScreen.POLL_RESULT
        ? () => Navigator.of(ctx).pushReplacementNamed('/pollResult',
            arguments: PollResultRouteParams(_roomForNextScreen))
        : () => Navigator.of(ctx).pushReplacementNamed('/dead',
            arguments: DeadRouteParams(_roomForNextScreen));

    return RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: Text(PollingScreenForQuestionOwner._nextScreenText),
      onPressed: onPressed,
    );
  }

  void _showNavigationControlsIfNecessary(Room newRoom) {
    if (_room == null) return;

    if (newRoom.state == RoomState.DEAD) {
      setState(() {
        _nextScreen = _NextScreen.DEAD;
        _roomForNextScreen = newRoom;
      });
    } else if (newRoom.state == RoomState.ANSWERING &&
        newRoom.deviceToken != newRoom.currPlayer.token) {
      setState(() {
        _nextScreen = _NextScreen.POLL_RESULT;
        _roomForNextScreen = newRoom;
      });
    }
  }

  void _updateRoomIfNecessary(Room newRoom) {
    if (Room.isDead(newRoom) || Room.isNextRoundStarted(newRoom)) return;

    setState(() {
      _room = newRoom;
    });
  }
}

// TODO: Change name to something shorter
// TODO: Nearly all route params classes have same one field - token
class PollingScreenForQuestionOwnerRouteParams {
  final Room room;

  PollingScreenForQuestionOwnerRouteParams(this.room);
}

enum _NextScreen { DEAD, POLL_RESULT }
