import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WaitForOtherQuestionsScreen extends StatelessWidget {
  const WaitForOtherQuestionsScreen();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(appBar: _buildAppBar(ctx), body: _buildBody(ctx));
  }

  Widget _buildAppBar(BuildContext ctx) {
    return AppBar(
      title: Text('Oczekiwanie na pytania'),
      leading: _buildLeading(ctx),
    );
  }

  Widget _buildLeading(BuildContext ctx) {
    return BackButton(
      onPressed: () => Navigator.of(ctx).popUntil(ModalRoute.withName('/')),
    );
  }

  Widget _buildBody(BuildContext ctx) {
    return Column(
      children: [
        _buildMessage(ctx),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _buildMessage(BuildContext ctx) {
    return Text('Oczekiwanie na dodanie pytań przez innych graczy...');
  }
}
