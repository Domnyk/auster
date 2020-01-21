import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/wait_for_other_questions_screen.dart';
import 'package:zefir/screens/room/wait_for_players_screen.dart';
import 'package:zefir/services/eurus/mutations.dart';
import 'package:zefir/services/storage/state.dart';
import 'package:zefir/utils.dart';
import 'dart:developer' as developer;

import 'package:zefir/widgets/confirm_button.dart';

class AddQuestionScreen extends StatelessWidget {
  static const String _addQuestionText = 'Dodaj pytanie';

  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();

  String _question;

  AddQuestionScreen() {
    _questionController.addListener(() {
      _question = _questionController.value.text.trim();
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(resizeToAvoidBottomInset: false, appBar: _buildAppBar(ctx), body: _buildBody(ctx));
  }

  Widget _buildAppBar(BuildContext ctx) {
    return AppBar(
      title: Text('Dodaj pytanie'),
      leading: _buildLeading(ctx),
    );
  }

  Widget _buildLeading(BuildContext ctx) {
    return BackButton(
      onPressed: () => Navigator.of(ctx).popUntil(ModalRoute.withName('/')),
    );
  }

  Widget _buildBody(BuildContext ctx) {
    final List<Widget> controls = [      
      _buildQuestionField(ctx),
      _buildSubmitButton(ctx),
    ].map((w) => Padding(
              child: w,
              padding: EdgeInsets.all(10),
            ))
        .toList();
    
    return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: controls,
        ));
  }

  Widget _buildQuestionField(BuildContext ctx) {
    return TextFormField(
      controller: _questionController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      minLines: 3,
      maxLines: 10,
      decoration: InputDecoration(labelText: 'Twoja pytanie'),
      validator: (v) => v.isEmpty ? 'Podaj treść pytania' : null,
    );
  }

  Widget _buildSubmitButton(BuildContext ctx) {
    final int token = (Utils.routeArgs(ctx) as AddQuestionRouteParams).token;
    final StateStorage stateStorage = Zefir.of(ctx).eurus.storage.state;
    final btn = Mutation(
      options: MutationOptions(
          document: Mutations.ADD_QUESTION,
          onError: (OperationException exception) {
            developer.log(
                'Exception occured when sending question ${exception.graphqlErrors[0].toString()}');
          },
          onCompleted: (data) {
            developer
                .log('Sending of question has ended. Resp: ${data.toString()}');
          }),
      builder: (RunMutation runMutation, QueryResult result) {
        return ConfirmButton(
          text: _addQuestionText,
          onPressed: () => _addQuestion(ctx, runMutation),
        );
      },
    );

    return SizedBox(
      child: btn,
      width: double.infinity,
    );
  }

  void _addQuestion(
    BuildContext ctx,
    RunMutation runMutation,
  ) {
    final int token = (Utils.routeArgs(ctx) as AddQuestionRouteParams).token;
    final StateStorage stateStorage = Zefir.of(ctx).eurus.storage.state;

    runMutation({'token': token, 'question': _question});
    developer.log('Send question $_question with token $token',
        name: 'AddQuestionScreen');
    stateStorage.update(token, RoomState.WAIT_FOR_OTHER_QUESTIONS).then((_) =>
        Navigator.of(ctx).pushReplacementNamed('/waitForOtherQuestions',
            arguments: WaitForOtherQuestionsRouteParams(token)));
  }
}

class AddQuestionRouteParams {
  final int token;

  AddQuestionRouteParams(this.token);
}
