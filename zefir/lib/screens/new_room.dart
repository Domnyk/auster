import 'package:flutter/material.dart';
import 'package:zefir/main.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/screens/room/wait_for_players.dart';
import 'package:zefir/services/storage/token.dart';
import 'package:zefir/widgets/number_picker.dart';
import 'dart:developer' as developer;
import 'package:zefir/services/eurus/eurus.dart';

class NewRoom extends StatefulWidget {
  @override
  _NewRoomState createState() => _NewRoomState();
}

class _NewRoomState extends State<NewRoom> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController numOfPlayersController = new TextEditingController();
  TextEditingController numOfRoundsController = new TextEditingController();
  TextEditingController nameOfPlayerController = new TextEditingController();
  Eurus _eurus;
  String roomName;
  int numOfPlayers;
  int _numOfRounds;
  String _nameOfPlayer;

  _NewRoomState() {
    numOfPlayersController.addListener(() {
      numOfPlayers = int.parse(numOfPlayersController.text);
    });
    numOfRoundsController.addListener(() {
      _numOfRounds = int.parse(numOfRoundsController.text);
    });
    nameOfPlayerController.addListener(() {
      _nameOfPlayer = nameOfPlayerController.text.trim();
    });
  }

  @override
  Widget build(BuildContext ctx) {
    _eurus = Zefir.of(ctx).eurus;

    final numOfPlayersField = buildNumOfPlayersField(
        context: ctx, initialValue: 4, controller: numOfPlayersController);
    final numOfRoundsField = _buildNumOfRoundsField(
        context: ctx, initialValue: 3, controller: numOfRoundsController);
    final widgets = [
      _buildNameOfPlayerField(),
      buildRoomNameField(),
      numOfPlayersField,
      numOfRoundsField,
      _buildCreateRoomButton(ctx)
    ]
        .map((widget) => Padding(child: widget, padding: EdgeInsets.all(10)))
        .toList();

    return Scaffold(
        appBar: AppBar(title: Text('Załóż nowy pokój')),
        body: Form(
            key: _formKey,
            child: Column(
              children: widgets,
            )));
  }

  Widget _buildNameOfPlayerField() {
    return TextFormField(
      controller: nameOfPlayerController,
      decoration: InputDecoration(
          border: OutlineInputBorder(), labelText: 'Twoja nazwa'),
      validator: (value) {
        return value.isEmpty ? 'Wprowadź nazwę gracza' : null;
      },
    );
  }

  Widget buildNumOfPlayersField(
      {@required BuildContext context,
      @required int initialValue,
      @required TextEditingController controller}) {
    return new NumberPicker(
      context: context,
      initialValue: 4,
      controller: numOfPlayersController,
      labelText: 'Liczba graczy',
    );
  }

  Widget _buildNumOfRoundsField(
      {@required BuildContext context,
      @required int initialValue,
      @required TextEditingController controller}) {
    return new NumberPicker(
      context: context,
      initialValue: initialValue,
      minValue: 1,
      controller: controller,
      labelText: 'Liczba rund',
    );
  }

  Widget buildRoomNameField() {
    return TextFormField(
      onChanged: (String newVal) {
        roomName = newVal.trim();
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(), labelText: 'Nazwa pokoju'),
      validator: (value) {
        return value.isEmpty ? 'Wprowadź nazwę pokoju' : null;
      },
    );
  }

  Widget _buildCreateRoomButton(BuildContext ctx) {
    final button = RaisedButton(
        onPressed: () => _createRoom(ctx),
        color: Colors.green,
        textColor: Colors.white,
        child: Text('Załóż pokój'));

    return SizedBox(
      child: button,
      width: double.infinity,
    );
  }

  void _createRoom(BuildContext ctx) {
    bool isFormValid = _formKey.currentState.validate();
    if (isFormValid == false) {
      return;
    }

    final TokenStorage storage = Zefir.of(ctx).storage.token;
    _eurus
        .createNewRoom(storage,
            roomName: roomName,
            playerName: _nameOfPlayer,
            numOfPlayers: numOfPlayers,
            numOfRounds: _numOfRounds)
        .then((room) => _navigateToWaitForPlayersScreen(ctx, room))
        .catchError((err) => _showErrorDialog(ctx, err));
  }

  void _navigateToWaitForPlayersScreen(BuildContext ctx, Room room) {
    Navigator.pushReplacementNamed(ctx, '/waitForPlayers',
        arguments: WaitForPlayersRouteParams(room));
  }

  void _showErrorDialog(BuildContext ctx, Exception err) {
    showDialog(
        context: ctx,
        builder: (BuildContext _) {
          return AlertDialog(
            title: Text("Wystąpił błąd"),
            content:
                Text("Nie udało się utworzyć pokoju. Spróbuj ponownie później"),
          );
        });
  }
}
