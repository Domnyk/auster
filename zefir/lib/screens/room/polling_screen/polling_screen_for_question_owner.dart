import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/answer.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/question.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/dead_screen.dart';
import 'package:zefir/screens/room/poll_result_screen.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/zefir.dart';
import 'dart:developer' as developer;

// TODO: Change name to something shorter
class PollingScreenForQuestionOwner extends StatelessWidget {
  const PollingScreenForQuestionOwner();

  @override
  Widget build(BuildContext ctx) {
    int token = (Utils.routeArgs(ctx) as PollingScreenForQuestionOwnerRouteParams).token;
    
    return Scaffold(
        appBar: AppBar(
          title: Text('Głosowanie'),
        ),
        body: StreamBuilder(
          stream: Zefir.of(ctx).eurus.roomStreamService.createStreamFor(token: token),
          builder: (BuildContext context, AsyncSnapshot<Room> snapshot) {
            if (snapshot.hasError) throw Exception(snapshot.error);

            if (!snapshot.hasData) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Center(child: Text('Proszę czekać, trwa pobieranie danych'))
                ],
              );
            }

            Room room = snapshot.data;
            developer
                .log('Got room data with state ${room.state.toMyString()}');

            if (room.state == RoomState.DEAD) {
              return RaisedButton(
                child: Text('Przejdź do listy wyników'),
                onPressed: () => Navigator.of(ctx).pushReplacementNamed(
                    '/dead',
                    arguments: DeadRouteParams(room)),
              );
            }

            if (room.state == RoomState.ANSWERING && room.deviceToken != room.currPlayer.token) {
              return RaisedButton(
                child: Text('Przejdź do listy wyników'),
                onPressed: () => Navigator.of(ctx).pushReplacementNamed(
                    '/pollResult',
                    arguments: PollResultRouteParams(room)),
              );
            }

            List<Player> polledPlayers =
                room.players.where((p) => p.polledAnswer != null).toList();

            return Column(
              children: [
                _buildQuestion(context, room.currQuestion),
                _buildAllAnswersHeadline(ctx),
                _buildAllAnswers(room.currAnswers),
                _buildPolledAnswersHeadline(ctx),
                _buildPolledAnswers(polledPlayers),
              ]
                  .map((w) => Padding(child: w, padding: EdgeInsets.all(10)))
                  .toList(),
            );
          },
        ));
  }

  Widget _buildQuestion(BuildContext ctx, Question q) {
    return Text('${q.content}',
        style: TextStyle(fontSize: Theme.of(ctx).textTheme.display2.fontSize));
  }

  Widget _buildAllAnswersHeadline(BuildContext ctx) {
    return Text('Odpowiedzi jakie pojawiły się do Twojego pytania');
  }

  Widget _buildAllAnswers(List<Answer> allAnswers) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: allAnswers.length,
      itemBuilder: (BuildContext ctx, int index) {
        return Text('$index: ${allAnswers[index].content}');
      },
    );
  }

  Widget _buildPolledAnswersHeadline(BuildContext ctx) {
    return Text('Odpowiedz udzielone do tej pory');
  }

  Widget _buildPolledAnswers(List<Player> polledPlayers) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: polledPlayers.length,
      itemBuilder: (BuildContext ctx, int index) {
        return Text('$index: ${polledPlayers[index].polledAnswer.content}');
      },
    );
  }

  void navigateToPollResultScreen(BuildContext ctx, Room room) {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      Navigator.of(ctx).pushReplacementNamed('/pollResult',
          arguments: PollResultRouteParams(room));
    });
  }
}

// TODO: Change name to something shorter
// TODO: Nearly all route params classes have same one field - token
class PollingScreenForQuestionOwnerRouteParams {
  final int token;

  PollingScreenForQuestionOwnerRouteParams(this.token);
}
