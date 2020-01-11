import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/wait_for_other_questions/wait_for_other_questions_service.dart';
import 'dart:developer' as developer;
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/services/storage/state.dart';
import 'package:zefir/utils.dart';

class WaitForOtherQuestionsScreen extends StatelessWidget {
  const WaitForOtherQuestionsScreen();

  @override
  Widget build(BuildContext ctx) {
    final int token =
        (Utils.routeArgs(ctx) as WaitForOtherQuestionsRouteParams).token;

    return Scaffold(
        appBar: _buildAppBar(ctx),
        body: WaitForOtherQuestionsService.buildBody(ctx, token,
            errorBuilder: _errorBuilder, builder: _builder));
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

  Widget _errorBuilder() {
    return null;
  }

  Widget _builder(BuildContext ctx, bool isInWaitingState) {
    if (isInWaitingState) {
      return Text('Proszę czakać aż pozostali gracze dodadzą pytania');
    } else {
      // Navigator.of(ctx).pushNamed('/answering');
      return Text('Przechodzimy do pokoju');
    }
  }
}

class WaitForOtherQuestionsRouteParams {
  final int token;

  const WaitForOtherQuestionsRouteParams(this.token);
}
