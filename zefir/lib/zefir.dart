import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/routes.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/zefir_theme.dart';

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
    return GraphQLProvider(
        client: client,
        child: MaterialApp(
            title: 'EGO mobile',
            theme: ZefirTheme().themeData,
            initialRoute: '/',
            routes: Routes.routes));
  }

  final Eurus eurus;

  Zefir()
      : eurus = Eurus(client: client.value),
        super(child: buildMaterialApp(client));

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}