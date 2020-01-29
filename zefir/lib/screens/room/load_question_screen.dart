import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/wait_for_other_questions_screen.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/eurus/mutations.dart';
import 'dart:developer' as developer;

import 'package:zefir/zefir.dart';

class LoadQuestionScreen extends StatefulWidget {
  static const String _loadQuestionText = 'Dodaj pytania';

  final int _token;
  final int _numOfQuestionsToChoose;
  final List<String> _questions;

  LoadQuestionScreen(
      this._token, this._numOfQuestionsToChoose, this._questions);

  @override
  _LoadQuestionScreenState createState() => _LoadQuestionScreenState();
}

class _LoadQuestionScreenState extends State<LoadQuestionScreen> {
  List<bool> _isSelected;

  @override
  void initState() {
    _isSelected = List.filled(widget._questions.length, false);
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    Eurus eurus = Zefir.of(ctx).eurus;

    return Scaffold(
        appBar: AppBar(
          title: Text('Wczytaj pytania'),
        ),
        floatingActionButton: Visibility(
          visible: _calculateNumOfSelected() == widget._numOfQuestionsToChoose,
          child: FloatingActionButton(
            child: Icon(Icons.file_upload),
            onPressed: _calculateNumOfSelected() ==
                    widget._numOfQuestionsToChoose
                ? () async {
                    Iterable.generate(widget._questions.length)
                        .where((i) => _isSelected[i])
                        .forEach((i) async {
                      await eurus.client
                          .mutate(_buildOptions(widget._questions[i]));
                    });

                    eurus.storage.state
                        .update(
                            widget._token, RoomState.WAIT_FOR_OTHER_QUESTIONS)
                        .then((_) {
                      Navigator.of(ctx).pushNamedAndRemoveUntil(
                          '/waitForOtherQuestions', ModalRoute.withName('/'),
                          arguments:
                              WaitForOtherQuestionsRouteParams(widget._token));
                    });
                  }
                : null,
          ),
        ),
        body: ListView.builder(
          itemCount: widget._questions.length,
          itemBuilder: (BuildContext ctx, int index) {
            return _Question(
                widget._questions[index],
                _isSelected[index],
                _isQuestionDisabled(index)
                    ? null
                    : (bool val) {
                        setState(() {
                          this._isSelected[index] = !this._isSelected[index];
                        });
                      });
          },
        ));
  }

  int _calculateNumOfSelected() {
    return _isSelected
        .map((selected) => selected ? 1 : 0)
        .reduce((acc, elem) => acc + elem);
  }

  MutationOptions _buildOptions(String q) {
    return MutationOptions(
        document: Mutations.ADD_QUESTION,
        onError: handleSendError,
        onCompleted: handleCompleted,
        variables: {'token': widget._token, 'question': q});
  }

  void handleSendError(OperationException exception) {
    developer.log(
        'Exception occured when sending question ${exception.graphqlErrors[0].toString()}');
  }

  void handleCompleted(data) {
    developer.log('Sending of question has ended. Resp: ${data.toString()}');
  }

  bool _isQuestionDisabled(int questionIndex) {
    return _calculateNumOfSelected() == widget._numOfQuestionsToChoose &&
        _isSelected[questionIndex] == false;
  }
}

class LoadQuestionRouteParams {
  final int token;
  final int numOfQuestionsToChoose;
  final List<String> questions;

  LoadQuestionRouteParams(
      this.token, this.numOfQuestionsToChoose, this.questions);
}

class _Question extends StatelessWidget {
  final String _question;
  final bool _isSelected;
  final Function _onChanged;

  const _Question(this._question, this._isSelected, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        title: Text(_question), value: _isSelected, onChanged: _onChanged);
  }
}
