import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/screens/join_room.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/screens/new_room.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'dart:developer' as developer;

class RoomList extends StatefulWidget {
  @override
  _RoomListState createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  List<int> rooms;
  Eurus eurus;

  _RoomListState() {
    rooms = new List();
    eurus = new Eurus(
        graphQlEndpoint: new HttpLink(uri: 'https://eurus-13.pl:8000/graphql'));
  }

  @override
  Widget build(BuildContext context) {
    String readUsers = """
      query {
        users {
          name
        }
      }
    """;

    return Scaffold(
        appBar: AppBar(title: Text('Lista pokojów, w których się znajdujesz')),
        body: GraphQLProvider(
            client: eurus.client,
            child: Query(
                options: QueryOptions(document: readUsers, pollInterval: 10),
                builder: (QueryResult result,
                    {VoidCallback refetch, FetchMore fetchMore}) {
                  List rooms = new List<Room>(); // result.data['users'];

                  return rooms.isEmpty
                      ? buildBodyIfNoRooms(eurus: eurus)
                      : buildIfAnyRooms(rooms);
                })));
  }

  Widget buildBodyIfNoRooms({@required Eurus eurus}) {
    final messageRow =
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Text(
        'Obecnie nie znajdujesz się w żadnym pokoju 😕',
      )
    ]);
    final buttonsRow = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('Dołącz do pokoju'),
            onPressed: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => JoinRoom(eurus)))
            },
          ),
          RaisedButton(
            child: Text('Załóż pokój'),
            onPressed: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewRoom(eurus)))
            },
          )
        ]);

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[messageRow, buttonsRow]);
  }

  Widget buildIfAnyRooms(List<Room> rooms) {
    return ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          Room room = rooms[index];
          return ListTile(
            title: Text(room.name),
            onTap: () => developer.log('Button was clicked'),
          );
        });
  }
}
