import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/screens/room/wait_for_other_questions.dart';
import 'package:zefir/screens/room/wait_for_players.dart';
import 'package:zefir/services/eurus/mutations.dart';
import 'package:zefir/utils.dart';

class AddQuestionScreen extends StatelessWidget {
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
    return Scaffold(appBar: _buildAppBar(ctx), body: _buildBody(ctx));
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
    return Column(children: [
      Form(
          key: _formKey,
          child: Column(
            children: _buildFormControls(ctx),
          ))
    ]);
  }

  List<Widget> _buildFormControls(BuildContext ctx) {
    final List<Widget> controls = [
      _buildQuestionField(ctx),
      _buildSubmitButton(ctx),
    ];

    return controls
        .map((w) => Padding(
              child: w,
              padding: EdgeInsets.all(10),
            ))
        .toList();
  }

  Widget _buildQuestionField(BuildContext ctx) {
    return TextFormField(
      controller: _questionController,
      minLines: 3,
      maxLines: 10,
      decoration: InputDecoration(
          border: OutlineInputBorder(), labelText: 'Twoja pytanie'),
      validator: (v) => v.isEmpty ? 'Podaj treść pytania' : null,
    );
  }

  Widget _buildSubmitButton(BuildContext ctx) {
    final int token =
        (Utils.routeArgs(ctx) as AddQuestionRouteParams).room.deviceToken;
    final btn = Mutation(
      options: _buildMutationOptions(ctx),
      builder: (RunMutation runMutation, QueryResult result) {
        return RaisedButton(
            onPressed: () {
              // runMutation({'token': token, 'content': _question});
              Navigator.of(ctx).pushNamed('/waitForOtherQuestions',
                  arguments: WaitForOtherQuestionsRouteParams(token));
            },
            color: Colors.green,
            textColor: Colors.white,
            child: Text('Dodaj pytanie'));
      },
    );

    return SizedBox(
      child: btn,
      width: double.infinity,
    );
  }

  MutationOptions _buildMutationOptions(BuildContext ctx) {
    return MutationOptions(document: Mutations.ADD_QUESTION);
  }
}

class AddQuestionRouteParams {
  final Room room;

  AddQuestionRouteParams(this.room);
}
