import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';
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
    if (qr.hasErrors) {
      throw ('Creating new room failed with ' + _createErrorMsg(qr));
    }

    return qr.data['newRoom']['joinCode'] as String;
  }

  Future<void> joinRoom(
      {@required String roomCode, @required String playerName}) async {
    final mutationOptions = MutationOptions(
        document: Mutations.JOIN_ROOM,
        variables: {'roomCode': roomCode, 'playerName': playerName});

    QueryResult qr = await client.value.mutate(mutationOptions);
    if (qr.hasErrors) {
      String errorMsg = 'Joing room failed with ' + _createErrorMsg(qr);
      developer.log(errorMsg);
      throw (errorMsg);
    }
  }

  String _createErrorMsg(QueryResult qr) {
    return qr.errors
        .toList()
        .map((e) => e.message)
        .reduce((acc, val) => acc + val + '\n');
  }
}
