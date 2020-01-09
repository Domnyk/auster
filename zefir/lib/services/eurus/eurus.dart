import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/services/eurus/exceptions/no_such_room_exception.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/services/storage/token.dart';
import 'package:zefir/typedefs.dart';
import 'dart:developer' as developer;
import 'mutations.dart';

class Eurus {
  ValueNotifier<GraphQLClient> client;

  Eurus({@required ValueNotifier<GraphQLClient> client}) : client = client;

  Future<Room> createNewRoom(TokenStorage storage,
      {@required String roomName,
      @required String playerName,
      @required int numOfPlayers,
      @required int numOfRounds}) async {
    String joinCode = await _createNewRoomWithoutJoining(
        name: roomName, numOfPlayers: numOfPlayers, numOfRounds: numOfRounds);
    Room room = await joinRoom(roomCode: joinCode, playerName: playerName);
    storage.insert(room.deviceToken);
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

    QueryResult qr = await client.value.mutate(mutationOptions);
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

    QueryResult qr = await client.value.mutate(mutationOptions);
    if (qr.hasException) {
      throw NoSuchRoomException(roomCode);
    }

    int token = qr.data['joinRoom']['token'] as int;
    Room room = Room.fromGraphQL(qr.data['joinRoom']['room'], token);

    developer.log(
        'Successfully joined room using room code $roomCode. Received token $token',
        name: 'eurus.joinRoom');
    return room;
  }

  Stream<Room> fetchRooms({@required List<int> tokens}) async* {
    for (final token in tokens) {
      final roomPreview = await _fetchRoom(token);
      developer.log('Received room preview: $roomPreview',
          name: 'eurus.fetchRoomsPreview');
      yield roomPreview;
    }
  }

  Future<Room> _fetchRoom(token) async {
    final mutationOptions =
        MutationOptions(document: Queries.FETCH_ROOM, variables: {
      'token': token,
    });

    QueryResult qr = await client.value.mutate(mutationOptions);
    if (qr.hasException) {
      String errorMsg =
          'Fetching room with token $token failed with ' + _createErrorMsg(qr);
      developer.log(errorMsg);
      throw (errorMsg);
    }

    return Room.fromGraphQL(qr.data['player']['room'], token);
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
        variables: {'token': token},
        pollInterval: 5);
  }

  Widget _handleFetchRoomException(
      BuildContext ctx, QueryResult result, ErrorBuilder errorBuilder) {
    String msg = _createErrorMsg(result);
    developer.log('An exception occured $msg');
    return errorBuilder(context: ctx, exception: result.exception);
  }

  Future<void> leaveRoom(BuildContext ctx, int token) async {
    final TokenStorage storage = Zefir.of(ctx).storage;
    await storage.delete(token);
  }

  String _createErrorMsg(QueryResult qr) {
    return qr.exception.graphqlErrors
        .toList()
        .map((e) => e.message)
        .reduce((acc, val) => acc + val + '\n');
  }
}
