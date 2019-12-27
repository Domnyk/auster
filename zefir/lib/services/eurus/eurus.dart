import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/model/room_preview.dart' as prefix0;
import 'package:zefir/services/eurus/exceptions/no_such_room_exception.dart';
import 'dart:developer' as developer;
import 'mutations.dart';

class Eurus {
  ValueNotifier<GraphQLClient> client;

  Eurus({@required Link graphQlEndpoint}) {
    client = ValueNotifier(
        GraphQLClient(cache: InMemoryCache(), link: graphQlEndpoint));
  }

  Future<void> createNewRoom(
      {@required String roomName,
      @required String playerName,
      @required int numOfPlayers,
      @required int numOfRounds}) async {
    String joinCode = await _createNewRoomWithoutJoining(
        name: roomName, numOfPlayers: numOfPlayers, numOfRounds: numOfRounds);
    joinRoom(roomCode: joinCode, playerName: playerName);
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

  Future<int> joinRoom(
      {@required String roomCode, @required String playerName}) async {
    final mutationOptions = MutationOptions(
        document: Mutations.JOIN_ROOM,
        variables: {'roomCode': roomCode, 'playerName': playerName});

    QueryResult qr = await client.value.mutate(mutationOptions);
    if (qr.hasException) {
      String errorMsg =
          'Joing room using code $roomCode failed with ' + _createErrorMsg(qr);
      developer.log(errorMsg);
      // throw (errorMsg);
      throw NoSuchRoomException(roomCode);
    }

    int token = qr.data['joinRoom']['token'] as int;
    developer.log(
        'Successfully joined room using room code $roomCode. Received token $token',
        name: 'eurus.joinRoom');
    return token;
  }

  Stream<RoomPreview> fetchRoomsPreview({@required List<int> tokens}) async* {
    for (final token in tokens) {
      final roomPreview = await _fetchRoom(token);
      developer.log('Received room preview: $roomPreview',
          name: 'eurus.fetchRoomsPreview');
      yield roomPreview;
    }
  }

  Future<RoomPreview> _fetchRoom(token) async {
    final mutationOptions =
        MutationOptions(document: Mutations.FETCH_ROOM_PREVIEW, variables: {
      'token': token,
    });

    QueryResult qr = await client.value.mutate(mutationOptions);
    if (qr.hasException) {
      String errorMsg =
          'Fetching room with token $token failed with ' + _createErrorMsg(qr);
      developer.log(errorMsg);
      throw (errorMsg);
    }

    RoomPreview roomPreview =
        RoomPreview.parse(qr.data['player']['room'] as Map<String, dynamic>);
    developer.log(
        'Successfully fetched room preview with following data $roomPreview',
        name: 'eurus._fetchRoom');
    return roomPreview;
  }

  String _createErrorMsg(QueryResult qr) {
    return qr.exception.graphqlErrors
        .toList()
        .map((e) => e.message)
        .reduce((acc, val) => acc + val + '\n');
  }
}
