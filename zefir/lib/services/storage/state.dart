import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

import 'package:zefir/model/room_state.dart';

class StateStorage {
  final Future<Database> _database;

  StateStorage(this._database);

  Future<RoomState> fetch(int token) async {
    final Database db = await _database;

    String rawState = (await db.query('rooms'))
        .map((Map<String, dynamic> map) => map['state'] as String)
        .toList()
        .first;

    RoomState state = RoomStateParser.parse(rawState);

    developer.log(
        'State fetched from database for $token: ${state.toMyString()}',
        name: 'StateStorage');
    return state;
  }

  Future<void> insert(int token, RoomState state) async {
    final Database db = await _database;

    final Map<String, dynamic> map = {
      'token': token,
      'state': state.toMyString()
    };
    developer.log('Inserting following map into database: ${map.toString()}',
        name: 'StateStorage');

    await db.insert('rooms', map);
  }

  Future<void> update(int token, RoomState newState) async {
    final Database db = await _database;

    final Map<String, dynamic> map = {
      'token': token,
      'state': newState.toMyString(),
    };
    developer.log(
        'Updating state of a room with token $token to following: ${newState.toString()}',
        name: 'StateStorage');

    await db.update('rooms', map, where: "token = ?", whereArgs: [token]);
  }
}
