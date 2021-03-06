import 'package:flutter/material.dart';
import 'package:zefir/model/room.dart';
import 'package:zefir/screens/room/wait_for_players_screen.dart';
import 'package:zefir/services/storage/token.dart';
import 'package:zefir/widgets/number_picker.dart';
import 'package:zefir/services/eurus/eurus.dart';
import 'package:zefir/zefir.dart';
import 'dart:developer' as developer;

class NewRoomScreen extends StatefulWidget {
  final Eurus _eurus;

  NewRoomScreen(this._eurus);

  @override
  _NewRoomScreenState createState() => _NewRoomScreenState(_eurus);
}

class _NewRoomScreenState extends State<NewRoomScreen> {
  static const String _createRoomText = 'Załóż pokój';

  final _formKey = GlobalKey<FormState>();
  final Eurus _eurus;

  TextEditingController numOfPlayersController = new TextEditingController();
  TextEditingController numOfRoundsController = new TextEditingController();
  TextEditingController nameOfPlayerController = new TextEditingController();

  String roomName;
  int numOfPlayers;
  int _numOfRounds;
  String _nameOfPlayer;

  _NewRoomScreenState(this._eurus) {
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
    // _eurus = Zefir.of(ctx).eurus;

    final numOfPlayersField = buildNumOfPlayersField(
        context: ctx, initialValue: 4, controller: numOfPlayersController);
    final numOfRoundsField = _buildNumOfRoundsField(
        context: ctx, initialValue: 3, controller: numOfRoundsController);
    final widgets = [
      Column(
        children: [
          _buildNameOfPlayerField(),
          buildRoomNameField(),
          numOfPlayersField,
          numOfRoundsField,
        ]
            .map(
                (widget) => Padding(child: widget, padding: EdgeInsets.all(10)))
            .toList(),
      ),
      Padding(
          child: _buildJoinRoomButton(ctx),
          padding: EdgeInsets.fromLTRB(15, 0, 15, 15)),
    ];

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text('Załóż nowy pokój')),
        body: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widgets,
            )));
  }

  Widget _buildNameOfPlayerField() {
    return TextFormField(
      controller: nameOfPlayerController,
      decoration: InputDecoration(labelText: 'Twoja nazwa'),
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
      decoration: InputDecoration(labelText: 'Nazwa pokoju'),
      validator: (value) {
        return value.isEmpty ? 'Wprowadź nazwę pokoju' : null;
      },
    );
  }

  Widget _buildJoinRoomButton(BuildContext ctx) {
    return RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      child: Text(_createRoomText),
      onPressed: () => _createRoom(ctx),
    );
  }

  void _createRoom(BuildContext ctx) {
    bool isFormValid = _formKey.currentState.validate();
    if (isFormValid == false) {
      return;
    }

    final TokenStorage storage = Zefir.of(ctx).eurus.storage.token;
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
        arguments: WaitForPlayersRouteParams(room, _eurus));
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

class NewRoomRouteParams {
  final Eurus eurus;

  NewRoomRouteParams(this.eurus);
}
