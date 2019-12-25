import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/screens/wait_for_players.dart';
import 'package:zefir/services/eurus/eurus.dart';

class JoinRoom extends StatefulWidget {
  final Eurus eurus;

  JoinRoom(this.eurus);

  @override
  _JoinRoomState createState() => _JoinRoomState(eurus: eurus);
}

class _JoinRoomState extends State<JoinRoom> {
  final _formKey = GlobalKey<FormState>();
  final _joinCodeController = TextEditingController();
  final _playerNameController = TextEditingController();

  String _joinCode;
  String _playerName;

  Eurus _eurus;

  _JoinRoomState({@required Eurus eurus}) {
    this._eurus = eurus;

    _joinCodeController.addListener(() {
      _joinCode = _joinCodeController.value.text.trim();
    });

    _playerNameController.addListener(() {
      _playerName = _playerNameController.value.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Dołącz do pokoju')),
        body: _buildForm(context, _formKey));
  }

  Form _buildForm(BuildContext context, GlobalKey<FormState> formKey) {
    final widgestWithPaddings = [
      _buildJoinCodeField(_joinCodeController),
      _buildPlayerNameField(_playerNameController),
      _buildSubmitButton(context)
    ].map((w) => Padding(child: w, padding: EdgeInsets.all(10))).toList();

    return Form(
        key: formKey,
        child: Column(
          children: widgestWithPaddings,
        ));
  }

  TextFormField _buildPlayerNameField(TextEditingController controller) {
    final validator =
        (String val) => val.isEmpty ? 'nazwa gracza nie może być pusta' : null;
    final decoration = InputDecoration(
        border: OutlineInputBorder(), labelText: 'Nazwa graczza');

    return TextFormField(
        validator: validator, decoration: decoration, controller: controller);
  }

  TextFormField _buildJoinCodeField(TextEditingController controller) {
    final validator =
        (String val) => val.isEmpty ? 'kod nie może być pusty' : null;
    final decoration =
        InputDecoration(border: OutlineInputBorder(), labelText: 'Kod');

    return TextFormField(
        validator: validator, decoration: decoration, controller: controller);
  }

  Widget _buildSubmitButton(BuildContext ctx) {
    final button = RaisedButton(
      child: Text('Dołącz'),
      onPressed: () => _joinRoom(ctx),
      color: Colors.green,
      textColor: Colors.white,
    );

    return SizedBox(
      child: button,
      width: double.infinity,
    );
  }

  void _joinRoom(BuildContext ctx) {
    showErrorDialog(err) {
      showDialog(
          context: ctx,
          builder: (BuildContext _) {
            return AlertDialog(
              title: Text("Wystąpił błąd"),
              content:
                  Text("Nie udało dołączyć się do pokoju. Spróbuj ponownie"),
            );
          });
    }

    void navigateToWaitForPlayersScreen(_) {
      Navigator.push(
          ctx, MaterialPageRoute(builder: (context) => WaitForPlayers()));
    }

    this
        ._eurus
        .joinRoom(roomCode: _joinCode, playerName: _playerName)
        .then(navigateToWaitForPlayersScreen)
        .catchError(showErrorDialog);
  }
}
