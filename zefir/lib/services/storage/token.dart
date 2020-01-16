import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

import 'package:zefir/model/room_state.dart';

class TokenStorage {
  final Future<Database> _database;

  TokenStorage(this._database);

  Future<List<int>> fetchAll() async {
    Database db = await _database;

    List<int> tokens = (await db.query('rooms'))
        .map((Map<String, dynamic> map) => map['token'] as int)
        .toList();

    developer.log('Tokens fetched from database: $tokens',
        name: 'TokenStorage');
    return tokens;
  }

  Future<void> insert(int token, {RoomState initialState}) async {
    final db = await _database;
    final Map<String, dynamic> map = {
      'token': token,
      'state': initialState.toMyString()
    };
    developer.log('Inserting following map into database: ${map.toString()}',
        name: 'TokenStorage');

    await db.insert('rooms', map);
  }

  Future<void> delete(int token) async {
    final db = await _database;
    await db.delete('rooms', where: 'token = ?', whereArgs: [token]);
  }
}
