import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/answer.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/question.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/services/storage/state.dart';
import 'dart:developer' as developer;

import 'package:zefir/utils.dart';

// TODO: Change name to something shorter
class PollingScreenForQuestionOwner extends StatelessWidget {
  const PollingScreenForQuestionOwner();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Głosowanie'),
        ),
        body: StreamBuilder(
          stream: _buildStream(ctx),
          builder: (BuildContext context, AsyncSnapshot<Room> snapshot) {
            if (!snapshot.hasData) return Text('dupa');

            Room room = snapshot.data;
            List<Player> polledPlayers =
                room.players.where((p) => p.polledAnswer != null).toList();

            return Column(
              children: [
                _buildQuestion(context, room.currQuestion),
                _buildAllAnswers(room.currAnswers),
                _buildPolledAnswers(polledPlayers),
              ],
            );
          },
        ));
  }

  Widget _buildQuestion(BuildContext ctx, Question q) {
    return Text('${q.content}',
        style: TextStyle(fontSize: Theme.of(ctx).textTheme.display2.fontSize));
  }

  Widget _buildAllAnswersHeadline(BuildContext ctx) {
    return Text('Odpowiedz jakie pojawiły się do Twojego pytania');
  }

  Widget _buildAllAnswers(List<Answer> allAnswers) {
    return Column(
      children: [
        Text('Odpowiedz jakie pojawiły się do Twojego pytania'),
        ListView.builder(
          shrinkWrap: true,
          itemCount: allAnswers.length,
          itemBuilder: (BuildContext ctx, int index) {
            return Text('$index: ${allAnswers[index].content}');
          },
        )
      ],
    );
  }

  Widget _buildPolledAnswers(List<Player> polledPlayers) {
    return Column(
      children: [
        Text('Odpowiedz udzielone do tej pory'),
        ListView.builder(
          shrinkWrap: true,
          itemCount: polledPlayers.length,
          itemBuilder: (BuildContext ctx, int index) {
            return Text('$index: ${polledPlayers[index].polledAnswer.content}');
          },
        )
      ],
    );
  }

  Stream<Room> _buildStream(BuildContext ctx) {
    final token =
        (Utils.routeArgs(ctx) as PollingScreenForQuestionOwnerRouteParams)
            .token;
    final stateStorage = Zefir.of(ctx).storage.state;
    final client = Zefir.of(ctx).eurus.client.value;
    final options = WatchQueryOptions(
      fetchResults: true,
      pollInterval: 5,
      document: Queries.FETCH_ROOM,
      fetchPolicy: FetchPolicy.networkOnly,
      errorPolicy: ErrorPolicy.all,
      variables: {'token': token},
    );

    return _RoomStream(client, options, stateStorage, token).build();
  }
}

class _RoomStream {
  final GraphQLClient _client;
  final WatchQueryOptions _options;
  final StateStorage _state;
  final int _token;

  _RoomStream(this._client, this._options, this._state, this._token);

  Stream<Room> build() {
    return _client.watchQuery(_options).stream.asyncMap((result) async {
      if (result.hasException || result.data == null) return null;

      final Room room = Room.fromGraphQL(result.data['player']['room'], _token);
      final RoomState stateFromDb = await _state.fetch(_token);

      if (room.state != stateFromDb) {
        developer.log(
            'State from db: $stateFromDb differs from state from backend: ${room.state}');
      }
      room.state = RoomStateUtils.merge(stateFromDb, room.state);
      return room;
    });
  }
}

// TODO: Change name to something shorter
// TODO: Nearly all route params classes have same one field - token
class PollingScreenForQuestionOwnerRouteParams {
  final int token;

  PollingScreenForQuestionOwnerRouteParams(this.token);
}
