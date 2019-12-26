import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/screens/no_rooms.dart';
import 'package:zefir/screens/room_list.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'dart:developer' as developer;

class CheckRooms extends StatefulWidget {
  @override
  _CheckRoomsState createState() => _CheckRoomsState();
}

class _CheckRoomsState extends State<CheckRooms> {
  final List<RoomPreview> _rooms;
  Eurus eurus;

  _CheckRoomsState() : _rooms = [] {
    eurus = new Eurus(
        graphQlEndpoint: new HttpLink(uri: 'https://eurus-13.pl:8000/graphql'));
  }

  @override
  Widget build(BuildContext ctx) {
    return StreamBuilder<RoomPreview>(
      stream: eurus.fetchRoomsPreview(tokens: []),
      builder: _buildFromStream,
    );
  }

  Widget _buildFromStream(
      BuildContext ctx, AsyncSnapshot<RoomPreview> snapshot) {
    if (snapshot.hasError) {
      return _buildIfError(context, snapshot.error);
    }
    switch (snapshot.connectionState) {
      case ConnectionState.done:
        handleSnapshotData(snapshot);
        return _buildIfDone(context, this._rooms);
      case ConnectionState.active:
        handleSnapshotData(snapshot);
        return Text('Waiting with new value ${snapshot.data}');
      case ConnectionState.none:
        return Text('None');
      case ConnectionState.waiting:
        return Text('Waiting');
    }
    return null;
  }

  Widget _buildIfDone(BuildContext ctx, List<RoomPreview> rooms) {
    return rooms.isEmpty ? NoRooms(eurus: eurus) : RoomList(rooms: rooms);
  }

  void handleSnapshotData(AsyncSnapshot<RoomPreview> snapshot) {
    if (snapshot.hasData) {
      developer.log('Received new data: ${snapshot.data}');
      this._rooms.addAll([snapshot.data]);
    }
  }

  Widget _buildIfError(BuildContext ctx, Exception err) {
    return Text('Wystąpił błąd w czasie pobierania danych');
  }
}
