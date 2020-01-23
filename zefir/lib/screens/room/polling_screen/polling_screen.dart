import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/answer.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/dead_screen.dart';
import 'package:zefir/screens/room/poll_result_screen.dart';
import 'package:zefir/screens/room/wait_for_other_polls.dart';
import 'package:zefir/services/eurus/mutations.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/zefir.dart';
import 'dart:developer' as developer;

class PollingScreen extends StatefulWidget {
  @override
  _PollingScreenState createState() => _PollingScreenState(null);
}

class _PollingScreenState extends State<PollingScreen> {
  static const appBartTitle = 'Zagłosuj na odpowiedź';
  static const confirmBtnText = 'Prześlij odpowiedź';

  Answer _choosedAnswer;
  bool _isSending;

  _PollingScreenState(this._choosedAnswer);

  @override
  void initState() {
    super.initState();

    _isSending = false;
  }

  @override
  Widget build(BuildContext ctx) {
    final Room room = (Utils.routeArgs(ctx) as PollingRouteParams).room;
    return Scaffold(
      floatingActionButton: _buildFAB(ctx),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _builder(ctx, room),
      appBar: AppBar(title: Text(appBartTitle)),
    );
  }

  Widget _buildFAB(BuildContext ctx) {
    final EdgeInsets padding = MediaQuery.of(ctx).padding.bottom != 0
        ? EdgeInsets.only(bottom: MediaQuery.of(ctx).padding.bottom)
        : EdgeInsets.only(bottom: 10);
    const double elevation = 4.0;

    Widget fab = FloatingActionButton.extended(
      backgroundColor: Colors.green,
      elevation: elevation,
      label: const Text('Prześlij odpowiedź'),
      onPressed: () {
        setState(() {
          _isSending = true;
        });

        sendQuestion(ctx).then((token) {
          setState(() {
            _isSending = false;
          });

          return token;
        }).then((room) => _navigateToProperScreen(ctx, room));
      },
    );

    Widget inactiveFab = FloatingActionButton.extended(
      elevation: elevation,
      label: const Text('Trwa przesyłanie odpowiedzi...'),
      backgroundColor: Colors.grey,
      onPressed: null,
    );

    return Padding(padding: padding, child: _isSending ? inactiveFab : fab);
  }

  Widget _builder(BuildContext ctx, Room room) {
    final List<Widget> childen = [
      _buildCurrentPlayer(ctx, room.currPlayer.name),
      _buildQuestion(ctx, room.currPlayer.name, room.currQuestion.content),
      _buildAnswers(ctx, room.currAnswers),
    ]
        .map((w) => Padding(
              child: w,
              padding: EdgeInsets.all(10),
            ))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: childen,
    );
  }

  Widget _buildCurrentPlayer(BuildContext ctx, String currentPlayerName) {
    return Text(
      'Odpowiedz tak jak $currentPlayerName',
      style: TextStyle(fontSize: Theme.of(ctx).textTheme.headline.fontSize),
    );
  }

  Widget _buildQuestion(BuildContext ctx, String playerName, String question) {
    final q =
        question[0].toLowerCase() + question.substring(1, question.length - 1);

    return Text(
      q,
      style: TextStyle(fontSize: Theme.of(ctx).textTheme.headline.fontSize),
    );
  }

  Widget _buildAnswers(BuildContext ctx, List<Answer> answers) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: answers.length,
        itemBuilder: (BuildContext ctx, int index) {
          return RadioListTile(
            value: answers[index].id,
            groupValue: _choosedAnswer == null ? null : _choosedAnswer.id,
            title: Text(answers[index].content),
            onChanged: (int value) {
              setState(() {
                _choosedAnswer = answers[index];
              });
            },
          );
        });
  }

  Future<Room> sendQuestion(BuildContext ctx) async {
    final stateStorage = Zefir.of(ctx).eurus.storage.state;
    final token = (Utils.routeArgs(ctx) as PollingRouteParams).token;
    final GraphQLClient client = Zefir.of(ctx).eurus.client;
    final QueryResult result = await client.mutate(MutationOptions(
        document: Mutations.POLL_ANSWER,
        fetchPolicy: FetchPolicy.noCache,
        errorPolicy: ErrorPolicy.all,
        variables: {'token': token, 'answerId': _choosedAnswer.id}));

    if (result.hasException)
      throw Exception('Exception occured in senQuestion');

    if (result.data == null) throw Exception('Data is null');

    Room room =
        Room.fromGraphQL(result.data['pollAnswer']['player']['room'], token);

    return stateStorage
        .update(token, RoomState.WAIT_FOR_OTHER_POLLS)
        .then((_) => room);
  }

  void _navigateToProperScreen(BuildContext ctx, Room roomAfterMutation) {
    final state = roomAfterMutation.state;
    final stateStorage = Zefir.of(ctx).eurus.storage.state;

    if (state == RoomState.DEAD) {
      Navigator.of(ctx).pushReplacementNamed('/dead',
          arguments: DeadRouteParams(roomAfterMutation));
    } else if (state == RoomState.POLLING) {
      stateStorage
          .update(roomAfterMutation.deviceToken, RoomState.WAIT_FOR_OTHER_POLLS)
          .then((_) => Navigator.of(ctx).pushReplacementNamed(
              '/waitForOtherPolls',
              arguments: WaitForOtherPollsRouteParams(roomAfterMutation)));
    } else if (state == RoomState.ANSWERING) {
      Navigator.of(ctx).pushReplacementNamed('/pollResult',
          arguments: PollResultRouteParams(roomAfterMutation));
    }
  }
}

class PollingRouteParams {
  final int token;
  final Room room;

  PollingRouteParams(this.token, {Room room}) : room = room;
}
