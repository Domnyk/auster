import 'package:flutter/material.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/utils.dart';

class DeadScreen extends StatelessWidget {
  static const String appBarTitle = 'Koniec gry';

  // final Room room;
  final _formKey = GlobalKey<FormState>();

  DeadScreen();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(leading: null, title: Text(appBarTitle)),
      bottomNavigationBar:
          Builder(builder: (context) => _buildBottomAppBar(context)),
      body: _buildWinner(ctx),
    );
  }

  Widget _buildBottomAppBar(BuildContext ctx) {
    return BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton(
              onPressed: () => Navigator.of(ctx).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false),
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('Przejdź do listy pokoi'),
            ),
            FlatButton(
              onPressed: () => showDialog(
                  context: ctx, child: _buildSaveQuestiosDialog(ctx)),
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('Zapisz zestaw pytań'),
            ),
          ],
        ));
  }

  Widget _buildSaveQuestiosDialog(BuildContext ctx) {
    return AlertDialog(
      title: Text('Zapisz zestaw pytań'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Nazwa zestawu'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Anuluj'),
          onPressed: () => Navigator.pop(ctx),
        ),
        FlatButton(
          child: Text('Zapisz'),
          onPressed: () {
            Navigator.pop(ctx);
            Scaffold.of(ctx).showSnackBar(
                SnackBar(content: Text('Pytania zostały zapisane')));
          },
        ),
      ],
    );
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

    Widget l = ListView.builder(
      shrinkWrap: true,
      itemCount: room.players.length,
      itemBuilder: (BuildContext context, int index) {
        final Widget leading = winners.contains(room.players[index])
            ? Icon(
                Icons.grade,
                color: Colors.orange,
              )
            : Icon(null);

        return ListTile(
          leading: leading,
          title: Text(
            room.players[index].name,
          ),
          trailing: Text(room.players[index].points.toString()),
        );
      },
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildTitle(ctx, winners, room.deviceToken),
        l,
      ],
    );
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
          style: TextStyle(fontSize: Theme.of(ctx).textTheme.display1.fontSize),
        ));
  }
}

class DeadRouteParams {
  final Room room;

  DeadRouteParams(this.room);
}
