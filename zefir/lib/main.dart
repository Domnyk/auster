import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql/src/link/fetch_result.dart';
import 'package:graphql/src/link/operation.dart';
import 'package:provider/provider.dart';
import 'package:zefir/model/answer.dart';
import 'package:zefir/model/user.dart';
import 'package:zefir/screens/check_rooms.dart';
import 'package:zefir/screens/join_room.dart';
import 'package:zefir/screens/new_room.dart';
import 'package:zefir/screens/no_rooms.dart';
import 'package:zefir/screens/room/add_question.dart';
import 'package:zefir/screens/room/answering_screen.dart';
import 'package:zefir/screens/room/dead.dart';
import 'package:zefir/screens/room/poll_result.dart';
import 'package:zefir/screens/room/polling/polling_screen.dart';
import 'package:zefir/screens/room/wait_for_other_answers.dart';
import 'package:zefir/screens/room/wait_for_other_polls.dart';
import 'package:zefir/screens/room/wait_for_other_questions/wait_for_other_questions_screen.dart';
import 'package:zefir/screens/room/wait_for_players.dart';
import 'package:zefir/screens/room_list.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/storage/storage.dart';
import 'package:zefir/zefir_theme.dart';
import 'dart:developer' as developer;

import 'model/player.dart';
import 'model/question.dart';
import 'model/room.dart';
import 'model/room_state.dart';

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
  static Room room = Room(
      RoomState.DEAD,
      "Pokój Dominika",
      "joinxDCodeXD",
      5,
      5,
      1,
      Player(1, 'Dominik', 10),
      [Answer(1, 'Tak'), Answer(2, 'Nie'), Answer(3, 'Ne wem')],
      Question('Lubisz schabowe', true),
      [
        Player(1, 'Dominik', 10),
        Player(2, 'Damian', 2),
        Player(3, 'Dobromir', 5),
        Player(4, 'Dorian', 10),
      ],
      123);

  static Map<String, WidgetBuilder> routes = {
    '/': (ctx) => CheckRoomsWidget(),
    '/noRooms': (ctx) => NoRooms(),
    '/roomList': (ctx) => RoomList(),
    '/waitForPlayers': (ctx) => WaitForPlayersScreen(),
    '/addQuestion': (ctx) => AddQuestionScreen(),
    '/waitForOtherQuestions': (ctx) => WaitForOtherQuestionsScreen(),
    '/answering': (ctx) => AnsweringScreen(),
    '/waitForOtherAnswers': (ctx) => WaitForOtherAnswersScreen(),
    '/polling': (ctx) => PollignScreen(),
    '/waitForOtherPolls': (ctx) => WaitForOtherPollsScreen(),
    '/pollResult': (ctx) => PollResultScreen(),
    '/dead': (ctx) => DeadScreen(),
    '/newRoom': (ctx) => NewRoom(),
    '/joinRoom': (ctx) => JoinRoom(),
  };

  static ValueNotifier<GraphQLClient> client = ValueNotifier(GraphQLClient(
      cache: InMemoryCache(),
      link: new HttpLink(uri: 'https://eurus-13.pl:8000/graphql')));

  static Zefir of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Zefir>();
  }

  static Widget buildMaterialApp(ValueNotifier<GraphQLClient> client) {
    return GraphQLProvider(
        client: client,
        child: MaterialApp(
            title: 'EGO mobile',
            // theme: ThemeData(primarySwatch: Colors.blue),
            theme: ZefirTheme().themeData,
            initialRoute: '/',
            routes: routes));
  }

  final Eurus eurus;
  final Storage storage;

  Zefir()
      : eurus = Eurus(client: client),
        storage = Storage(client.value),
        super(child: buildMaterialApp(client));

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
