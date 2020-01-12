import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/answer.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/services/eurus/mutations.dart';
import 'package:zefir/utils.dart';
import 'dart:developer' as developer;

class PollignScreen extends StatefulWidget {
  const PollignScreen();

  @override
  _PollignScreenState createState() => _PollignScreenState(null);
}

class _PollignScreenState extends State<PollignScreen> {
  Answer _choosedAnswer;

  _PollignScreenState(this._choosedAnswer);

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: _buildBody(ctx),
      appBar: AppBar(
        title: Text('Zagłosuj na odpowiedź'),
        leading: _buildLeading(ctx),
      ),
    );
  }

  Widget _buildLeading(BuildContext ctx) {
    return BackButton(
      onPressed: () => Navigator.of(ctx).popUntil(ModalRoute.withName('/')),
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

  Widget _buildQuestion(BuildContext ctx, String question) {
    return Text(question);
  }

  Widget _buildAnswers(BuildContext ctx, List<Answer> answers) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: answers.length,
      itemBuilder: (BuildContext ctx, int index) {
        return CheckboxListTile(
          key: ObjectKey(index),
          title: Text(answers[index].content),
          value:
              _choosedAnswer != null && _choosedAnswer.id == answers[index].id,
          onChanged: (bool value) {
            setState(() {
              _choosedAnswer = answers[index];
            });
          },
          secondary: Text((index + 1).toString()),
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
      // stateStorage.update(token, RoomState.WAIT_FOR_OTHER_QUESTIONS).then((_) =>
      //     Navigator.of(ctx).pushNamed('/waitForOtherQuestions',
      //         arguments: WaitForOtherQuestionsRouteParams(token)));
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

  Widget _builder(BuildContext ctx, Room room) {
    final List<Widget> childen = [
      _buildQuestion(ctx, room.currQuestion.content),
      _buildAnswers(ctx, room.currAnswers),
      _buildSubmitButton(ctx),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: childen,
    );
  }
}

class PollingRouteParams {
  final int token;

  PollingRouteParams(this.token);
}
