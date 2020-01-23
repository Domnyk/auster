import 'package:flutter/widgets.dart';
import 'package:zefir/screens/room/answering_screen.dart';
import 'package:zefir/screens/room/dead_screen.dart';
import 'package:zefir/screens/room/poll_result_screen.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen.dart';
import 'package:zefir/screens/room/wait_for_other_answers.dart';
import 'package:zefir/screens/room/wait_for_other_questions_screen.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/answering': (ctx) => AnsweringScreen(),
    '/polling': (ctx) => PollingScreen(),
    '/pollResult': (ctx) => PollResultScreen(),
    '/dead': (ctx) => DeadScreen(),
  };
}
