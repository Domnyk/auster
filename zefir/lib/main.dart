import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zefir/model/user.dart';
import 'package:zefir/screens/check_rooms.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => new User(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EGO mobile',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CheckRooms(),
    );
  }
}
