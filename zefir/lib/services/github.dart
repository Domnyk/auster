import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Github {

  ValueNotifier<GraphQLClient> client;

  Github() {
    print('This is Github GraphQL test');

    final HttpLink httpLink = HttpLink(uri: 'https://api.github.com/graphql');
    final AuthLink authLink = AuthLink(
        getToken: () async => 'BEARER f4eb44c1234af230573543cb03b7718c1012806e'
    );
    final Link link = authLink.concat(httpLink);

    client = ValueNotifier(GraphQLClient(
     cache: InMemoryCache(),
     link: link
    ));
  }
}