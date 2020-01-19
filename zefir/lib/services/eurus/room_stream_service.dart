import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/services/storage/state.dart';
import 'dart:developer' as developer;

class RoomStreamService {
  GraphQLClient _client;
  Stream<Room> _stream;
  StateStorage _stateStorage;

  RoomStreamService(this._client, this._stateStorage);

  get stream => _stream;

  void createStreamFor({@required int token}) {
    final options = _buildOptions(token);

    _stream = _client
        .watchQuery(options)
        .stream
        .where((result) => !result.hasException && result.data != null)
        .asyncMap((result) => parseRoom(result, token));
  }

  Future<Room> parseRoom(QueryResult result, int token) async {
    final room = Room.fromGraphQL(result.data['player']['room'], token);
    final RoomState stateFromDb = await _stateStorage.fetch(token);

    room.state = RoomStateUtils.merge(stateFromDb, room.state);
    return room;
  }

  WatchQueryOptions _buildOptions(int token) {
    return WatchQueryOptions(
      fetchResults: true,
      pollInterval: 5,
      document: Queries.FETCH_ROOM,
      fetchPolicy: FetchPolicy.networkOnly,
      errorPolicy: ErrorPolicy.all,
      variables: {'token': token},
    );
  }
}
