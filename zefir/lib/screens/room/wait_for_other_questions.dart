import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/room_state.dart';
import 'dart:developer' as developer;
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/utils.dart';

class WaitForOtherQuestionsScreen extends StatelessWidget {
  const WaitForOtherQuestionsScreen();

  @override
  Widget build(BuildContext ctx) {
    final int token =
        (Utils.routeArgs(ctx) as WaitForOtherQuestionsRouteParams).token;

    return Scaffold(appBar: _buildAppBar(ctx), body: _buildBody(ctx, token));
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

  Widget _buildBody(BuildContext ctx, int token) {
    return Query(
        options: _buildQueryOptions(token),
        builder: (result, {refetch, fetchMore}) => _resultsBuilder(ctx, result,
            refetch: refetch, fetchMore: fetchMore));
  }

  QueryOptions _buildQueryOptions(int token) {
    return QueryOptions(
        document: Queries.FEETCH_ROOM_STATE,
        pollInterval: 2,
        variables: {'token': token});
  }

  Widget _resultsBuilder(BuildContext ctx, QueryResult result,
      {VoidCallback refetch, FetchMore fetchMore}) {
    if (result.hasException) {
      developer.log(
          'Exception occured when fetching room state: ${Utils.parseExceptions(result)}');
      return null; // TODO: handle errors
    }

    developer.log('Data received: ${result.data.toString()}',
        name: 'WaitForOtherQuestionsScreen');

    RoomState state =
        RoomStateParser.parse(result.data['player']['room']['state']);

    if (state == RoomState.ANSWERING) {
      // TODO: update state in DB
      Navigator.pushNamed(ctx, '/answering');
      return null;
    } else if (state == RoomState.WAIT_FOR_OTHER_QUESTIONS) {
      return Text('Oczekiwanie na dodanie pytań przez innych graczy...');
    } else {
      throw Exception(
          'Room is in state ${state.toString()}. WaitForOtherQuestionsScreen widget should not render for this state');
    }
  }
}

class WaitForOtherQuestionsRouteParams {
  final int token;

  const WaitForOtherQuestionsRouteParams(this.token);
}
