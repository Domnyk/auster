import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  static const String _defaultConfirmation = 'Jesteś pewien?';
  static const String _defaultDescription =
      'Czy jesteś pewien, że chcesz to zrobić';

  final String _confirmation;
  final String _description;
  final Function _confirmationHandler;

  const ConfirmationDialogWidget(
      this._confirmation, this._description, this._confirmationHandler);

  @override
  Widget build(BuildContext ctx) {
    Widget dialog = AlertDialog(
      title: _buildTitle(ctx, _confirmation),
      content: _buildContent(ctx, _description),
      actions: _buildButtons(ctx),
    );

    return Theme(
      data: Theme.of(ctx),
      child: dialog,
    );
  }

  List<Widget> _buildButtons(BuildContext ctx) {
    return <Widget>[_buildConfirmButton(ctx), _buildCancelButton(ctx)];
  }

  Widget _buildCancelButton(BuildContext ctx) {
    return FlatButton(
      child: Text('Anuluj'),
      onPressed: () => Navigator.pop(ctx),
    );
  }

  Widget _buildConfirmButton(BuildContext ctx) {
    return FlatButton(
      child: Text('Potwierdź'),
      onPressed: _confirmationHandler,
    );
  }

  Widget _buildContent(BuildContext ctx, final String description) {
    return description.isNotEmpty
        ? Text(description)
        : Text(_defaultDescription);
  }

  Widget _buildTitle(BuildContext ctx, final String text) {
    return text.isNotEmpty ? Text(text) : Text(_defaultConfirmation);
  }
}
