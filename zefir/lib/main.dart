import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zefir/model/user.dart';
import 'package:zefir/screens/check_rooms.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/storage/token.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => new User(),
      child: Zefir(),
    ),
  );
}

class Zefir extends InheritedWidget {
  static final _materialApp = MaterialApp(
    title: 'EGO mobile',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: CheckRoomsWidget(),
  );

  final Eurus eurus;
  final TokenStorage storage;

  static Zefir of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Zefir>();
  }

  Zefir()
      : eurus = Eurus(endpoint: 'https://eurus-13.pl:8000/graphql'),
        storage = TokenStorage(),
        super(child: _materialApp);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
