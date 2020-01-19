import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/answering_screen.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'dart:developer' as developer;
import 'package:zefir/utils.dart';

class WaitForOtherQuestionsScreen extends StatelessWidget {
  static const String waitText =
      'Proszę czekać aż pozostali gracze dodadzą pytania';
  static const String appBarText = 'Oczekiwanie na pytania';

  const WaitForOtherQuestionsScreen();

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
          builder: (BuildContext context, AsyncSnapshot<RoomState> snapshot) {
            if (snapshot.hasData &&
                !snapshot.hasError &&
                snapshot.data == RoomState.ANSWERING) {
              navigateToAnsweringScreen(ctx);
            }
            return _buildBody(context);
          },
        ));
  }

  Stream<RoomState> _buildStateStream(BuildContext ctx) {
    final token =
        (Utils.routeArgs(ctx) as WaitForOtherQuestionsRouteParams).token;
    final client = Zefir.of(ctx).eurus.client;
    final options = WatchQueryOptions(
      fetchResults: true,
      pollInterval: 5,
      document: Queries.FEETCH_ROOM_STATE,
      fetchPolicy: FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
      variables: {'token': token},
    );

    return client.watchQuery(options).stream.asyncMap((result) async {
      if (result.hasException == false && result.data != null) {
        final stateFromDb =
            await Zefir.of(ctx).eurus.storage.state.fetch(token);
        final stateFromBackend = RoomStateUtils.parse(
            result.data['player']['room']['state'] as String);

        return calculateProperState(stateFromBackend, stateFromDb);
      } else {
        return null;
      }
    });
  }

  Widget _buildBody(BuildContext ctx) {
    final spinner = _buildSpinner(ctx);
    final text = _buildText(ctx, waitText);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [spinner, text]
          .map((w) => Padding(
                child: w,
                padding: EdgeInsets.all(10),
              ))
          .toList(),
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

  RoomState calculateProperState(RoomState fromBackend, RoomState fromDb) {
    if (fromBackend == RoomState.COLLECTING &&
        fromDb == RoomState.WAIT_FOR_OTHER_QUESTIONS) {
      return RoomState.WAIT_FOR_OTHER_QUESTIONS;
    } else if (fromBackend == RoomState.ANSWERING) {
      return RoomState.ANSWERING;
    } else {
      throw Exception(
          'Illegal combination of states. FromDb: $fromDb, from backedn: $fromBackend');
    }
  }

  void navigateToAnsweringScreen(BuildContext ctx) {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      final int token =
          (Utils.routeArgs(ctx) as WaitForOtherQuestionsRouteParams).token;
      developer.log(
          'All players have add questions, navigation to AnsweringScreen',
          name: 'WaitForOtherQuestionsScreen');
      Navigator.of(ctx).pushReplacementNamed('/answering',
          arguments: AnsweringRouteParams(token));
    });
  }
}

class WaitForOtherQuestionsRouteParams {
  final int token;

  const WaitForOtherQuestionsRouteParams(this.token);
}
