import 'package:flutter/material.dart';
import 'package:zefir/screens/new_room_screen.dart';
import 'package:zefir/zefir.dart';

import 'join_room.dart';

class NoRooms extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: null,
      body: _buildBody(ctx),
      backgroundColor: Colors.blue,
    );
  }

  Widget _buildBody(BuildContext ctx) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[_buildMessage(ctx), _buildButtons(ctx)]);
  }

  Widget _buildMessage(BuildContext ctx) {
    Text text = Text('Obecnie nie znajdujesz się w żadnym pokoju',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: Theme.of(ctx).textTheme.headline.fontSize,
            color: Colors.white));

    return Padding(padding: EdgeInsets.only(bottom: 100), child: text);
  }

  Widget _buildButtons(BuildContext ctx) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _buildJoinRoomButton(ctx),
      _buildCreateRoomButton(ctx),
    ]);
  }

  Widget _buildJoinRoomButton(BuildContext ctx) {
    return RaisedButton(
      child: Text('Dołącz do pokoju'),
      color: Colors.white,
      onPressed: () => Navigator.pushNamed(ctx, '/joinRoom', arguments: JoinRoomRouteParams(Zefir.of(ctx).eurus)),
    );
  }

  Widget _buildCreateRoomButton(BuildContext ctx) {
    return RaisedButton(
      child: Text('Załóż pokój'),
      color: Colors.white,
      onPressed: () => Navigator.pushNamed(ctx, '/newRoom', arguments: NewRoomRouteParams(Zefir.of(ctx).eurus)),
    );
  }
}
