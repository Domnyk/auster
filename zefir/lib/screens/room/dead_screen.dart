import 'package:flutter/material.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/screens/save_questions_screen.dart';
import 'package:zefir/utils.dart';

class DeadScreen extends StatelessWidget {
  static const String appBarTitle = 'Koniec gry';

  final _formKey = GlobalKey<FormState>();

  DeadScreen();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
          leading: null,
          title: Text(appBarTitle),
          automaticallyImplyLeading: false),
      bottomNavigationBar:
          Builder(builder: (context) => _buildBottomAppBar(context)),
      body: _buildWinner(ctx),
    );
  }

  Widget _buildBottomAppBar(BuildContext ctx) {
    return BottomAppBar(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FlatButton(
          onPressed: () => Navigator.of(ctx)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false),
          child: Text('Przejdź do listy pokoi'),
        ),
        FlatButton(
          onPressed: () {
            final questions =
                (Utils.routeArgs(ctx) as DeadRouteParams).room.allQuestions;
            Navigator.pushNamed(ctx, '/saveQuestions',
                arguments: SaveQuestionsRouteParams(questions));
          },
          child: Text('Zapisz zestaw pytań'),
        ),
      ],
    ));
  }

  Widget _buildWinner(BuildContext ctx) {
    final room = (Utils.routeArgs(ctx) as DeadRouteParams).room;
    room.players.sort((p1, p2) => p2.points.compareTo(p1.points));
    final Map<int, List<Player>> playersDict = Map();

    room.players.forEach((p) {
      final int key = p.points;
      playersDict[key] == null
          ? playersDict[key] = [p]
          : playersDict[key].add(p);
    });

    int winnersKey = (playersDict.keys..toList().sort()).first;
    List<Player> winners = playersDict[winnersKey];

    Widget title = _buildTitle(ctx, winners, room.deviceToken);
    List<Widget> children = [title];
    room.players.forEach((p) {
      Widget playerIcon = Padding(
          child: Icon(Icons.person), padding: EdgeInsets.only(left: 10));
      Widget maybeStar = winners.contains(p)
          ? Icon(Icons.grade, color: Colors.orange)
          : Icon(null);
      Widget points = Text(p.points.toString());

      children.add(Column(
        children: [
          ListTile(
            leading: maybeStar,
            title: Row(children: [
              Text(p.name),
              if (room.deviceToken == p.token) playerIcon
            ]),
            trailing: points,
          ),
          Divider()
        ],
      ));
    });

    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: children,
    ));
  }

  Widget _buildTitle(BuildContext ctx, List<Player> winners, int deviceToken) {
    if (winners.length < 1) throw Exception('Num of winners is less than 1');

    String content;
    if (winners.length == 1 && winners[0].token == deviceToken) {
      content = 'Gratulacje, wygrałeś!';
    } else if (winners.length == 1 && winners[0].token != deviceToken) {
      content = 'Powodzenia następnym razem';
    } else if (winners.length > 1 &&
        winners.any((p) => p.token == deviceToken)) {
      content = 'Gratulacje, jesteś jednym ze zwycięzców';
    } else if (winners.length > 1 &&
        !winners.any((p) => p.token == deviceToken)) {
      content = 'Mamy ${winners.length} zwycięzców!';
    } else {
      content = 'Koniec gry!';
    }

    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: Theme.of(ctx).textTheme.display1.fontSize),
        ));
  }
}

class DeadRouteParams {
  final Room room;

  DeadRouteParams(this.room);
}
