import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/wait_for_other_questions_screen.dart';
import 'package:zefir/services/eurus/mutations.dart';
import 'package:zefir/services/storage/state.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/zefir.dart';
import 'dart:developer' as developer;

class AddQuestionScreen extends StatefulWidget {
  static const String _addQuestionText = 'Dodaj pytanie';

  final int _token;
  final int _numOfQuestions;

  AddQuestionScreen(this._token, this._numOfQuestions);

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _questionControllers = [];
  final List<String> _questions = [];

  _AddQuestionScreenState();

  @override
  void initState() {
    super.initState();

    Iterable.generate(widget._numOfQuestions).forEach((_) {
      _questionControllers.add(TextEditingController());
      _questions.add(null);
    });
    for (var i = 0; i < widget._numOfQuestions; i++) {
      final questionController = _questionControllers[i];

      _questionControllers[i].addListener(() {
        _questions[i] = questionController.value.text.trim();
      });
    }
  }

  @override
  void dispose() {
    _questionControllers.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    AppBar appBar = _buildAppBar(ctx);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar,
        body: _buildBody(ctx, appBar.preferredSize.height));
  }

  Widget _buildAppBar(BuildContext ctx) {
    String title =
        widget._numOfQuestions == 1 ? 'Dodaje pytanie' : 'Dodaj pytania';

    return AppBar(
      title: Text(title),
      leading: _buildLeading(ctx),
    );
  }

  Widget _buildLeading(BuildContext ctx) {
    return BackButton(
      onPressed: () => Navigator.of(ctx).popUntil(ModalRoute.withName('/')),
    );
  }

  Widget _buildBody(BuildContext ctx, double appBarHeight) {
    final List<Widget> controls = [
      Column(children: _buildQuestionFields(ctx)),
      _buildSubmitButton(ctx),
    ]
        .map((w) => Padding(
              child: w,
              padding: EdgeInsets.all(10),
            ))
        .toList();

    final _pageSize = MediaQuery.of(context).size.height;
    final _notifySize = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
        child: SizedBox(
      height: _pageSize - (_notifySize + appBarHeight),
      child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: controls,
          )),
    ));
  }

  List<Widget> _buildQuestionFields(BuildContext ctx) {
    int numOfQuestions =
        (Utils.routeArgs(ctx) as AddQuestionRouteParams).numOfQuestions;

    return Iterable.generate(numOfQuestions)
        .map((i) => Padding(
              padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
              child: TextFormField(
                controller: _questionControllers[i],
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                minLines: 2,
                maxLines: 3,
                decoration:
                    InputDecoration(labelText: 'Pytanie numer ${i + 1}'),
                validator: (v) => v.isEmpty ? 'Podaj treść pytania' : null,
              ),
            ))
        .toList() as List<Widget>;
  }

  Widget _buildSubmitButton(BuildContext ctx) {
    return Mutation(
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
        return RaisedButton(
          child: Text(AddQuestionScreen._addQuestionText),
          onPressed: () {
            if (!_formKey.currentState.validate()) return;

            Iterable.generate(widget._numOfQuestions)
                .forEach((i) => _addQuestion(ctx, runMutation, i));
          },
          color: Colors.green,
          textColor: Colors.white,
        );
      },
    );
  }

  void _addQuestion(
    BuildContext ctx,
    RunMutation runMutation,
    int idx,
  ) {
    final int token = (Utils.routeArgs(ctx) as AddQuestionRouteParams).token;
    final StateStorage stateStorage = Zefir.of(ctx).eurus.storage.state;

    runMutation({'token': token, 'question': _questions[idx]});
    developer.log('Send question ${_questions[idx]} with token $token',
        name: 'AddQuestionScreen');
    stateStorage.update(token, RoomState.WAIT_FOR_OTHER_QUESTIONS).then((_) =>
        Navigator.of(ctx).pushReplacementNamed('/waitForOtherQuestions',
            arguments: WaitForOtherQuestionsRouteParams(token)));
  }
}

class AddQuestionRouteParams {
  final int token;
  final int numOfQuestions;

  AddQuestionRouteParams(this.token, this.numOfQuestions);
}
