import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room_state.dart';
import 'dart:developer' as developer;
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/services/storage/state.dart';
import '../../../utils.dart';

class WaitForOtherQuestionsService {
  static Widget buildBody(BuildContext ctx, int token,
      {@required errorBuilder, @required builder}) {
    return Query(
        options: _buildQueryOptions(token),
        builder: (QueryResult result, {Refetch refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            final exceptions = Utils.parseExceptions(result.exception);
            developer
                .log('Exception occured when fetching room state: $exceptions');
            return errorBuilder();
          }

          developer.log('result is: ${result.data.toString()}',
              name: 'WaitForOtherQuestionsService');

          if (result.loading) {
            return Text('Loading');
          }

          final StateStorage stateStorage = Zefir.of(ctx).storage.state;
          return FutureBuilder(
            future: stateStorage.fetch(token),
            builder: (BuildContext context, AsyncSnapshot<RoomState> snapshot) {
              if (snapshot.hasError) {
                return errorBuilder();
              }

              if (snapshot.hasData) {
                final RoomState stateFromBackend = parseData(result);
                final bool isInWaitingState =
                    _isInWaitingState(stateFromBackend, snapshot.data);
                return builder(context, isInWaitingState);
              }

              return Text('Loading in progress');
            },
          );
        });
  }

  static QueryOptions _buildQueryOptions(int token) {
    return QueryOptions(
        document: Queries.FEETCH_ROOM_STATE,
        pollInterval: 2,
        variables: {'token': token});
  }

  static RoomState parseData(QueryResult result) {
    return RoomStateParser.parse(result.data['player']['room']['state']);
  }

  static bool _isInWaitingState(
      RoomState stateFromBackend, RoomState stateFromDatabase) {
    if (stateFromBackend == RoomState.ANSWERING &&
        stateFromDatabase == RoomState.WAIT_FOR_OTHER_QUESTIONS) {
      return false;
    } else if (stateFromBackend == RoomState.COLLECTING &&
        stateFromDatabase == RoomState.WAIT_FOR_OTHER_QUESTIONS) {
      return true;
    } else {
      throw Exception(
          'Inproper states. From DB: $stateFromDatabase, from backend: $stateFromBackend');
    }
  }
}
