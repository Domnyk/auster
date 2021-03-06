import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/question.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/load_question_screen.dart';
import 'package:zefir/screens/room/wait_for_other_questions_screen.dart';
import 'package:zefir/services/eurus/eurus.dart';
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
      _buildButtons(ctx),
    ]
        .map((w) => Padding(
              child: w,
              padding: EdgeInsets.all(10),
            ))
        .toList();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
            child: ConstrainedBox(
          constraints: constraints.copyWith(
            minHeight: constraints.maxHeight,
            maxHeight: double.infinity,
          ),
          child: IntrinsicHeight(
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: controls,
                )),
          ),
        ));
      },
    );
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
                decoration: InputDecoration(
                    labelText: numOfQuestions == 1
                        ? 'Pytanie'
                        : 'Pytanie numer ${i + 1}'),
                validator: (v) => v.isEmpty ? 'Podaj treść pytania' : null,
              ),
            ))
        .toList() as List<Widget>;
  }

  Widget _buildButtons(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [_navigateToLoadQuestionButton(ctx), _buildSubmitButton(ctx)],
    );
  }

  Widget _navigateToLoadQuestionButton(BuildContext ctx) {
    return RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: Text('Wczytaj pytania'),
      onPressed: () {
        Zefir.of(ctx).eurus.question.fetchAll().then((questions) {
          Navigator.of(ctx).pushNamed('/loadQuestion',
              arguments: LoadQuestionRouteParams(
                  widget._token, widget._numOfQuestions, questions));
        });
      },
    );
  }

  Widget _buildSubmitButton(BuildContext ctx) {
    return RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: Text(AddQuestionScreen._addQuestionText),
      onPressed: () {
        if (!_formKey.currentState.validate()) return;

        Iterable.generate(widget._numOfQuestions).forEach((i) async {
          await _addQuestion(ctx, _questions[i]);
        });

        final StateStorage stateStorage = Zefir.of(ctx).eurus.storage.state;
        stateStorage
            .update(widget._token, RoomState.WAIT_FOR_OTHER_QUESTIONS)
            .then((_) => Navigator.of(ctx).pushReplacementNamed(
                '/waitForOtherQuestions',
                arguments: WaitForOtherQuestionsRouteParams(widget._token)));
      },
    );
  }

  Future<void> _addQuestion(BuildContext ctx, String q) async {
    final Eurus eurus = Zefir.of(ctx).eurus;

    await eurus.client.mutate(_buildOptions(q));
  }

  MutationOptions _buildOptions(String q) {
    return MutationOptions(
        document: Mutations.ADD_QUESTION,
        onError: (OperationException exception) {
          developer.log(
              'Exception occured when sending question ${exception.graphqlErrors[0].toString()}');
        },
        onCompleted: (data) {
          developer
              .log('Sending of question has ended. Resp: ${data.toString()}');
        },
        variables: {'token': widget._token, 'question': Question.format(q)});
  }
}

class AddQuestionRouteParams {
  final int token;
  final int numOfQuestions;

  AddQuestionRouteParams(this.token, this.numOfQuestions);
}
