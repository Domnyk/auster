import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Utils {
  static Object routeArgs(BuildContext ctx) {
    return ModalRoute.of(ctx).settings.arguments;
  }

  static String parseExceptions(OperationException exception) {
    final List<String> errors = exception.graphqlErrors
        .toList()
        .map((e) => e.message)
        .toList()
          ..add(exception.clientException.message);

    return errors.reduce((acc, val) => acc + val);
  }
}
