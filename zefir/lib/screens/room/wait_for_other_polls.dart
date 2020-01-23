import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/dead_screen.dart';
import 'package:zefir/screens/room/poll_result_screen.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/zefir.dart';
import 'dart:developer' as developer;

class WaitForOtherPollsScreen extends StatefulWidget {
  static const String pleaseWait = 'Proszę czekać na głosy innych graczy';
  static const String appBarText = 'Oczekiwanie na głosy';

  final Eurus _eurus;
  final Room _room;

  const WaitForOtherPollsScreen(this._eurus, this._room);

  @override
  _WaitForOtherPollsScreenState createState() =>
      _WaitForOtherPollsScreenState();
}

class _WaitForOtherPollsScreenState extends State<WaitForOtherPollsScreen> {
  dynamic _observableQuery;
  StreamSubscription _roomSubscription;
  Room _room;

  @override
  void initState() {
    super.initState();

    _observableQuery = widget._eurus.roomStreamService
        .createWatchableQueryFor(token: widget._room.deviceToken);

    _roomSubscription = widget._eurus.roomStreamService
        .createStreamFrom(_observableQuery, token: widget._room.deviceToken)
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
    if (_room.state == RoomState.POLL_RESULT) {
      _navigateToProperScreen(ctx, _room);
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(WaitForOtherPollsScreen.appBarText),
        elevation: 0,
      ),
      body: _buildBody(ctx),
    );
  }

  Widget _buildBody(BuildContext ctx) {
    final spinner = _buildSpinner(ctx);
    final text = _buildText(ctx, WaitForOtherPollsScreen.pleaseWait);

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

  void _navigateToProperScreen(BuildContext ctx, Room room) {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      final state = room.state;

      if (state == RoomState.POLL_RESULT) {
        developer.log('All polls present, navigating to PollResult',
            name: 'WaitForOtherPolls');

        final stateStorage = Zefir.of(ctx).eurus.storage.state;
        stateStorage.update(room.deviceToken, RoomState.POLL_RESULT).then((_) =>
            Navigator.of(ctx).pushReplacementNamed('/pollResult',
                arguments: PollResultRouteParams(room)));
      } else if (state == RoomState.DEAD) {
        Navigator.of(ctx)
            .pushReplacementNamed('/dead', arguments: DeadRouteParams(room));
      } else {
        throw Exception('Illegal state on WaitForOtherPolls screen');
      }
    });
  }
}

class WaitForOtherPollsRouteParams {
  final Room room;

  const WaitForOtherPollsRouteParams(this.room);
}
