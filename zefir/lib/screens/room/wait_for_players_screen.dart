import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:zefir/model/player.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/widgets/confirmation_dialog_widget.dart';
import 'add_question_screen.dart';
import 'dart:developer' as developer;

class WaitForPlayersScreen extends StatefulWidget {
  final Eurus _eurus;
  final Room _room;

  const WaitForPlayersScreen(this._eurus, this._room);

  @override
  _WaitForPlayersScreenState createState() => _WaitForPlayersScreenState();
}

class _WaitForPlayersScreenState extends State<WaitForPlayersScreen> {
  StreamSubscription _playersSubscription;
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();

    _playersSubscription = widget._eurus.roomStreamService
        .createStreamFor(token: widget._room.deviceToken)
        .map((room) => room.players)
        .listen((players) {
      setState(() {
        _players = players;
      });
    });
  }

  @override
  void dispose() {
    _playersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      if (_players.length == widget._room.maxPlayers) {
        Navigator.pushReplacementNamed(ctx, '/addQuestion',
        arguments: AddQuestionRouteParams(widget._room.deviceToken, widget._room.maxRounds));
      }
    });
    
    return Scaffold(
      appBar: _buildAppBar(ctx),
      body: _buildBody(ctx, widget._room),
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
        Column(
          children: [
            _buildRoomName(room.name),
            _buildJoinCode(room.joinCode),
            _buildPlayersWidgets(ctx, room.deviceToken, room.maxPlayers),
            _buildQrCode(room.joinCode),
          ].map((w) => Padding(child: w, padding: EdgeInsets.all(10))).toList(),
        ),
        Padding(
          child: _buildLeaveRoomButton(ctx, room.deviceToken),
          padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
        )
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  Widget _buildPlayersWidgets(BuildContext ctx, int token, int maxPlayers) {
    List<String> playersNames = _players.map((p) => p.name).toList();

    Widget loading = Text('Proszę czekać, ładuję listę graczy...');

    Widget playersList = Column(
      children: <Widget>[
        Padding(
            child: _buildListOfPlayers(ctx, playersNames),
            padding: EdgeInsets.only(bottom: 10)),
        _buildNumOfMissingPlayers(maxPlayers, playersNames.length)
      ],
    );

    return playersNames.isEmpty ? loading : playersList;
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

  Widget _buildLeaveRoomButton(BuildContext ctx, int token) {
    Widget confirmationDialog = ConfirmationDialogWidget(
        'Opuszczasz pokój', 'Jesteś pewien, że chcesz opuścic pokój', () {
      widget._eurus.leaveRoom(ctx, token).then((_) {
        Navigator.of(ctx).popUntil(ModalRoute.withName('/'));
      });
    });

    return RaisedButton(
        onPressed: () =>
            showDialog(context: ctx, builder: (_) => confirmationDialog),
        color: Colors.red,
        textColor: Colors.white,
        child: Text('Opuść pokój'));
  }
}

class WaitForPlayersRouteParams {
  final Eurus eurus;
  final Room room;

  const WaitForPlayersRouteParams(this.room, this.eurus);
}
