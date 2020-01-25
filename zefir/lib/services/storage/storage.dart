import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zefir/services/storage/SQLs.dart';
import 'package:zefir/services/storage/question.dart';
import 'package:zefir/services/storage/state.dart';
import 'dart:developer' as developer;

import 'package:zefir/services/storage/token.dart';

class Storage {
  static String databaseFile = 'zefir13.db';

  final Future<Database> _database;
  StateStorage _state;
  TokenStorage _token;
  QuestionStorage _question;

  Storage(GraphQLClient graphQLClient) : _database = _createDatabase() {
    _token = TokenStorage(_database);
    _state = StateStorage(_database, graphQLClient);
    _question = QuestionStorage(_database);
  }

  TokenStorage get token => _token;
  StateStorage get state => _state;
  QuestionStorage get question => _question;

  static Future<Database> _createDatabase() {
    return getDatabasesPath()
        .then((dbDir) => Directory(dbDir).create(recursive: true))
        .then((dbDir) => openDatabase(join(dbDir.path, Storage.databaseFile),
            onCreate: _createTables, version: 2));
  }

  static Future<void> _createTables(Database db, int version) async {
    developer.log('Attempt to create table');
    await db.execute(SQL.CREATE_ROOMS_TABLE);
    await db.execute(SQL.CREATE_QUESTIONS_TABLE);
  }
}
