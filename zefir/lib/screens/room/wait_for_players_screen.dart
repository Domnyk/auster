import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/screens/room/add_question_screen.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/eurus/queries.dart';
import 'package:zefir/utils.dart';
import 'package:zefir/widgets/confirmation_dialog_widget.dart';
import 'dart:developer' as developer;

class WaitForPlayersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    final Room room = (Utils.routeArgs(ctx) as WaitForPlayersRouteParams).room;

    return Scaffold(appBar: _buildAppBar(ctx), body: _buildBody(ctx, room));
  }

  Widget _buildAppBar(BuildContext ctx) {
    return AppBar(
      title: Text('Oczekiwanie na graczy'),
      leading: _buildLeading(ctx),
    );
  }

  Widget _buildLeading(BuildContext ctx) {
    return BackButton(
      onPressed: () => Navigator.of(ctx).popUntil(ModalRoute.withName('/')),
    );
  }

  Widget _buildBody(BuildContext ctx, Room room) {
    List<Widget> widgets = [
      _buildRoomName(room.name),
      _buildJoinCode(room.joinCode),
      _buildPlayersWidgets(ctx, room.deviceToken, room.maxPlayers),
      _buildLeaveRoom(ctx, room.deviceToken)
    ].map((w) => Padding(child: w, padding: EdgeInsets.all(10))).toList();

    return Column(
      children: widgets,
    );
  }

  Widget _buildPlayersWidgets(BuildContext ctx, int token, int maxPlayers) {
    return Query(
      options: _buildQueryOptions(ctx, token),
      builder: (QueryResult result, {fetchMore, refetch}) {
        //   WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
        // if (isInWaitingState == false) {
        //   developer.log(
        //       'All players have add questions, navigation to AnsweringScreen',
        //       name: 'WaitForOtherQuestionsScreen');
        //   Navigator.of(ctx).pushNamed('/answering',
        //       arguments: AnsweringRouteParams(
        //           (Utils.routeArgs(ctx) as WaitForOtherQuestionsRouteParams)
        //               .token));
        // }

        if (result.hasException) developer.log('Result has exception');
        if (result.loading) return Text('Proszę czekać, trwa ładowanie');

        List<String> playersNames =
            (result.data['player']['room']['players'] as List<dynamic>)
                .map((p) => p['name'] as String)
                .toList();

        WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
          if (playersNames.length == maxPlayers) {
            Navigator.pushReplacementNamed(ctx, '/addQuestion',
                arguments: AddQuestionRouteParams(token));
          }
        });

        return Column(
          children: <Widget>[
            _buildListOfPlayers(ctx, playersNames),
            _buildNumOfMissingPlayers(maxPlayers, playersNames.length)
          ],
        );
      },
    );
  }

  QueryOptions _buildQueryOptions(BuildContext ctx, int token) {
    return QueryOptions(
        document: Queries.FETCH_PLAYERS,
        pollInterval: 5,
        variables: {'token': token});
  }

  Widget _buildRoomName(String roomName) {
    return Row(
      children: <Widget>[Text('Nazwa pokoju'), Text(roomName)],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  Widget _buildJoinCode(String joinCode) {
    return Row(
      children: <Widget>[Text('Kod dołączenia'), Text(joinCode)],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  Widget _buildListOfPlayers(BuildContext ctx, List<String> playersNames) {
    Widget _buildItem(BuildContext ctx, int index) {
      return ListTile(
        title: Text(
          playersNames[index],
          style: TextStyle(fontSize: Theme.of(ctx).textTheme.body1.fontSize),
        ),
        contentPadding: EdgeInsets.all(0),
        dense: true,
      );
    }

    Text heading = Text(
      'Lista graczy w pokoju',
      style: TextStyle(fontSize: Theme.of(ctx).textTheme.headline.fontSize),
    );
    ListView listOfPlayers = ListView.builder(
        itemCount: playersNames.length,
        itemBuilder: _buildItem,
        scrollDirection: Axis.vertical,
        shrinkWrap: true);

    return Column(
      children: <Widget>[heading, listOfPlayers],
    );
  }

  Widget _buildNumOfMissingPlayers(int maxPlayers, int currNumOfPlayers) {
    int neededNumOfPlayers = maxPlayers - currNumOfPlayers;

    return Row(
      children: <Widget>[
        Text(
            'Potrzeba jeszcze $neededNumOfPlayers graczy aby rozpocząć rozgrywkę')
      ],
    );
  }

  Widget _buildLeaveRoom(BuildContext ctx, int token) {
    final Eurus eurus = Zefir.of(ctx).eurus;
    Widget confirmationDialog = ConfirmationDialogWidget(
        'Opuszczasz pokój', 'Jesteś pewien, że chcesz opuścic pokój', () {
      eurus.leaveRoom(ctx, token).then((_) {
        Navigator.of(ctx).popUntil(ModalRoute.withName('/'));
      });
    });

    final btn = RaisedButton(
        onPressed: () =>
            showDialog(context: ctx, builder: (_) => confirmationDialog),
        color: Colors.red,
        textColor: Colors.white,
        child: Text('Opuść pokój'));

    return SizedBox(
      child: btn,
      width: double.infinity,
    );
  }
}

class WaitForPlayersRouteParams {
  final Room room;

  const WaitForPlayersRouteParams(this.room);
}
