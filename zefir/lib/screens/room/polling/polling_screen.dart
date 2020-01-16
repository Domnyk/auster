import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/answer.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/wait_for_other_polls.dart';
import 'package:zefir/services/eurus/mutations.dart';
import 'package:zefir/utils.dart';
import 'dart:developer' as developer;

class PollignScreen extends StatefulWidget {
  const PollignScreen();

  @override
  _PollignScreenState createState() => _PollignScreenState(null);
}

class _PollignScreenState extends State<PollignScreen> {
  static const appBartTitle = 'Zagłosuj na odpowiedź';

  Answer _choosedAnswer;

  _PollignScreenState(this._choosedAnswer);

  @override
  Widget build(BuildContext ctx) {
    final Room room = (Utils.routeArgs(ctx) as PollingRouteParams).room;

    return Scaffold(
      body: room != null ? _builder(ctx, room) : _buildBody(ctx),
      appBar: AppBar(title: Text(appBartTitle)),
    );
  }

  Widget _buildBody(BuildContext ctx) {
    return Zefir.of(ctx).eurus.buildRoom(
          ctx: ctx,
          token: (Utils.routeArgs(ctx) as PollingRouteParams).token,
          loadingBuilder: _loadingBuilder,
          errorBuilder: _errorBuilder,
          builder: _builder,
        );
  }

  Widget _builder(BuildContext ctx, Room room) {
    final List<Widget> childen = [
      _buildQuestion(ctx, room.currPlayer.name, room.currQuestion.content),
      _buildAnswers(ctx, room.currAnswers),
      _buildSubmitButton(ctx),
    ]
        .map((w) => Padding(
              child: w,
              padding: EdgeInsets.all(10),
            ))
        .toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: childen,
    );
  }

  Widget _buildQuestion(BuildContext ctx, String playerName, String question) {
    final q =
        question[0].toLowerCase() + question.substring(1, question.length - 1);

    return Text(
      'Odpowiedz tak jak $playerName: $q',
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
          key: ObjectKey(index),
          title: Text(answers[index].content),
          onChanged: (int value) {
            setState(() {
              _choosedAnswer = answers[index];
            });
          },
          // secondary: Text((index + 1).toString()),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext ctx) {
    final onPressed = (RunMutation runM) {
      final token = (Utils.routeArgs(ctx) as PollingRouteParams).token;
      final stateStorage = Zefir.of(ctx).storage.state;
      runM({'token': token, 'answerId': _choosedAnswer.id});
      developer.log('Send answerId ${_choosedAnswer.id} for token $token',
          name: 'PollingScreen');
      stateStorage.update(token, RoomState.WAIT_FOR_OTHER_POLLS).then((_) =>
          Navigator.of(ctx).pushReplacementNamed('/waitForOtherPolls',
              arguments: WaitForOtherPollsRouteParams(token)));
    };
    return SizedBox(
        child: Mutation(
          options: MutationOptions(document: Mutations.POLL_ANSWER),
          builder: (RunMutation runMutation, QueryResult result) {
            return RaisedButton(
              color: Colors.green,
              textColor: Colors.white,
              child: Text('Prześlij odpowiedź'),
              onPressed: () => onPressed(runMutation),
            );
          },
        ),
        width: double.infinity);
  }

  Widget _loadingBuilder(BuildContext ctx) {
    return Text('Wczytywanie...');
  }

  Widget _errorBuilder(BuildContext ctx, OperationException exception) {
    developer.log(Utils.parseExceptions(exception), name: 'PollingScreen');
    return Text('Error occured');
  }
}

class PollingRouteParams {
  final int token;
  final Room room;

  PollingRouteParams(this.token, {Room room}) : room = room;
}
