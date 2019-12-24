import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/services/eurus.dart';

class JoinRoom extends StatefulWidget {
  final Eurus eurus;

  JoinRoom(this.eurus);

  @override
  _JoinRoomState createState() => _JoinRoomState(eurus: eurus);
}

class _JoinRoomState extends State<JoinRoom> {
  final _formKey = GlobalKey<FormState>();
  final _joinCodeController = TextEditingController();
  final _playerNameField = TextEditingController();

  Eurus _eurus;

  _JoinRoomState({@required Eurus eurus}) {
    this._eurus = eurus;
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
      _buildPlayerNameField(_playerNameField),
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
      onPressed: () => joinRoom(ctx),
      color: Colors.green,
      textColor: Colors.white,
    );

    return SizedBox(
      child: button,
      width: double.infinity,
    );
  }

  void joinRoom(BuildContext context) {
    this
        ._eurus
        .joinRoom(
            roomCode: _joinCodeController.value.text,
            playerName: _playerNameField.value.text)
        .then((bool hasJoined) => {
              if (hasJoined == false)
                {
                  showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: Text("Alert Dialog"),
                          content: Text("Dialog Content"),
                        );
                      })
                }
            });
  }
}
