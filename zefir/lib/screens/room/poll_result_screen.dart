import 'package:flutter/material.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/player_poll_result.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/answering_screen.dart';
import 'package:zefir/services/storage/state.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/zefir.dart';

class PollResultScreen extends StatelessWidget {
  static const String appBarTitle = 'Wyniki głosowania';
  static const headlinePadding = const EdgeInsets.fromLTRB(10, 10, 0, 0);

  const PollResultScreen();

  @override
  Widget build(BuildContext ctx) {
    final Room room = (Utils.routeArgs(ctx) as PollResultRouteParams).room;
    final PlayerPollResult pollResult =
        (Utils.routeArgs(ctx) as PollResultRouteParams).playerPollResult;

    final bool isOwner = pollResult.wasOwner;
    final int pastPoints = pollResult.pastPoints;
    final String question = pollResult.question;
    final String correctAnswer = pollResult.correctAnswer;
    final String choosedAnswer = pollResult.choosedAnswer;
    final int gainedPoints =
        isOwner ? 0 : room.getDevicePlayer().points - pastPoints;

    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
        ),
        body: LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: constraints.copyWith(
                minHeight: constraints.maxHeight,
                maxHeight: double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      _buildSummary(
                          ctx,
                          gainedPoints,
                          formatToLowerCase(question),
                          formatToLowerCase(
                              isOwner ? correctAnswer : choosedAnswer),
                          formatToLowerCase(correctAnswer),
                          isOwner),
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: _buildScores(ctx, room),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Text('Następne pytanie'),
                      onPressed: () async {
                        await _navigateToNextQuestion(ctx);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  Widget _buildSummary(BuildContext ctx, int numOfPointsGained, String question,
      String playerAnswer, String correctAnswer, bool isOwner) {
    return Column(
        children: [
      Padding(
        padding: headlinePadding,
        child: Text(
          'Podsumowanie',
          style: TextStyle(fontSize: Theme.of(ctx).textTheme.headline.fontSize),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(30, 5, 0, 0),
        child: Text(isOwner
            ? 'Gracze odpowiadali na Twoje pytanie'
            : 'Liczba zdobytych puntków: $numOfPointsGained'),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(30, 5, 0, 0),
        child: Text('Pytanie: $question'),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(30, 5, 0, 0),
        child: Text('Twoja odpowiedź: $playerAnswer'),
      ),
      if (!isOwner)
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 5, 0, 0),
          child: Text('Poprawna odpowiedź: $correctAnswer'),
        ),
    ]
            .map((w) => SizedBox(
                  child: w,
                  width: double.infinity,
                ))
            .toList());
  }

  Widget _buildScores(BuildContext ctx, Room room) {
    return Column(
      children: <Widget>[
        Padding(
          padding: headlinePadding,
          child: SizedBox(
              width: double.infinity,
              child: Text('Tabela wyników',
                  style: TextStyle(
                      fontSize: Theme.of(ctx).textTheme.headline.fontSize))),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: room.players.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildListItem(ctx, room.players[index], room);
          },
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext ctx, Player player, Room room) {
    bool isCurrentPlayer = room.getDevicePlayer().token == player.token;

    return Column(children: [
      Padding(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    player.name,
                  ),
                  if (isCurrentPlayer)
                    Padding(
                        child: Icon(Icons.person, size: 18),
                        padding: const EdgeInsets.only(left: 10)),
                ],
              ),
              Text(
                player.points.toString(),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 40, 10)),
      Divider(height: 0, color: Colors.grey),
    ]);
  }

  Future<void> _navigateToNextQuestion(BuildContext ctx) {
    final Room room = (Utils.routeArgs(ctx) as PollResultRouteParams).room;
    final StateStorage storage = Zefir.of(ctx).eurus.storage.state;

    return storage.update(room.deviceToken, RoomState.ANSWERING).then((_) =>
        Navigator.of(ctx).pushReplacementNamed('/answering',
            arguments: AnsweringRouteParams(room.deviceToken)));
  }

  String formatToLowerCase(String s) {
    return s.substring(0, 1).toLowerCase() + s.substring(1, s.length);
  }
}

class PollResultRouteParams {
  final Room room;

  final PlayerPollResult playerPollResult;

  PollResultRouteParams(this.room, this.playerPollResult);
}
