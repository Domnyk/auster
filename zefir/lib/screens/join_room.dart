import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/screens/wait_for_players.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/storage/token.dart';
import 'package:zefir/widgets/error_dialog.dart';
import 'dart:developer' as developer;

class JoinRoom extends StatefulWidget {
  final Eurus _eurus;
  final TokenStorage _storage;

  JoinRoom({@required Eurus eurus, @required TokenStorage storage})
      : _eurus = eurus,
        _storage = storage;

  @override
  _JoinRoomState createState() =>
      _JoinRoomState(eurus: _eurus, storage: _storage);
}

class _JoinRoomState extends State<JoinRoom> {
  final _formKey = GlobalKey<FormState>();
  final _joinCodeController = TextEditingController();
  final _playerNameController = TextEditingController();

  String _joinCode;
  String _playerName;

  final Eurus _eurus;
  final TokenStorage _storage;

  _JoinRoomState({@required Eurus eurus, @required TokenStorage storage})
      : _eurus = eurus,
        _storage = storage {
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
        (String val) => val.isEmpty ? 'Nazwa gracza nie może być pusta' : null;
    final decoration = InputDecoration(
        border: OutlineInputBorder(), labelText: 'Nazwa graczza');

    return TextFormField(
        validator: validator, decoration: decoration, controller: controller);
  }

  TextFormField _buildJoinCodeField(TextEditingController controller) {
    final validator =
        (String val) => val.isEmpty ? 'Kod nie może być pusty' : null;
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
    bool isFormValid = _formKey.currentState.validate();
    if (isFormValid == false) {
      return;
    }

    _eurus
        .joinRoom(roomCode: _joinCode, playerName: _playerName)
        .then(_addTokenToStorage)
        .then((_) => _navigateToWaitForPlayersScreen(ctx))
        .catchError((err) => _showErrorDialog(ctx, err));
  }

  void _addTokenToStorage(int token) async {
    developer.log('Adding $token to DB', name: 'JoinRoom');
    await _storage.insert(token);
  }

  void _navigateToWaitForPlayersScreen(BuildContext ctx) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => WaitForPlayers()));
  }

  void _showErrorDialog(BuildContext ctx, Exception err) {
    showDialog(
        context: ctx,
        builder: (BuildContext _) {
          return ErrorDialog.build(ctx, err);
        });
  }
}
