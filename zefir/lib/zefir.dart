import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/question.dart';
import 'package:zefir/routes.dart';
import 'package:zefir/screens/check_rooms_screen.dart';
import 'package:zefir/screens/join_room.dart';
import 'package:zefir/screens/new_room_screen.dart';
import 'package:zefir/screens/no_rooms.dart';
import 'package:zefir/screens/room/add_question_screen.dart';
import 'package:zefir/screens/room/load_question_screen.dart';
import 'package:zefir/screens/room/polling_screen/polling_screen_for_question_owner.dart';
import 'package:zefir/screens/room/wait_for_other_answers.dart';
import 'package:zefir/screens/room/wait_for_other_polls.dart';
import 'package:zefir/screens/room/wait_for_other_questions_screen.dart';
import 'package:zefir/screens/room/wait_for_players_screen.dart';
import 'package:zefir/screens/room_list.dart';
import 'package:zefir/screens/save_questions_screen.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/zefir_theme.dart';

import 'model/room.dart';

class Zefir extends InheritedWidget {
  // static Room room = Room(
  //     RoomState.DEAD,
  //     "Pokój Dominika",
  //     "joinxDCodeXD",
  //     5,
  //     5,
  //     1,
  //     Player(1, 'Dominik', 10),
  //     [Answer(1, 'Tak'), Answer(2, 'Nie'), Answer(3, 'Ne wem')],
  //     Question('Lubisz schabowe', true),
  //     [
  //       Player(1, 'Dominik', 10),
  //       Player(2, 'Damian', 2),
  //       Player(3, 'Dobromir', 5),
  //       Player(4, 'Dorian', 10),
  //     ],
  //     123);

  static ValueNotifier<GraphQLClient> client = ValueNotifier(GraphQLClient(
      cache: InMemoryCache(),
      link: new HttpLink(uri: 'https://eurus-13.pl:8000/graphql')));

  static Zefir of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Zefir>();
  }

  static Widget buildMaterialApp(ValueNotifier<GraphQLClient> client) {
    return MaterialApp(
      title: 'EGO mobile',
      theme: ZefirTheme().themeData,
      onGenerateRoute: generateRoute,
      routes: Routes.routes,
    );
  }

  static MaterialPageRoute generateRoute(RouteSettings settings) {
    Widget Function(BuildContext) builder;

    switch (settings.name) {
      case '/':
        builder = (BuildContext ctx) => CheckRoomsScreen(Zefir.of(ctx).eurus);
        break;
      case '/noRooms':
        builder = (BuildContext ctx) => NoRooms();
        break;
      case '/roomList':
        List<Room> rooms = (settings.arguments as RoomListRouteParams).rooms;
        builder = (BuildContext ctx) => RoomList(rooms);
        break;
      case '/waitForPlayers':
        WaitForPlayersRouteParams params =
            (settings.arguments as WaitForPlayersRouteParams);
        builder = (BuildContext ctx) =>
            WaitForPlayersScreen(params.eurus, params.room);
        break;
      case '/waitForOtherAnswers':
        WaitForOtherAnswersRouteParams params =
            (settings.arguments as WaitForOtherAnswersRouteParams);
        builder = (BuildContext ctx) =>
            WaitForOtherAnswersScreen(Zefir.of(ctx).eurus, params.token);
        break;
      case '/addQuestion':
        AddQuestionRouteParams params =
            (settings.arguments as AddQuestionRouteParams);
        builder = (BuildContext ctx) =>
            AddQuestionScreen(params.token, params.numOfQuestions);
        break;
      case '/loadQuestion':
        LoadQuestionRouteParams params =
            (settings.arguments as LoadQuestionRouteParams);
        builder = (BuildContext ctx) => LoadQuestionScreen(
            params.token, params.numOfQuestionsToChoose, params.questions);
        break;
      case '/waitForOtherQuestions':
        WaitForOtherQuestionsRouteParams params =
            (settings.arguments as WaitForOtherQuestionsRouteParams);
        builder = (BuildContext ctx) =>
            WaitForOtherQuestionsScreen(Zefir.of(ctx).eurus, params.token);
        break;
      case '/newRoom':
        Eurus eurus = (settings.arguments as NewRoomRouteParams).eurus;
        builder = (BuildContext ctx) => NewRoomScreen(eurus);
        break;
      case '/joinRoom':
        Eurus eurus = (settings.arguments as JoinRoomRouteParams).eurus;
        builder = (BuildContext ctx) => JoinRoom(eurus);
        break;
      case '/saveQuestions':
        SaveQuestionsRouteParams params =
            (settings.arguments as SaveQuestionsRouteParams);
        builder = (BuildContext ctx) => SaveQuestionsScreen(params.questions);
        break;
      case '/pollingForQuestionOwner':
        PollingScreenForQuestionOwnerRouteParams params =
            (settings.arguments as PollingScreenForQuestionOwnerRouteParams);
        builder = (BuildContext ctx) =>
            PollingScreenForQuestionOwner(Zefir.of(ctx).eurus, params.room);
        break;
      case '/waitForOtherPolls':
        WaitForPlayersRouteParams params =
            (settings.arguments as WaitForPlayersRouteParams);
        builder = (BuildContext ctx) =>
            WaitForOtherPollsScreen(Zefir.of(ctx).eurus, params.room);
        break;
      default:
        throw Exception('Unkonw route ${settings.name}');
    }

    return builder != null
        ? MaterialPageRoute(builder: builder, settings: settings)
        : null;
  }

  final Eurus eurus = Eurus(client: client.value);

  Zefir()
      : super(
            child: GraphQLProvider(
          client: client,
          child: buildMaterialApp(client),
        ));

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
