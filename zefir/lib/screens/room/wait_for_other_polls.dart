import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/poll_result_screen.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/utils.dart';
import 'dart:developer' as developer;

class WaitForOtherPollsScreen extends StatelessWidget {
  static const String pleaseWait = 'Proszę czekać na głosy innych graczy';
  static const String appBarText = 'Oczekiwanie na głosy';

  const WaitForOtherPollsScreen();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text(appBarText),
          elevation: 0,
        ),
        body: StreamBuilder(
          stream: Zefir.of(ctx).eurus.roomStreamService.stream,
          builder: (BuildContext context, AsyncSnapshot<Room> snapshot) {
            if (snapshot.hasData &&
                !snapshot.hasError &&
                snapshot.data.state == RoomState.POLL_RESULT) {
              navigateToPollResultScreen(ctx, snapshot.data);
            }
            return _buildBody(context);
          },
        ));
  }

  Widget _buildBody(BuildContext ctx) {
    final spinner = _buildSpinner(ctx);
    final text = _buildText(ctx, pleaseWait);

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

  void navigateToPollResultScreen(BuildContext ctx, Room room) {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      final stateStorage = Zefir.of(ctx).eurus.storage.state;
      developer.log('All polls present, navigating to PollResult',
          name: 'WaitForOtherPolls');

      stateStorage.update(room.deviceToken, RoomState.POLL_RESULT).then((_) =>
          Navigator.of(ctx).pushReplacementNamed('/pollResult',
              arguments: PollResultRouteParams(room)));
    });
  }
}

class WaitForOtherPollsRouteParams {
  final int token;

  const WaitForOtherPollsRouteParams(this.token);
}
