import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/screens/no_rooms.dart';
import 'package:zefir/screens/room_list.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'dart:developer' as developer;

import 'package:zefir/services/storage/token.dart';

class CheckRoomsWidget extends StatefulWidget {
  @override
  _CheckRoomsWidgetState createState() => _CheckRoomsWidgetState();
}

class _CheckRoomsWidgetState extends State<CheckRoomsWidget> {
  final List<RoomPreview> _rooms;

  TokenStorage _storage;
  Eurus _eurus;

  _CheckRoomsWidgetState() : _rooms = [];

  @override
  Widget build(BuildContext ctx) {
    _eurus = Zefir.of(ctx).eurus;
    _storage = Zefir.of(ctx).storage;

    return FutureBuilder<List<int>>(
        future: _storage.fetchAll(), builder: _buildFromFuture);
  }

  Widget _buildFromFuture(BuildContext ctx, AsyncSnapshot<List<int>> snapshot) {
    if (snapshot.hasData) {
      developer.log('List of token in DB: ${snapshot.data}',
          name: 'CheckRooms');

      return StreamBuilder<RoomPreview>(
        stream: _eurus.fetchRoomsPreview(tokens: snapshot.data),
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
    return rooms.isEmpty ? NoRooms() : RoomList(rooms: _rooms);
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
