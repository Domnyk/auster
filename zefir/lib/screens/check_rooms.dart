import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_preview.dart';
import 'package:zefir/screens/loading.dart';
import 'package:zefir/screens/no_rooms.dart';
import 'package:zefir/screens/room_list.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/storage/token.dart';
import 'dart:developer' as developer;

class CheckRoomsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    final Eurus _eurus = Zefir.of(ctx).eurus;
    final TokenStorage _storage = Zefir.of(ctx).storage.token;

    return FutureBuilder<List<int>>(
        key: UniqueKey(),
        future: _storage.fetchAll(),
        builder: (ctx, snapshot) => _buildFromFuture(ctx, snapshot, _eurus));
  }

  Widget _buildFromFuture(
      BuildContext ctx, AsyncSnapshot<List<int>> snapshot, final Eurus eurus) {
    if (snapshot.hasData) {
      final List<Room> rooms = [];

      return StreamBuilder<Room>(
        stream: eurus.fetchRooms(
            tokens: snapshot.data, stateStorage: Zefir.of(ctx).storage.state),
        builder: (ctx, snapshot) => _buildFromStream(ctx, snapshot, rooms),
      );
    } else {
      return LoadingWidget();
    }
  }

  Widget _buildFromStream(
      BuildContext ctx, AsyncSnapshot<Room> snapshot, final List<Room> rooms) {
    if (snapshot.hasError) {
      return _buildIfError(ctx, snapshot.error);
    }
    switch (snapshot.connectionState) {
      case ConnectionState.done:
        if (snapshot.hasData) rooms.add(snapshot.data);
        return _buildIfDone(ctx, rooms);
      case ConnectionState.active:
        if (snapshot.hasData) rooms.add(snapshot.data);
        return LoadingWidget();
      case ConnectionState.none:
        return Text('None'); // TODO: Error widget ?
      case ConnectionState.waiting:
        return LoadingWidget();
    }
    return null;
  }

  Widget _buildIfDone(BuildContext ctx, List<Room> rooms) {
    return rooms.isEmpty ? NoRooms() : RoomList(rooms: rooms);
  }

  Widget _buildIfError(BuildContext ctx, Exception err) {
    return Text('Wystąpił błąd w czasie pobierania danych');
  }
}
