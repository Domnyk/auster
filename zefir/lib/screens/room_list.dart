import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/screens/join_room.dart';
import 'package:zefir/screens/new_room_screen.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/widgets/room_preview_card.dart';
import 'package:zefir/zefir.dart';

class RoomList extends StatelessWidget {
  static const String _leftRoomConfirmation = 'Opuściłeś pokój';

  final List<Room> _rooms;

  RoomList(this._rooms);

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista pokojów'),
      ),
      body: Builder(
        builder: (context) => _buildList(context, _rooms),
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
                key: ObjectKey(rooms[index].joinCode),
                child: RoomPreviewCard(
                    room: rooms[index], eurus: Zefir.of(ctx).eurus),
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
        onTap: () => Navigator.pushNamed(ctx, '/newRoom',
            arguments: NewRoomRouteParams(Zefir.of(ctx).eurus)));
  }

  SpeedDialChild _buildJoinRoomIcon(BuildContext ctx) {
    return SpeedDialChild(
        child: Icon(Icons.arrow_forward_ios),
        backgroundColor: Colors.black,
        label: 'Dołącz do istniejącego pokoju',
        labelStyle: TextStyle(fontSize: 18.0),
        onTap: () => Navigator.pushNamed(ctx, '/joinRoom',
            arguments: JoinRoomRouteParams(Zefir.of(ctx).eurus)));
  }
}

class RoomListRouteParams {
  final List<Room> rooms;

  RoomListRouteParams(this.rooms);
}
