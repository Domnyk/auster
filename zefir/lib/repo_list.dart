import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RepoList extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista repozytoriów'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Powrót do ekranu głównego')
        )
      )
    );
  }

}
