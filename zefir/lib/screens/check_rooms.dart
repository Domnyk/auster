import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/screens/no_rooms.dart';
import 'package:zefir/screens/room_list.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'dart:developer' as developer;

import 'package:zefir/services/storage/token.dart';

class CheckRooms extends StatefulWidget {
  @override
  _CheckRoomsState createState() => _CheckRoomsState();
}

class _CheckRoomsState extends State<CheckRooms> {
  final TokenStorage _storage;
  final List<RoomPreview> _rooms;
  Eurus eurus;

  _CheckRoomsState()
      : _rooms = [],
        _storage = TokenStorage() {
    eurus = new Eurus(
        graphQlEndpoint: new HttpLink(uri: 'https://eurus-13.pl:8000/graphql'));
  }

  @override
  Widget build(BuildContext ctx) {
    return FutureBuilder<List<int>>(
        future: _storage.fetchAll(), builder: _buildFromFuture);
  }

  Widget _buildFromFuture(BuildContext ctx, AsyncSnapshot<List<int>> snapshot) {
    if (snapshot.hasData) {
      developer.log('List of token in DB: ${snapshot.data}',
          name: 'CheckRooms');

      return StreamBuilder<RoomPreview>(
        stream: eurus.fetchRoomsPreview(tokens: snapshot.data),
        builder: _buildFromStream,
      );
    } else {
      return Text('Waiting');
    }
  }

  Widget _buildFromStream(
      BuildContext ctx, AsyncSnapshot<RoomPreview> snapshot) {
    if (snapshot.hasError) {
      return _buildIfError(context, snapshot.error);
    }
    switch (snapshot.connectionState) {
      case ConnectionState.done:
        _handleSnapshotData(snapshot);
        return _buildIfDone(context, this._rooms);
      case ConnectionState.active:
        _handleSnapshotData(snapshot);
        return Text('Waiting with new value ${snapshot.data}');
      case ConnectionState.none:
        return Text('None');
      case ConnectionState.waiting:
        return Text('Waiting');
    }
    return null;
  }

  Widget _buildIfDone(BuildContext ctx, List<RoomPreview> rooms) {
    return rooms.isEmpty
        ? NoRooms(eurus: eurus, storage: _storage)
        : RoomList(rooms: rooms, eurus: eurus, storage: _storage);
  }

  void _handleSnapshotData(AsyncSnapshot<RoomPreview> snapshot) {
    if (snapshot.hasData) {
      developer.log('Received new data: ${snapshot.data}',
          name: 'CheckRooms._handleSnapshotData');
      this._rooms.addAll([snapshot.data]);
    }
  }

  Widget _buildIfError(BuildContext ctx, Exception err) {
    return Text('Wystąpił błąd w czasie pobierania danych');
  }
}
