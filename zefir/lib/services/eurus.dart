import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';
import 'dart:developer' as developer;

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
}
