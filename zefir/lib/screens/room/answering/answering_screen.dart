import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/screens/room/answering/answering_service.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/eurus/queries.dart';
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
  final _answerController = TextEditingController();

  String _answer;

  _AnsweringScreenState() {
    _answerController.addListener(() {
      _answer = _answerController.value.text.trim();
      developer.log('Answer is $_answer', name: 'AnsweringScreen');
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final int token = (Utils.routeArgs(ctx) as AnsweringRouteParams).token;

    return Scaffold(appBar: _buildAppBar(ctx), body: _buildBody(ctx, token));
  }

  Widget _buildAppBar(BuildContext ctx) {
    return AppBar(
      title: Text('Odpowiedz na pytanie'),
      leading: _buildLeading(ctx),
    );
  }

  Widget _buildLeading(BuildContext ctx) {
    return BackButton(
      onPressed: () => Navigator.of(ctx).popUntil(ModalRoute.withName('/')),
    );
  }

  Widget _buildBody(BuildContext ctx, int token) {
    Eurus eurus = Zefir.of(ctx).eurus;

    Widget form = _buildForm(ctx, token);

    Widget dynamicData = eurus.buildRoom(
        ctx: ctx,
        token: token,
        loadingBuilder: _loadingBuilder,
        errorBuilder: _errorBuilder,
        builder: _builder);

    List<Widget> children = [dynamicData, form];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: children,
    );
  }

  Widget _loadingBuilder(BuildContext ctx) {
    return Text('Proszę czekać, trwa pobieranie informacji');
  }

  Widget _errorBuilder(BuildContext ctx, OperationException exception) {
    return Text('Wystąpił błąd...');
  }

  Widget _builder(BuildContext ctx, Room room) {
    return Text(room.currQuestion.content);
  }

  Widget _buildForm(BuildContext ctx, int token) {
    developer.log('Answer in _buildForm is $_answer', name: 'AnsweringScreen');

    return Form(
      key: GlobalKey<FormState>(),
      child: Column(
        children: <Widget>[
          _buildTextField(ctx),
          AnsweringSerice.buildSubmitButton(ctx, token, _answer),
        ],
      ),
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
