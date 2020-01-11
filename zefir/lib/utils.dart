import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Utils {
  static Object routeArgs(BuildContext ctx) {
    return ModalRoute.of(ctx).settings.arguments;
  }

  static String parseExceptions(QueryResult result) {
    final List<String> errors = result.exception.graphqlErrors
        .toList()
        .map((e) => e.message)
        .toList()
          ..add(result.exception.clientException.message);

    return errors.reduce((acc, val) => acc + val);
  }
}
