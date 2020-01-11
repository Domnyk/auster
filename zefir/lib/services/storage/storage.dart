import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zefir/services/storage/SQLs.dart';
import 'package:zefir/services/storage/state.dart';
import 'dart:developer' as developer;

import 'package:zefir/services/storage/token.dart';

class Storage {
  static String databaseFile = 'zefir5.db';

  final Future<Database> _database;
  StateStorage _state;
  TokenStorage _token;

  Storage() : _database = _createDatabase() {
    _token = TokenStorage(_database);
    _state = StateStorage(_database);
  }

  get token => _token;
  get state => _state;

  static Future<Database> _createDatabase() {
    return getDatabasesPath()
        .then((dbDir) => Directory(dbDir).create(recursive: true))
        .then((dbDir) => openDatabase(join(dbDir.path, Storage.databaseFile),
            onCreate: _createRoomsTable, version: 2));
  }

  static Future<void> _createRoomsTable(Database db, int version) {
    developer.log('Attempt to create table');
    return db.execute(SQL.CREATE_ROOMS_TABLE);
  }
}
