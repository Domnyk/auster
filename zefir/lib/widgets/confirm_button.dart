import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConfirmButton extends StatelessWidget {
  final String _text;
  final _onPressed;
  final bool _isRaised;

  const ConfirmButton(
      {@required String text, @required onPressed, bool isRaised = true})
      : _text = text,
        _onPressed = onPressed,
        _isRaised = isRaised;

  @override
  Widget build(BuildContext context) {
    final btn = _isRaised
        ? RaisedButton(
            child: Text(_text),
            onPressed: () => _onPressed(),
            color: Colors.green,
            textColor: Colors.white,
          )
        : FlatButton(
            child: Text(_text),
            onPressed: () => _onPressed(),
            color: Colors.green,
            textColor: Colors.white);

    return SizedBox(child: btn);
  }
}
