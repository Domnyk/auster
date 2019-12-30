import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  static const String _defaultText = 'Proszę czekać, trwa pobieranie danych...';
  final String _text;

  const LoadingWidget({String text}) : _text = text;

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: null,
      body: _buildBody(ctx),
      backgroundColor: Colors.blue,
    );
  }

  Widget _buildBody(BuildContext ctx) {
    final spinner = _buildSpinner(ctx);
    final text = _buildText(ctx, _text == null ? _defaultText : _text);

    List<Widget> padded = [spinner, text]
        .map((w) => Padding(
              child: w,
              padding: EdgeInsets.all(10),
            ))
        .toList();

    return Column(
      children: padded,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _buildSpinner(BuildContext ctx) {
    return CircularProgressIndicator(
      backgroundColor: Colors.white,
      strokeWidth: 5,
    );
  }

  Widget _buildText(BuildContext ctx, String content) {
    TextTheme currentTheme = Theme.of(ctx).textTheme;

    return Text(
      content,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white, fontSize: currentTheme.headline.fontSize),
    );
  }
}
