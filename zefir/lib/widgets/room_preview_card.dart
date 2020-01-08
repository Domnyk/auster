import 'package:flutter/material.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/model/room_state.dart';

class RoomPreviewCard extends StatelessWidget {
  final RoomPreview _room;

  RoomPreviewCard({Key key, @required RoomPreview room})
      : _room = room,
        super(key: key);

  @override
  Widget build(BuildContext ctx) {
    Row row = Row(
      children: <Widget>[
        Expanded(child: _buildShortRoomDescription(ctx), flex: 8),
        Expanded(child: _buildMoreAcctionsColumn(ctx), flex: 2),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );

    Padding paddedRow = Padding(
      padding: EdgeInsets.all(10),
      child: row,
    );

    return Card(
      child: InkWell(
        child: paddedRow,
        onTap: () => {},
      ),
      margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
    );
  }

  Widget _buildMoreAcctionsColumn(BuildContext ctx) {
    FlatButton btn = FlatButton(
      child: Icon(Icons.more_vert),
      onPressed: () => showDialog(
          context: ctx, builder: (context) => _buildMoreActionsDialog(context)),
    );

    return Column(children: [btn]);
  }

  Widget _buildMoreActionsDialog(BuildContext ctx) {
    Widget closeButton = FlatButton(
      child: Text('Zamknij'),
      onPressed: () => Navigator.pop(ctx),
    );

    return AlertDialog(
      title: Text('Dostępne akcje'),
      content: Text('Opuść pokój'),
      actions: <Widget>[closeButton],
    );
  }

  Widget _buildShortRoomDescription(BuildContext ctx) {
    return Column(
      children: [
        _buildRoomTitle(ctx, _room.name),
        _buildGameState(ctx, _room.state)
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget _buildRoomTitle(BuildContext ctx, String roomTitle) {
    return Text(
      roomTitle,
      style: TextStyle(fontSize: Theme.of(ctx).textTheme.headline.fontSize),
    );
  }

  Widget _buildGameState(BuildContext ctx, RoomState state) {
    Text text = Text(
      'Stan gry: ${_describeRoomState(state)}',
      style: TextStyle(fontSize: Theme.of(ctx).textTheme.body1.fontSize),
    );

    return Padding(
      padding: EdgeInsets.only(left: 5),
      child: text,
    );
  }

  String _describeRoomState(final RoomState state) {
    switch (state) {
      case RoomState.JOINING:
        return 'oczekiwanie na graczy';
      case RoomState.COLLECTING:
        return 'dodawanie pytań';
      case RoomState.ANSWERING:
        return 'dodawanie odpowiedzi na pytanie';
      case RoomState.POLLING:
        return 'odpowiadanie na pytanie';
      case RoomState.DEAD:
        return 'koniec gry';
      default:
        throw ArgumentError('Unknown state ${state.toString()}');
    }
  }
}
