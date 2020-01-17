import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/widgets/room_preview_card.dart';

class RoomList extends StatelessWidget {
  static const String _leftRoomConfirmation = 'Opuściłeś pokój';

  final List<Room> _rooms;

  RoomList({List<Room> rooms}) : _rooms = rooms;

  List<Room> getRooms(BuildContext ctx) {
    return this._rooms != null
        ? this._rooms
        : (Utils.routeArgs(ctx) as _RoomListRouteParams).rooms;
  }

  @override
  Widget build(BuildContext ctx) {
    final List<Room> rooms = getRooms(ctx);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista pokojów, w których sie znajdujesz'),
      ),
      body: Builder(
        builder: (context) => _buildList(context, rooms),
      ),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.menu),
        children: [_buildJoinRoomIcon(ctx), _buildNewRoomIcon(ctx)],
      ),
    );
  }

  Widget _buildList(BuildContext ctx, List<Room> rooms) {
    return ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Dismissible(
                background: Container(color: Colors.red),
                key: ObjectKey(index),
                child: RoomPreviewCard(room: rooms[index]),
                onDismissed: (DismissDirection direction) {
                  Zefir.of(ctx)
                      .eurus
                      .leaveRoom(ctx, rooms[index].deviceToken)
                      .then((_) => Scaffold.of(ctx).showSnackBar(
                          SnackBar(content: Text(_leftRoomConfirmation))));
                },
              ),
            ],
          );
        });
  }

  SpeedDialChild _buildNewRoomIcon(BuildContext ctx) {
    return SpeedDialChild(
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
        label: 'Załóż nowy pokój',
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () => Navigator.pushNamed(ctx, '/newRoom'));
  }

  SpeedDialChild _buildJoinRoomIcon(BuildContext ctx) {
    return SpeedDialChild(
        child: Icon(Icons.arrow_forward_ios),
        backgroundColor: Colors.black,
        label: 'Dołącz do istniejącego pokoju',
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () => Navigator.pushNamed(ctx, '/joinRoom'));
  }
}

class _RoomListRouteParams {
  final List<Room> rooms;

  _RoomListRouteParams(this.rooms);
}
