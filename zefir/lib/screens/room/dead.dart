import 'package:flutter/material.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/utils.dart';

class DeadScreen extends StatelessWidget {
  static const String appBarTitle = 'Koniec gry';

  const DeadScreen();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: _buildWinner(ctx),
    );
  }

  Widget _buildWinner(BuildContext ctx) {
    final room = (Utils.routeArgs(ctx) as DeadRouteParams).room;
    room.players.sort((p1, p2) => p1.points.compareTo(p2.points));
    final Map<int, List<String>> playersDict = Map();

    room.players.forEach((p) {
      final int key = p.points;
      playersDict[key] == null
          ? playersDict[key] = [p.name]
          : playersDict[key].add(p.name);
    });

    int winnersKey = (playersDict.keys..toList().sort()).last;
    List<String> winners = playersDict[winnersKey];

    Widget w = winners.length > 1
        ? Text('Mamy ${winners.length} zwycięzców')
        : Text('Mamy 1 zwycięzce');

    Widget l = ListView.builder(
      shrinkWrap: true,
      itemCount: room.players.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(room.players[index].name),
          trailing: Text(room.players[index].points.toString()),
        );
      },
    );

    return Column(
      children: [w, l],
    );
  }
}

class DeadRouteParams {
  final Room room;

  DeadRouteParams(this.room);
}
