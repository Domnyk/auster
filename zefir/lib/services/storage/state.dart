import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zefir/model/player_poll_result.dart';
import 'dart:developer' as developer;

import 'package:zefir/model/room_state.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/utils.dart';

class StateStorage {
  final Future<Database> _database;
  final GraphQLClient _graphQLClient;

  StateStorage(this._database, this._graphQLClient);

  Future<RoomState> fetch(int token) async {
    final Database db = await _database;

    String rawState = (await db.query('rooms')).firstWhere(
        (Map<String, dynamic> map) => map['token'] == token)['state'] as String;

    if (rawState == null) {
      return null;
    }

    RoomState fromDb = RoomStateUtils.parse(rawState);
    RoomState fromBackend = await _fetchFromBackend(token);
    RoomState state = fromDb == null
        ? fromBackend
        : RoomStateUtils.merge(fromDb, fromBackend);

    developer.log(
        'State fetched from database for $token: ${state.toMyString()}',
        name: 'StateStorage');
    // return fromDb;
    return state;
  }

  Future<void> insert(int token, RoomState state) async {
    final Database db = await _database;

    final Map<String, dynamic> map = {
      'token': token,
      'state': state.toMyString()
    };

    await db.insert('rooms', map);
  }

  Future<void> update(int token, RoomState newState) async {
    final Database db = await _database;

    final Map<String, dynamic> map = {
      'token': token,
      'state': newState.toMyString(),
    };

    await db.update('rooms', map,
        where: "token = ?",
        whereArgs: [token],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> savePlayerPollResult(int token, PlayerPollResult p) async {
    final Database db = await _database;

    final Map<String, dynamic> map = {
      'token': token,
      'pastpoints': p.pastPoints,
      'question': p.question,
      'correctanswer': p.correctAnswer,
      'choosedanswer': p.choosedAnswer,
      'wasowner': p.wasOwner.toString()
    };

    await db.update('rooms', map);
  }

  Future<PlayerPollResult> fetchPlayerPollResult(int token) async {
    final Database db = await _database;

    Map<String, dynamic> data = (await db.query('rooms'))
        .firstWhere((Map<String, dynamic> map) => map['token'] == token);

    bool wasOwner = data['wasowner'] == 'true';
    if (wasOwner) {
      return PlayerPollResult(null, null, null, null, true);
    } else {
      final int pastPoints = int.tryParse(data['pastpoints'], radix: 10);

      return PlayerPollResult(pastPoints, data['question'],
          data['correctAnswer'], data['choosedAnswer'], false);
    }
  }

  Future<RoomState> _fetchFromBackend(int token) async {
    final result = await _graphQLClient.query(QueryOptions(
        document: Queries.FEETCH_ROOM_STATE,
        fetchPolicy: FetchPolicy.networkOnly,
        variables: {'token': token}));

    if (result.hasException) {
      throw Exception(
          'Exception occured when fetching room state from backend: ${Utils.parseExceptions(result.exception)}');
    } else if (!result.hasException && result.data == null) {
      throw Exception('Data from backend are null');
    }

    return RoomStateUtils.parse(result.data['player']['room']['state']);
  }
}
