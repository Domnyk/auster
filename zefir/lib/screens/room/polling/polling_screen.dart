import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/screens/room/answering/answering_screen.dart';

class PollignScreen extends StatelessWidget {
  int token;

  const PollignScreen();

  @override
  Widget build(BuildContext ctx) {
    final int token = (Utils.routeArgs(ctx) as AnsweringRouteParams).token;

    return Scaffold(appBar: _buildAppBar(ctx), body: _buildBody(ctx));
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

  Widget _buildBody(BuildContext ctx) {
    return Text('dupa, hehe');
  }
}

class PollingRouteParams {
  final int token;

  PollingRouteParams(this.token);
}
