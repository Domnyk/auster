import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';
import 'dart:developer' as developer;
import 'mutations.dart';

class Eurus {
  static final String _createNewRoom = """
    mutation newRoom(\$name: String!, \$players: Int!) {
      newRoom(name: \$name, players: \$players) {
        name,

      }
    }
  """;

  ValueNotifier<GraphQLClient> client;

  Eurus({@required Link graphQlEndpoint}) {
    client = ValueNotifier(
        GraphQLClient(cache: InMemoryCache(), link: graphQlEndpoint));
  }

  void createNewRoom(
      {@required String name, @required int numOfPlayers}) async {
    QueryResult result = await client.value.mutate(MutationOptions(
        document: _createNewRoom,
        variables: {'name': name, 'players': numOfPlayers}));

    developer.log('Result from GraphQL is ${result.data}');
  }

  Future<bool> joinRoom(
      {@required String roomCode, @required String playerName}) {
    final mutationOptions = MutationOptions(
        document: Mutations.JOIN_ROOM,
        variables: {'roomCode': roomCode, 'playerName': playerName});
    final processResults = (QueryResult qr) {
      if (qr.hasErrors) {
        developer.log('Following errors has occured:');
        qr.errors
            .toList()
            .forEach((GraphQLError e) => {developer.log(e.message)});

        return false;
      }
      return true;
    };

    return client.value.mutate(mutationOptions).then(processResults);
  }
}
