import 'package:flutter/material.dart';
import 'package:zefir/services/eurus/exceptions/no_such_room_exception.dart';

class ErrorDialog {
  static Widget build(BuildContext ctx, Exception e) {
    Widget closeButton = FlatButton(
      child: Text('Zamknij'),
      onPressed: () => Navigator.pop(ctx),
    );

    Widget dialog = AlertDialog(
      title: _buildTitle(ctx, e),
      content: _buildContent(ctx, e),
      actions: <Widget>[closeButton],
    );

    return Theme(
      data: Theme.of(ctx),
      child: dialog,
    );
  }

  static Widget _buildTitle(BuildContext ctx, Exception e) {
    if (e is NoSuchRoomException) {
      return Text('Nie ma takiego pokoju');
    } else {
      return Text('Wystąpił błąd');
    }
  }

  static Widget _buildContent(BuildContext ctx, Exception e) {
    if (e is NoSuchRoomException) {
      return Text(
          'Kod ${e.roomCode} nie pasuje do żadnego pokoju. Sprawdź kod i spróbuj ponownie');
    } else {
      return Text('Wystąpił błąd. Zamknij to okno i spróbuj ponownie');
    }
  }
}
