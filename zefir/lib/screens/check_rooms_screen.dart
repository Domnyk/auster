import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/screens/loading.dart';
import 'package:zefir/screens/no_rooms.dart';
import 'package:zefir/screens/room_list.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/zefir.dart';
import 'dart:developer' as developer;

class CheckRoomsScreen extends StatelessWidget {
  final Eurus _eurus;

  const CheckRoomsScreen(this._eurus);

  @override
  Widget build(BuildContext ctx) {
    return FutureBuilder<List<int>>(
        key: UniqueKey(),
        future: _eurus.storage.token.fetchAll(),
        builder: _buildFromFuture);
  }

  Widget _buildFromFuture(
      BuildContext ctx, AsyncSnapshot<List<int>> snapshot) {
    if (snapshot.hasData) {
      final List<Room> rooms = [];

      return StreamBuilder<Room>(
        stream: _eurus.fetchRooms(
            tokens: snapshot.data,
            stateStorage: Zefir.of(ctx).eurus.storage.state),
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
    return rooms.isEmpty ? NoRooms() : RoomList(rooms);
  }

  Widget _buildIfError(BuildContext ctx, Exception err) {
    return Text('Wystąpił błąd w czasie pobierania danych');
  }
}

class CheckRoomsRouteParams {
  final Eurus eurus;

  CheckRoomsRouteParams(this.eurus);
}
