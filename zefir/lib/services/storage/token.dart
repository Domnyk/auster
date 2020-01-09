import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zefir/services/storage/SQLs.dart';
import 'dart:developer' as developer;

class TokenStorage {
  static String file = 'zefir.db';

  Database _database;

  Future<List<int>> fetchAll() async {
    await _openDatabaseIfNecessary();

    List<int> tokens = (await _database.query('tokens'))
        .map((Map<String, dynamic> map) => map['id'] as int)
        .toList();

    developer.log('Tokens fetched from database: $tokens',
        name: 'TokenStorage');
    return tokens;
  }

  Future<void> insert(int token) async {
    await _openDatabaseIfNecessary();

    final Map<String, dynamic> map = {'id': token};
    developer.log('Inserting following map into database: ${map.toString()}',
        name: 'TokenStorage');

    await _database.insert('tokens', {'id': token});
  }

  Future<void> delete(int token) async {
    await _openDatabaseIfNecessary();

    await _database.delete('tokens', where: 'id = ?', whereArgs: [token]);
  }

  Future<void> _openDatabaseIfNecessary() async {
    String dbsDir = await getDatabasesPath();

    await Directory(dbsDir).create(recursive: true);

    if (_database == null) {
      _database = await openDatabase(join(dbsDir, TokenStorage.file),
          onCreate: _createTokensTable, version: 1);
    }
  }

  Future<void> _createTokensTable(Database db, int version) async {
    return await db.execute(SQL.CREATE_TOKENS_TABLE);
  }
}
