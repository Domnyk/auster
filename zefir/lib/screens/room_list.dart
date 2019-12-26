import 'package:flutter/material.dart';
import 'package:zefir/model/room_preview.dart';
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
}
