import 'package:flutter/material.dart';
import 'package:zefir/number_picker.dart';
import 'dart:developer' as developer;
import 'package:zefir/services/eurus.dart';

class NewRoom extends StatefulWidget {
  final Eurus eurus;

  NewRoom(this.eurus);

  @override
  _NewRoomState createState() => _NewRoomState(eurus: eurus);
}

class _NewRoomState extends State<NewRoom> {
  TextEditingController numOfPlayersController = new TextEditingController();
  Eurus eurus;
  final _formKey = GlobalKey<FormState>();
  String roomName;
  int numOfPlayers;

  _NewRoomState({@required Eurus eurus}) {
    this.eurus = eurus;
    numOfPlayersController.addListener(() {
      numOfPlayers = int.parse(numOfPlayersController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    var numOfPlayersField = buildNumOfPlayersField(
            context: context,
            initialValue: 4,
            controller: numOfPlayersController),
        widgets = [buildNameField(), numOfPlayersField, buildCreateRoomButton()]
            .map(
                (widget) => Padding(child: widget, padding: EdgeInsets.all(10)))
            .toList();

    return Scaffold(
        appBar: AppBar(title: Text('Załóż nowy pokój')),
        body: Form(
            key: _formKey,
            child: Column(
              children: widgets,
            )));
  }

  Widget buildNumOfPlayersField(
      {@required BuildContext context,
      @required int initialValue,
      @required TextEditingController controller}) {
    return new NumberPicker(
      context: context,
      initialValue: 4,
      controller: numOfPlayersController,
    );
  }

  Widget buildNameField() {
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

  Widget buildCreateRoomButton() {
    var button = RaisedButton(
        onPressed: () {
          developer
              .log('Name of room: $roomName, num of players: $numOfPlayers');
          if (_formKey.currentState.validate()) {
            eurus.createNewRoom(name: roomName, numOfPlayers: numOfPlayers);
          }
        },
        color: Colors.green,
        textColor: Colors.white,
        child: Text('Załóż pokój'));

    return SizedBox(
      child: button,
      width: double.infinity,
    );
  }
}
