import 'package:flutter/material.dart';

class NewRoom extends StatefulWidget {
  @override
  _NewRoomState createState() => _NewRoomState();
}

class _NewRoomState extends State<NewRoom> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var nameField = buildNameField();

    return Scaffold(
        appBar: AppBar(title: Text('Załóż nowy pokój')),
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              nameField,
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Załóż pokój'),
              )
            ],
          ),
        ));
  }

  TextFormField buildNameField() {
    return TextFormField(
      validator: (value) {
        return value.isEmpty ? 'Wprowadź nazwę pokoju' : null;
      },
    );
  }
}
