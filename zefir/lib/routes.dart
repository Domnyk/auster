import 'package:flutter/widgets.dart';
import 'package:zefir/screens/check_rooms.dart';
import 'package:zefir/screens/join_room.dart';
import 'package:zefir/screens/new_room.dart';
import 'package:zefir/screens/room/add_question_screen.dart';
import 'package:zefir/screens/room/answering_screen.dart';
import 'package:zefir/screens/room/dead_screen.dart';
import 'package:zefir/screens/room/poll_result_screen.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen_for_question_owner.dart';
import 'package:zefir/screens/room/wait_for_other_answers.dart';
import 'package:zefir/screens/room/wait_for_other_polls.dart';
import 'package:zefir/screens/room/wait_for_other_questions_screen.dart';
import 'package:zefir/screens/room/wait_for_players_screen.dart';
import 'package:zefir/screens/room_list.dart';

import 'screens/no_rooms.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (ctx) => CheckRoomsWidget(),
    '/noRooms': (ctx) => NoRooms(),
    '/roomList': (ctx) => RoomList(),
    '/waitForPlayers': (ctx) => WaitForPlayersScreen(),
    '/addQuestion': (ctx) => AddQuestionScreen(),
    '/waitForOtherQuestions': (ctx) => WaitForOtherQuestionsScreen(),
    '/answering': (ctx) => AnsweringScreen(),
    '/waitForOtherAnswers': (ctx) => WaitForOtherAnswersScreen(),
    '/polling': (ctx) => PollingScreen(),
    '/pollingForQuestionOwner': (ctx) => PollingScreenForQuestionOwner(),
    '/waitForOtherPolls': (ctx) => WaitForOtherPollsScreen(),
    '/pollResult': (ctx) => PollResultScreen(),
    '/dead': (ctx) => DeadScreen(),
    '/newRoom': (ctx) => NewRoom(),
    '/joinRoom': (ctx) => JoinRoom(),
  };
}