import 'package:flutter/material.dart';

class ZefirTheme {
  final ThemeData _themeData;

  ThemeData get themeData => _themeData;

  ZefirTheme()
      : _themeData = ThemeData(
            inputDecorationTheme:
                InputDecorationTheme(border: OutlineInputBorder()));
}
