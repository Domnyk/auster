import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/screens/join_room.dart';
import 'package:zefir/screens/new_room.dart';
import 'package:zefir/widgets/room_preview_widget.dart';

class RoomList extends StatelessWidget {
  final List<RoomPreview> _rooms;

  RoomList({@required List<RoomPreview> rooms}) : _rooms = rooms;

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista pokojów, w których sie znajdujesz'),
      ),
      body: _buildList(ctx, this._rooms),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.menu),
        children: [_buildJoinRoomIcon(ctx), _buildNewRoomIcon(ctx)],
      ),
    );
  }

  Widget _buildList(BuildContext ctx, List<RoomPreview> rooms) {
    return ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return new RoomPreviewWidget(
              key: ObjectKey(index), room: rooms[index]);
        });
  }

  SpeedDialChild _buildJoinRoomIcon(BuildContext ctx) {
    return SpeedDialChild(
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
        label: 'Załóż nowy pokój',
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (BuildContext context) => NewRoom())));
  }

  SpeedDialChild _buildNewRoomIcon(BuildContext ctx) {
    return SpeedDialChild(
        child: Icon(Icons.arrow_forward_ios),
        backgroundColor: Colors.black,
        label: 'Dołącz do istniejącego pokoju',
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (BuildContext context) => JoinRoom())));
  }
}
