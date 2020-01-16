import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/model/room_state.dart';
import 'package:zefir/screens/room/add_question.dart';
import 'package:zefir/screens/room/wait_for_players.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/services/storage/token.dart';
import 'package:zefir/widgets/error_dialog.dart';
import 'dart:developer' as developer;

class JoinRoom extends StatefulWidget {
  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final _formKey = GlobalKey<FormState>();
  final _joinCodeController = TextEditingController();
  final _playerNameController = TextEditingController();

  String _joinCode;
  String _playerName;

  Eurus _eurus;
  TokenStorage _storage;

  _JoinRoomState() {
    _joinCodeController.addListener(() {
      _joinCode = _joinCodeController.value.text.trim();
    });

    _playerNameController.addListener(() {
      _playerName = _playerNameController.value.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    _eurus = Zefir.of(context).eurus;
    _storage = Zefir.of(context).storage.token;

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
        .then((room) => _navigateToNextScreen(ctx, room))
        .catchError((err) => _showErrorDialog(ctx, err));
  }

  Future<void> _navigateToNextScreen(
      BuildContext ctx, Room roomAfterJoining) async {
    if (roomAfterJoining.state == RoomState.COLLECTING) {
      await _navigatToAddQuestion(ctx, roomAfterJoining.deviceToken);
    } else if (roomAfterJoining.state == RoomState.JOINING) {
      await _navigateToWaitForPlayers(ctx, roomAfterJoining);
    }
  }

  Future<void> _navigateToWaitForPlayers(BuildContext ctx, Room room) async {
    await _storage.insert(room.deviceToken, initialState: RoomState.JOINING);

    Navigator.pushReplacementNamed(ctx, '/waitForPlayers',
        arguments: WaitForPlayersRouteParams(room));
  }

  Future<void> _navigatToAddQuestion(BuildContext ctx, int token) async {
    await _storage.insert(token, initialState: RoomState.COLLECTING);

    Navigator.pushReplacementNamed(ctx, '/addQuestion',
        arguments: AddQuestionRouteParams(token));
  }

  void _showErrorDialog(BuildContext ctx, Exception err) {
    showDialog(
        context: ctx,
        builder: (BuildContext _) {
          return ErrorDialog.build(ctx, err);
        });
  }
}
