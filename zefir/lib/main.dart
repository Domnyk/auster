import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zefir/model/user.dart';
import 'package:zefir/screens/check_rooms.dart';
import 'package:zefir/screens/join_room.dart';
import 'package:zefir/screens/new_room.dart';
import 'package:zefir/screens/no_rooms.dart';
import 'package:zefir/screens/room/add_question.dart';
import 'package:zefir/screens/room/wait_for_other_questions.dart';
import 'package:zefir/screens/room/wait_for_players.dart';
import 'package:zefir/screens/room_list.dart';
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
  static Map<String, WidgetBuilder> routes = {
    '/': (ctx) => CheckRoomsWidget(),
    '/noRooms': (ctx) => NoRooms(),
    '/roomList': (ctx) => RoomList(),
    '/waitForPlayers': (ctx) => WaitForPlayersScreen(),
    '/addQuestion': (ctx) => AddQuestionScreen(),
    '/waitForOtherQuestions': (ctx) => WaitForOtherQuestionsScreen(),
    '/answering': (ctx) =>
        throw Exception('AnsweringScreen is not yet implemented'),
    '/waitForOtherAnswers': (ctx) =>
        throw Exception('WaitForOtherAnswersScreen is not yet implemented'),
    '/polling': (ctx) =>
        throw Exception('PollingScreen is not yet implemented'),
    '/waitForPoll': (ctx) =>
        throw Exception('WaitForPollScreen is not yet implemented'),
    '/pollResult': (ctx) =>
        throw Exception('PollResultScreen is not yet implemented'),
    '/endGame': (ctx) =>
        throw Exception('endGameScreen is not yet implemented'),
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
            theme: ThemeData(primarySwatch: Colors.blue),
            initialRoute: '/',
            routes: routes));
  }

  final Eurus eurus;
  final TokenStorage storage;

  Zefir()
      : eurus = Eurus(client: client),
        storage = TokenStorage(),
        super(child: buildMaterialApp(client));

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
