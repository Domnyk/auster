import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen_for_question_owner.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/zefir.dart';
import 'dart:developer' as developer;

class WaitForOtherAnswersScreen extends StatefulWidget {
  static const String pleaseWait = 'Proszę czekać na odpowiedzi innych graczy';
  static const String appBarText = 'Oczekiwanie na odpowiedzi';

  final Eurus _eurus;
  final int _token;

  const WaitForOtherAnswersScreen(this._eurus, this._token);

  @override
  _WaitForOtherAnswersScreenState createState() =>
      _WaitForOtherAnswersScreenState();
}

class _WaitForOtherAnswersScreenState extends State<WaitForOtherAnswersScreen> {
  dynamic _observableQuery;
  StreamSubscription _roomSubscription;
  Room _room;

  @override
  void initState() {
    super.initState();

    _observableQuery = widget._eurus.roomStreamService
        .createWatchableQueryFor(token: widget._token);

    _roomSubscription = widget._eurus.roomStreamService
        .createStreamFrom(_observableQuery, token: widget._token)
        .listen((newRoom) {
      setState(() {
        _room = newRoom;
      });
    });
  }

  @override
  void dispose() {
    _roomSubscription.cancel().then((_) => _observableQuery.close(force: true));
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    if (_room != null && _room.state == RoomState.POLLING) {
      navigateToPollingScreen(ctx, _room);
    }

    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text(WaitForOtherAnswersScreen.appBarText),
          elevation: 0,
        ),
        body: _buildBody(ctx));
  }

  Widget _buildBody(BuildContext ctx) {
    final spinner = _buildSpinner(ctx);
    final text = _buildText(ctx, WaitForOtherAnswersScreen.pleaseWait);

    List<Widget> padded = [spinner, text]
        .map((w) => Padding(
              child: w,
              padding: EdgeInsets.all(10),
            ))
        .toList();

    return Column(
      children: padded,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _buildSpinner(BuildContext ctx) {
    return CircularProgressIndicator(
      backgroundColor: Colors.white,
      strokeWidth: 5,
    );
  }

  Widget _buildText(BuildContext ctx, String content) {
    TextTheme currentTheme = Theme.of(ctx).textTheme;

    return Text(
      content,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white, fontSize: currentTheme.headline.fontSize),
    );
  }

  void navigateToPollingScreen(BuildContext ctx, Room roomInNewState) {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      final int token =
          (Utils.routeArgs(ctx) as WaitForOtherAnswersRouteParams).token;

      if (token == roomInNewState.currPlayer.token) {
        developer.log(
            'All players have add answers, navigation to polling screen for question creator',
            name: 'WaitForOtherAnswers');

        final stateStorage = Zefir.of(ctx).eurus.storage.state;
        stateStorage.update(token, RoomState.WAIT_FOR_OTHER_POLLS).then((_) =>
            Navigator.of(ctx).pushReplacementNamed('/pollingForQuestionOwner',
                arguments:
                    PollingScreenForQuestionOwnerRouteParams(roomInNewState)));
      } else {
        developer.log(
            'All players have add answers, navigation to PollingScreen',
            name: 'WaitForOtherAnswers');
        Navigator.of(ctx).pushReplacementNamed('/polling',
            arguments: PollingRouteParams(token, room: roomInNewState));
      }
    });
  }
}

class WaitForOtherAnswersRouteParams {
  final int token;

  WaitForOtherAnswersRouteParams(this.token);
}
