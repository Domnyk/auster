import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/answering_screen.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/utils.dart';
import 'dart:developer' as developer;

class WaitForOtherQuestionsScreen extends StatefulWidget {
  static const String waitText =
      'Proszę czekać aż pozostali gracze dodadzą pytania';
  static const String appBarText = 'Oczekiwanie na pytania';

  final Eurus _eurus;
  final int _token;

  const WaitForOtherQuestionsScreen(this._eurus, this._token);

  @override
  _WaitForOtherQuestionsScreenState createState() =>
      _WaitForOtherQuestionsScreenState();
}

class _WaitForOtherQuestionsScreenState
    extends State<WaitForOtherQuestionsScreen> {
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
    if (_room != null && _room.state == RoomState.ANSWERING) {
      _navigateToAnsweringScreen(ctx);
    }

    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text(WaitForOtherQuestionsScreen.appBarText),
          elevation: 0,
        ),
        body: _buildBody(ctx));
  }

  Widget _buildBody(BuildContext ctx) {
    final spinner = _buildSpinner(ctx);
    final text = _buildText(ctx, WaitForOtherQuestionsScreen.waitText);

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

  // RoomState _calculateProperState(RoomState fromBackend, RoomState fromDb) {
  //   if (fromBackend == RoomState.COLLECTING &&
  //       fromDb == RoomState.WAIT_FOR_OTHER_QUESTIONS) {
  //     return RoomState.WAIT_FOR_OTHER_QUESTIONS;
  //   } else if (fromBackend == RoomState.ANSWERING) {
  //     return RoomState.ANSWERING;
  //   } else {
  //     throw Exception(
  //         'Illegal combination of states. FromDb: $fromDb, from backedn: $fromBackend');
  //   }
  // }

  void _navigateToAnsweringScreen(BuildContext ctx) {
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
