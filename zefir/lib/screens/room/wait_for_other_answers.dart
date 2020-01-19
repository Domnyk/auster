import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen_for_question_owner.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/utils.dart';
import 'dart:developer' as developer;

class WaitForOtherAnswersScreen extends StatelessWidget {
  static const String pleaseWait = 'Proszę czekać na odpowiedzi innych graczy';
  static const String appBarText = 'Oczekiwanie na odpowiedzi';

  const WaitForOtherAnswersScreen();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text(appBarText),
          elevation: 0,
        ),
        body: StreamBuilder(
          stream: _buildStateStream(ctx),
          builder: (BuildContext context, AsyncSnapshot<Room> snapshot) {
            final room = snapshot.data;

            if (snapshot.hasData &&
                !snapshot.hasError &&
                room.state == RoomState.POLLING) {
              navigateToPollingScreen(ctx, room.currPlayer.token);
            }
            return _buildBody(context);
          },
        ));
  }

  Stream<Room> _buildStateStream(BuildContext ctx) {
    final token =
        (Utils.routeArgs(ctx) as WaitForOtherAnswersRouteParams).token;
    final client = Zefir.of(ctx).eurus.client;
    final options = WatchQueryOptions(
      fetchResults: true,
      pollInterval: 5,
      document: Queries.FETCH_ROOM,
      fetchPolicy: FetchPolicy.networkOnly,
      errorPolicy: ErrorPolicy.all,
      variables: {'token': token},
    );

    return client.watchQuery(options).stream.asyncMap((result) async {
      if (result.loading) {
        return null;
      }

      if (result.hasException == false && result.data != null) {
        final stateFromDb =
            await Zefir.of(ctx).eurus.storage.state.fetch(token);
        final Room room =
            Room.fromGraphQL(result.data['player']['room'], token);
        room.state = RoomStateUtils.merge(stateFromDb, room.state);

        developer.log(
            'State from DB for token $token is: ${stateFromDb.toString()}',
            name: 'WaitForOtherAnswersScreen');

        return room;
      } else {
        return null;
      }
    });
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

  void navigateToPollingScreen(BuildContext ctx, int currPlayerToken) {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      final int token =
          (Utils.routeArgs(ctx) as WaitForOtherAnswersRouteParams).token;

      if (token == currPlayerToken) {
        developer.log(
            'All players have add answers, navigation to polling screen for question creator',
            name: 'WaitForOtherAnswers');
        Navigator.of(ctx).pushReplacementNamed('/pollingForQuestionOwner',
            arguments: PollingScreenForQuestionOwnerRouteParams(token));
      } else {
        developer.log(
            'All players have add answers, navigation to PollingScreen',
            name: 'WaitForOtherAnswers');
        Navigator.of(ctx).pushReplacementNamed('/polling',
            arguments: PollingRouteParams(token));
      }
    });
  }
}

class WaitForOtherAnswersRouteParams {
  final int token;

  WaitForOtherAnswersRouteParams(this.token);
}
