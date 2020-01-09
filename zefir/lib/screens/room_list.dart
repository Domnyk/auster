import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/widgets/room_preview_card.dart';

class RoomList extends StatelessWidget {
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
      body: _buildList(ctx, rooms),
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
          return new RoomPreviewCard(key: ObjectKey(index), room: rooms[index]);
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
