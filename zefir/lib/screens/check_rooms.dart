import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zefir/main.dart';
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
    final TokenStorage _storage = Zefir.of(ctx).storage;

    return FutureBuilder<List<int>>(
        future: _storage.fetchAll(),
        builder: (ctx, snapshot) => _buildFromFuture(ctx, snapshot, _eurus));
  }

  Widget _buildFromFuture(
      BuildContext ctx, AsyncSnapshot<List<int>> snapshot, final Eurus eurus) {
    if (snapshot.hasData) {
      final List<RoomPreview> rooms = [];

      return StreamBuilder<RoomPreview>(
        stream: eurus.fetchRoomsPreview(tokens: snapshot.data),
        builder: (ctx, snapshot) => _buildFromStream(ctx, snapshot, rooms),
      );
    } else {
      return LoadingWidget();
    }
  }

  Widget _buildFromStream(BuildContext ctx, AsyncSnapshot<RoomPreview> snapshot,
      final List<RoomPreview> rooms) {
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

  Widget _buildIfDone(BuildContext ctx, List<RoomPreview> rooms) {
    return rooms.isEmpty ? NoRooms() : RoomList(rooms: rooms);
  }

  Widget _buildIfError(BuildContext ctx, Exception err) {
    return Text('Wystąpił błąd w czasie pobierania danych');
  }
}
