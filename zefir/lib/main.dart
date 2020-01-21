import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zefir/model/user.dart';
import 'package:zefir/zefir.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => new User(),
      child: Zefir(),
    ),
  );
}