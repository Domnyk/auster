import 'package:flutter/material.dart';
import 'package:zefir/screens/wait_for_players.dart';
import 'package:zefir/widgets/number_picker.dart';
import 'dart:developer' as developer;
import 'package:zefir/services/eurus/eurus.dart';

class NewRoom extends StatefulWidget {
  final Eurus eurus;

  NewRoom(this.eurus);

  @override
  _NewRoomState createState() => _NewRoomState(eurus: eurus);
}

class _NewRoomState extends State<NewRoom> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController numOfPlayersController = new TextEditingController();
  TextEditingController numOfRoundsController = new TextEditingController();
  TextEditingController nameOfPlayerController = new TextEditingController();
  Eurus eurus;
  String roomName;
  int numOfPlayers;
  int _numOfRounds;
  String _nameOfPlayer;

  _NewRoomState({@required Eurus eurus}) {
    this.eurus = eurus;

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

    eurus
        .createNewRoom(
            roomName: roomName,
            playerName: _nameOfPlayer,
            numOfPlayers: numOfPlayers,
            numOfRounds: _numOfRounds)
        .then((_) => _navigateToWaitForPlayersScreen(ctx))
        .catchError((err) => _showErrorDialog(ctx, err));
  }

  void _navigateToWaitForPlayersScreen(BuildContext ctx) {
    Navigator.push(
        ctx, MaterialPageRoute(builder: (context) => WaitForPlayers()));
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
