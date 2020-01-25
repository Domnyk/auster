import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/services/eurus/exceptions/no_such_room_exception.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/services/eurus/room_stream_service.dart';
import 'package:zefir/services/storage/question.dart';
import 'package:zefir/services/storage/state.dart';
import 'package:zefir/services/storage/storage.dart';
import 'package:zefir/services/storage/token.dart';
import 'package:zefir/typedefs.dart';
import 'package:zefir/zefir.dart';
import 'dart:developer' as developer;
import 'mutations.dart';

class Eurus {
  GraphQLClient _client;
  RoomStreamService _roomStreamService;
  Storage _storage;

  Eurus({@required GraphQLClient client}) : _client = client {
    _storage = Storage(_client);
    _roomStreamService = RoomStreamService(_client, _storage.state);
  }

  GraphQLClient get client => _client;
  RoomStreamService get roomStreamService => _roomStreamService;
  Storage get storage => _storage;

  QuestionStorage get question => _storage.question;

  Future<Room> createNewRoom(TokenStorage storage,
      {@required String roomName,
      @required String playerName,
      @required int numOfPlayers,
      @required int numOfRounds}) async {
    String joinCode = await _createNewRoomWithoutJoining(
        name: roomName, numOfPlayers: numOfPlayers, numOfRounds: numOfRounds);
    Room room = await joinRoom(roomCode: joinCode, playerName: playerName);
    storage.insert(room.deviceToken, initialState: RoomState.JOINING);
    return room;
  }

  Future<String> _createNewRoomWithoutJoining(
      {@required String name,
      @required int numOfPlayers,
      @required int numOfRounds}) async {
    final mutationOptions = MutationOptions(
        document: Mutations.CREATE_NEW_ROOM,
        variables: {
          'name': name,
          'players': numOfPlayers,
          'rounds': numOfRounds
        });

    QueryResult qr = await client.mutate(mutationOptions);
    if (qr.hasException) {
      throw ('Creating new room failed with ' + _createErrorMsg(qr));
    }

    final String joinCode = qr.data['newRoom']['joinCode'] as String;
    developer.log('Sucessfully created room $name with join code $joinCode',
        name: 'eurus._createNewRoomWithoutJoining');
    return joinCode;
  }

  Future<Room> joinRoom(
      {@required String roomCode, @required String playerName}) async {
    final mutationOptions = MutationOptions(
        document: Mutations.JOIN_ROOM,
        variables: {'roomCode': roomCode, 'playerName': playerName});

    QueryResult qr = await client.mutate(mutationOptions);
    if (qr.hasException) {
      throw NoSuchRoomException(roomCode);
    }

    int token = qr.data['joinRoom']['token'] as int;
    Room room = Room.fromGraphQL(qr.data['joinRoom']['room'], token);

    return room;
  }

  Stream<Room> fetchRooms(
      {@required List<int> tokens, StateStorage stateStorage}) async* {
    for (final token in tokens) {
      final roomPreview = await _fetchRoom(token, stateStorage);
      yield roomPreview;
    }
  }

  Future<Room> _fetchRoom(token, StateStorage stateStorage) async {
    final mutationOptions = QueryOptions(
        fetchPolicy: FetchPolicy.noCache,
        document: Queries.FETCH_ROOM,
        variables: {
          'token': token,
        });

    QueryResult qr = await client.query(mutationOptions);
    if (qr.hasException) {
      String errorMsg =
          'Fetching room with token $token failed with ' + _createErrorMsg(qr);
      developer.log(errorMsg);
      throw (errorMsg);
    }

    RoomState stateFromDatabase = await stateStorage.fetch(token);
    RoomState stateFromBackend =
        RoomStateUtils.parse(qr.data['player']['room']['state'] as String);

    final room = Room.fromGraphQL(qr.data['player']['room'], token);
    room.state = RoomStateUtils.merge(stateFromDatabase, stateFromBackend);
    return room;
  }

  Widget buildRoom(
      {@required BuildContext ctx,
      @required int token,
      @required LoadingBuilder loadingBuilder,
      @required ErrorBuilder errorBuilder,
      @required RoomBuilder builder}) {
    return Query(
      options: _buildFetchRoomOptions(token),
      builder: (QueryResult result,
          {VoidCallback refetch, FetchMore fetchMore}) {
        if (result.hasException)
          return _handleFetchRoomException(ctx, result, errorBuilder);
        if (result.loading) return loadingBuilder(ctx);

        Room room = Room.fromGraphQL(result.data['player']['room'], token);
        return builder(ctx, room);
      },
    );
  }

  QueryOptions _buildFetchRoomOptions(int token) {
    return QueryOptions(
        document: Queries.FETCH_ROOM,
        fetchPolicy: FetchPolicy.noCache,
        variables: {'token': token},
        pollInterval: 5);
  }

  Widget _handleFetchRoomException(
      BuildContext ctx, QueryResult result, ErrorBuilder errorBuilder) {
    String msg = _createErrorMsg(result);
    developer.log('An exception occured $msg');
    return errorBuilder(ctx, result.exception);
  }

  Future<int> leaveRoom(BuildContext ctx, int token) async {
    final TokenStorage storage = Zefir.of(ctx).eurus.storage.token;
    await storage.delete(token);

    final List<int> tokens = await storage.fetchAll();
    return tokens.length;
  }

  // TODO: move to utils
  String _createErrorMsg(QueryResult qr) {
    List<String> errors = [];
    qr.exception.graphqlErrors.forEach((e) {
      if (e != null && e.message != null) {
        errors.add(e.message);
      }
    });

    ClientException clientException = qr.exception.clientException;
    if (clientException != null && clientException.message != null) {
      errors.add(clientException.toString());
    }

    return errors.reduce((acc, val) => acc + val + '\n');
  }
}
