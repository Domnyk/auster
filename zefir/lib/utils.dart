import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Utils {
  static Object routeArgs(BuildContext ctx) {
    return ModalRoute.of(ctx).settings.arguments;
  }

  static String parseExceptions(OperationException exception) {
    List<String> errors = [];
    exception.graphqlErrors.forEach((e) {
      if (e != null && e.message != null) {
        errors.add(e.message);
      }
    });

    ClientException clientException = exception.clientException;
    if (clientException != null && clientException.message != null) {
      errors.add(clientException.toString());
    }

    return errors.reduce((acc, val) => acc + val + '\n');
  }
}
