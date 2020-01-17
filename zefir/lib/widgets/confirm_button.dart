import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConfirmButton extends StatelessWidget {
  final String _text;
  final _onPressed;

  const ConfirmButton({@required String text, @required onPressed})
      : _text = text,
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: RaisedButton(
        child: Text(_text),
        onPressed: () => _onPressed(),
        color: Colors.green,
        textColor: Colors.white,
      ),
      width: double.infinity,
    );
  }
}
