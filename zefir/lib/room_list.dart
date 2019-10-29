import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoomList extends StatefulWidget {
  @override
  _RoomListState createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  List<int> rooms = new List();

  @override
  Widget build(BuildContext context) {
    Widget body = rooms.isEmpty ? buildBodyIfNoRooms() : buildIfAnyRooms();

    return Scaffold(
        appBar: AppBar(
          title: Text('Lista pokojów, w których się znajdujesz'),
        ),
        body: body);
  }

  Widget buildBodyIfNoRooms() {
    final messageRow = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Obecnie nie znajdujesz się w żadnym pokoju 😕')
        ]);
    final buttonsRow = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('Dołącz do pokoju'),
            onPressed: () => {},
          ),
          RaisedButton(
            child: Text('Załóż pokój'),
            onPressed: () => {},
          )
        ]);

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[messageRow, buttonsRow]);
  }

  Widget buildIfAnyRooms() {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Pokój nr. 1'),
        ),
        ListTile(
          title: Text('Pokój nr. 2'),
        )
      ],
    );
  }
}
