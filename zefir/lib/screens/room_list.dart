import 'package:flutter/material.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/screens/join_room.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToJoinRoomScreen(ctx),
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

  void _navigateToJoinRoomScreen(BuildContext ctx) {
    Navigator.push(
        ctx, MaterialPageRoute(builder: (BuildContext context) => JoinRoom()));
  }
}
