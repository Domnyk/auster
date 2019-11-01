import 'package:flutter/material.dart';
import 'package:zefir/room_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EGO mobile',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'EGO mobile'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: RaisedButton(
          child: Text('Przejdź do listy repozytoriów!'),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => RoomList()));
          },
        )));
  }
}
