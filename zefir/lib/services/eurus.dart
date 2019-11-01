import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';

class Eurus {
  ValueNotifier<GraphQLClient> client;

  Eurus({@required Link graphQlEndpoint}) {
    client = ValueNotifier(
        GraphQLClient(cache: InMemoryCache(), link: graphQlEndpoint));
  }
}
