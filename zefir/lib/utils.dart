import 'package:flutter/material.dart';

class Utils {
  static Object routeArgs(BuildContext ctx) {
    return ModalRoute.of(ctx).settings.arguments;
  }
}
