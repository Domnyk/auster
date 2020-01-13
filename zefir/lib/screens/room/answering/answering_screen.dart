import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/question.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/answering/answering_service.dart';
import 'package:zefir/screens/room/wait_for_other_answers.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/eurus/mutations.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/services/storage/state.dart';
import 'package:zefir/utils.dart';
import 'dart:developer' as developer;

class AnsweringScreen extends StatefulWidget {
  const AnsweringScreen();
  @override
  _AnsweringScreenState createState() => _AnsweringScreenState();
}

class AnsweringRouteParams {
  final int token;

  AnsweringRouteParams(this.token);
}

class _AnsweringScreenState extends State<AnsweringScreen> {
  static const String pleaseWait = 'Losujemy Twoje pytanie, jeszcze moment...';

  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();

  Question _question;
  String _answer;

  @override
  void initState() {
    _question = null;
    _answer = null;

    super.initState();
  }

  _AnsweringScreenState() {
    _answerController.addListener(() {
      _answer = _answerController.value.text.trim();
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final int token = (Utils.routeArgs(ctx) as AnsweringRouteParams).token;

    return Scaffold(
      appBar: AppBar(
        title: Text('Odpowiedz na pytanie'),
      ),
      body: _question == null
          ? _buildWaitingMessage(ctx, token)
          : _buildQuestionForm(ctx, token),
    );
  }

  Widget _buildWaitingMessage(BuildContext ctx, token) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Query(
          options: QueryOptions(
              fetchPolicy: FetchPolicy.networkOnly,
              document: Queries.FETCH_ROOM,
              variables: {'token': token}),
          builder: (result, {fetchMore, refetch}) {
            if (!result.hasException && result.data != null) {
              Question question = Question.fromGraphQl(
                  result.data['player']['room']['currQuestion']);

              SchedulerBinding.instance
                  .addPostFrameCallback((_) => setState(() {
                        _question = question;
                      }));
            }

            return Text(pleaseWait,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: Theme.of(ctx).textTheme.headline.fontSize));
          },
        )
      ],
    );
  }

  Widget _buildQuestionForm(BuildContext ctx, int token) {
    return Form(
      key: _formKey,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _question.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Theme.of(ctx).textTheme.headline.fontSize),
            ),
            _buildTextField(ctx),
            Mutation(
              options: MutationOptions(
                  document: Mutations.SEND_ANSWER,
                  onError: (exception) => developer.log(
                      'Error occured when sending mutation: ${Utils.parseExceptions(exception)}',
                      name: 'AsnweringScreen'),
                  onCompleted: (data) =>
                      developer.log('Mutation has been completed')),
              builder: (runMutation, result) {
                return SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                        onPressed: () {
                          bool isFormValid = _formKey.currentState.validate();
                          if (isFormValid == false) {
                            return;
                          }

                          final StateStorage stateStorage =
                              Zefir.of(ctx).storage.state;
                          // runMutation({'token': token, 'answer': _answer});
                          stateStorage
                              .update(token, RoomState.WAIT_FOR_OTHER_ANSWERS)
                              .then((_) => Navigator.of(ctx)
                                  .pushReplacementNamed('/waitForOtherAnswers',
                                      arguments: WaitForOtherAnswersRouteParams(
                                          token)));
                        },
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text('Dodaj odpowiedź')));
              },
            )
          ]
              .map((w) => Padding(
                    child: w,
                    padding: EdgeInsets.all(10),
                  ))
              .toList()),
    );
  }

  Widget _buildTextField(BuildContext ctx) {
    final validator =
        (String val) => val.isEmpty ? 'Kod nie może być pusty' : null;
    final decoration =
        InputDecoration(border: OutlineInputBorder(), labelText: 'Odpowiedź');

    return TextFormField(
        validator: validator,
        decoration: decoration,
        controller: _answerController);
  }
}
