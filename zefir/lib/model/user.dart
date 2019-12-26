import 'dart:collection';
import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  final List<int> _tokens = [];

  UnmodifiableListView<int> get tokens => UnmodifiableListView(_tokens);

  void addToken(int token) {
    _tokens.add(token);

    notifyListeners();
  }
}
