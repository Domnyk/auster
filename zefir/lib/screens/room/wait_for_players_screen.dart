import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

    return Scaffold(
      appBar: _buildAppBar(ctx),
      body: _buildBody(ctx, room),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.red,
        child: _buildLeaveRoom(ctx, room.deviceToken),
      ),
    );
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
    return Column(
      children: [
        Expanded(
            flex: 9,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildRoomName(room.name),
                _buildJoinCode(room.joinCode),
                _buildPlayersWidgets(ctx, room.deviceToken, room.maxPlayers),
                _buildQrCode(room.joinCode),
              ]
                  .map((w) => Padding(child: w, padding: EdgeInsets.all(10)))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildPlayersWidgets(BuildContext ctx, int token, int maxPlayers) {
    return Query(
      options: _buildQueryOptions(ctx, token),
      builder: (QueryResult result, {fetchMore, refetch}) {
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
            Padding(
                child: _buildListOfPlayers(ctx, playersNames),
                padding: EdgeInsets.only(bottom: 10)),
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

  Widget _buildQrCode(String joinCode) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Text('Kod QR umożliwiający dołączenie do pokoju'), flex: 5),
        Expanded(
          flex: 5,
          child: QrImage(
            data: joinCode,
            version: QrVersions.auto,
          ),
        )
      ],
    );
  }

  Widget _buildListOfPlayers(BuildContext ctx, List<String> playersNames) {
    final List<Widget> children = [];
    children.addAll(playersNames.map((name) => Text(name)));

    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Lista graczy w pokoju',
          ),
          Column(
            children: children,
          )
        ]);
  }

  Widget _buildNumOfMissingPlayers(int maxPlayers, int currNumOfPlayers) {
    int neededNumOfPlayers = maxPlayers - currNumOfPlayers;
    String content = neededNumOfPlayers == 1
        ? 'Potrzeba jeszcze 1 gracza aby rozpocząć rozgrywkę'
        : 'Potrzeba jeszcze $neededNumOfPlayers graczy aby rozpocząć rozgrywkę';

    return Row(
      children: <Widget>[Text(content)],
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

    return FlatButton(
        onPressed: () =>
            showDialog(context: ctx, builder: (_) => confirmationDialog),
        color: Colors.red,
        textColor: Colors.white,
        child: Text('Opuść pokój'));
  }
}

class WaitForPlayersRouteParams {
  final Room room;

  const WaitForPlayersRouteParams(this.room);
}
