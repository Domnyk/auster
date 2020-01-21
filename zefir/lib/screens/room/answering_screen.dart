import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/question.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen_for_question_owner.dart';
import 'package:zefir/screens/room/wait_for_other_answers.dart';
import 'package:zefir/screens/room/wait_for_other_polls.dart';
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
  Player _currPlayer;
  String _answer;
  int _token;
  StateStorage _stateStorage;
  bool _isButtonDisabled;

  @override
  void initState() {
    _question = null;
    _currPlayer = null;
    _answer = null;
    _token = null;
    _stateStorage = null;
    _isButtonDisabled = false;

    super.initState();
  }

  _AnsweringScreenState() {
    _answerController.addListener(() {
      _answer = _answerController.value.text.trim();
    });
  }

  @override
  Widget build(BuildContext ctx) {
    _token = (Utils.routeArgs(ctx) as AnsweringRouteParams).token;
    _stateStorage = Zefir.of(ctx).eurus.storage.state;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Odpowiedz na pytanie'),
      ),
      body: _question == null
          ? _buildWaitingMessage(ctx)
          : _buildQuestionForm(ctx),
    );
  }

  Widget _buildWaitingMessage(BuildContext ctx) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Query(
          options: QueryOptions(
              fetchPolicy: FetchPolicy.networkOnly,
              document: Queries.FETCH_ROOM,
              variables: {'token': _token}),
          builder: (result, {fetchMore, refetch}) {
            if (!result.hasException && result.data != null) {
              final room =
                  Room.fromGraphQL(result.data['player']['room'], _token);

              SchedulerBinding.instance
                  .addPostFrameCallback((_) => setState(() {
                        _question = room.currQuestion;
                        _currPlayer = room.currPlayer;
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

  Widget _buildQuestionForm(BuildContext ctx) {
    return Form(
      key: _formKey,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [ 
            Column(
              children: <Widget>[
                Padding(child: _buildQuestionText(ctx), padding: const EdgeInsets.fromLTRB(10, 10, 10, 0)),
                _buildRoleText(ctx, _token, _currPlayer),
            Padding(
              padding: const EdgeInsets.all(10),
              child: _buildTextField(ctx),
            ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: _buildSubmitButton(ctx, _token,
                  onError: (exception) => developer.log(
                      'Error occured when sending mutation: ${Utils.parseExceptions(exception)}',
                      name: 'AsnweringScreen'),
                  onCompleted: (room) => _navigateToNextScreen(ctx, room),
                  builder: (runMutation, result) {
                    return RaisedButton(
                        onPressed: _isButtonDisabled
                            ? null
                            : () => _sendAnswer(runMutation),
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text('Dodaj odpowiedź'));
                  }),
            ),
          ]),
    );
  }

  Widget _buildRoleText(BuildContext ctx, int deviceToken, Player currPlayer) {
    return deviceToken == currPlayer.token
        ? Text('Inni gracze będą odpowiadać tak jak Ty')
        : null;
  }

  Widget _buildSubmitButton(BuildContext ctx, int token,
      {onError, void Function(Room) onCompleted, builder}) {
    return Mutation(
      options: MutationOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: Mutations.SEND_ANSWER,
          onError: (exception) => onError(exception),
          onCompleted: (data) {
            Room room =
                Room.fromGraphQL(data['sendAnswer']['player']['room'], token);
            onCompleted(room);
          }),
      builder: (runMutation, result) => builder(runMutation, result),
    );
  }

  Widget _buildQuestionText(BuildContext ctx) {
    return Text(
      _question.content,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: Theme.of(ctx).textTheme.headline.fontSize),
    );
  }

  Widget _buildTextField(BuildContext ctx) {
    final validator =
        (String val) => val.isEmpty ? 'Kod nie może być pusty' : null;
    final decoration = InputDecoration(labelText: 'Odpowiedź');

    return TextFormField(
        validator: validator,
        decoration: decoration,
        controller: _answerController);
  }

  void _navigateToNextScreen(
      BuildContext ctx, Room roomAfterMutionFromBackend) {
    if (roomAfterMutionFromBackend.state == RoomState.POLLING) {
      if (_amICurrentPlayer()) {
        return _navigateToPollingForQuestionOwner(ctx);
      } else {
        return _navigateToPolling(ctx, roomAfterMutionFromBackend);
      }
    } else if (roomAfterMutionFromBackend.state == RoomState.ANSWERING) {
      return _navigateToWaitForOtherAnswers(ctx);
    } else {
      throw Exception(
          'Illegal state on this screen ${roomAfterMutionFromBackend.state.toMyString()}');
    }
  }

  void _navigateToPollingForQuestionOwner(BuildContext ctx) {
    final String route = '/pollingForQuestionOwner';
    final arguments = PollingScreenForQuestionOwnerRouteParams(_token);

    Navigator.of(ctx).pushReplacementNamed(route, arguments: arguments);
  }

  void _navigateToPolling(BuildContext ctx, Room room) {
    Navigator.of(ctx).pushReplacementNamed('/polling',
        arguments: PollingRouteParams(_token, room: room));
  }

  void _navigateToWaitForOtherAnswers(BuildContext ctx) {
    _stateStorage.update(_token, RoomState.WAIT_FOR_OTHER_ANSWERS).then((_) =>
        Navigator.of(ctx).pushReplacementNamed('/waitForOtherAnswers',
            arguments: WaitForOtherAnswersRouteParams(_token)));
  }

  void _sendAnswer(RunMutation runMutation) {
    bool isFormValid = _formKey.currentState.validate();
    if (isFormValid == false) {
      return;
    }

    runMutation({'token': _token, 'answer': _answer});
    setState(() {
      _isButtonDisabled = true;
    });
  }

  bool _amICurrentPlayer() {
    return _token == _currPlayer.token;
  }
}
