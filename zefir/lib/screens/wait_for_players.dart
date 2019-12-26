import 'package:flutter/material.dart';

class WaitForPlayers extends StatefulWidget {
  @override
  _WaitForPlayersState createState() => _WaitForPlayersState(roomName: 'Dupa');
}

class _WaitForPlayersState extends State<WaitForPlayers> {
  String _roomName;

  _WaitForPlayersState({@required String roomName}) {
    this._roomName = roomName;
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(title: Text('Oczekiwanie na graczy')),
        body: _buildBody(ctx));
  }

  Widget _buildBody(BuildContext ctx) {
    List<Widget> widgets = [
      _buildRoomName(this._roomName),
      _buildJoinCode('MXCu23jk'),
      _buildListOfPlayers(ctx),
      _buildNumOfMissingPlayers(),
      _buildLeaveRoom()
    ].map((w) => Padding(child: w, padding: EdgeInsets.all(10))).toList();

    return Column(
      children: widgets,
    );
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

  Widget _buildListOfPlayers(BuildContext ctx) {
    List<String> players = ['Stefan', 'Roman', 'Jadwiga'];

    Widget _buildItem(BuildContext ctx, int index) {
      return ListTile(
        title: Text(
          players[index],
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
        itemCount: players.length,
        itemBuilder: _buildItem,
        scrollDirection: Axis.vertical,
        shrinkWrap: true);

    return Column(
      children: <Widget>[heading, listOfPlayers],
    );
  }

  Widget _buildNumOfMissingPlayers() {
    return Row(
      children: <Widget>[
        Text('Potrzeba jeszcze 4 graczy aby rozpocząć rozgrywkę')
      ],
    );
  }

  Widget _buildLeaveRoom() {
    final btn = RaisedButton(
        onPressed: () => {},
        color: Colors.red,
        textColor: Colors.white,
        child: Text('Opuść pokój'));

    return SizedBox(
      child: btn,
      width: double.infinity,
    );
  }
}
