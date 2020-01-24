import 'package:flutter/material.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/answering_screen.dart';
import 'package:zefir/services/storage/state.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/zefir.dart';

class PollResultScreen extends StatelessWidget {
  static const String appBarTitle = 'Wyniki głosowania';

  const PollResultScreen();

  @override
  Widget build(BuildContext ctx) {
    final Room room = (Utils.routeArgs(ctx) as PollResultRouteParams).room;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            itemCount: room.players.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildListItem(ctx, room.players[index]);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('Następne pytanie'),
              onPressed: () async {
                await _navigateToNextQuestion(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext ctx, Player player) {
    return Column(children: [
      Padding(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                player.name,
                style: Theme.of(ctx).textTheme.headline,
              ),
              Text(
                player.points.toString(),
                style: Theme.of(ctx).textTheme.headline,
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 40, 10)),
      Divider(height: 5, color: Colors.grey),
    ]);
  }

  Future<void> _navigateToNextQuestion(BuildContext ctx) {
    final Room room = (Utils.routeArgs(ctx) as PollResultRouteParams).room;
    final StateStorage storage = Zefir.of(ctx).eurus.storage.state;

    return storage.update(room.deviceToken, RoomState.ANSWERING).then((_) =>
        Navigator.of(ctx).pushReplacementNamed('/answering',
            arguments: AnsweringRouteParams(room.deviceToken)));
  }
}

class PollResultRouteParams {
  final Room room;

  PollResultRouteParams(this.room);
}
