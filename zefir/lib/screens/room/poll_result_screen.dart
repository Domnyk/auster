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
    final StateStorage storage = Zefir.of(ctx).eurus.storage.state;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Następne pytanie'),
        onPressed: () => storage
            .update(room.deviceToken, RoomState.ANSWERING)
            .then((_) => Navigator.of(ctx).pushReplacementNamed('/answering',
                arguments: AnsweringRouteParams(room.deviceToken))),
      ),
      appBar: AppBar(
        title: _buildHeadline(ctx, room),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: room.players.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildListItem(ctx, room.players[index]);
        },
      ),
    );
  }

  Widget _buildHeadline(BuildContext ctx, Room room) {
    String msg = 'Tabela wyników po rundzie ${room.currRound + 1}.';

    return Text(msg,
        style: TextStyle(
            fontSize: Theme.of(ctx).textTheme.headline.fontSize,
            color: Colors.white));
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
}

class PollResultRouteParams {
  final Room room;

  PollResultRouteParams(this.room);
}
