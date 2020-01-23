import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefir/model/question.dart';

class SaveQuestionsScreen extends StatefulWidget {
  static const String _appBarTitle = 'Zapisz pytania';

  final List<Question> _questions;

  const SaveQuestionsScreen(this._questions);

  @override
  _SaveQuestionsScreenState createState() =>
      _SaveQuestionsScreenState(_questions);
}

class _SaveQuestionsScreenState extends State<SaveQuestionsScreen> {
  final List<Question> _questions;
  List<bool> _isSelected;

  _SaveQuestionsScreenState(this._questions);

  @override
  void initState() {
    _isSelected = List.filled(_questions.length, false);
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(
          title: Text(SaveQuestionsScreen._appBarTitle),
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildNumOfQuestionsSelected(ctx),
            Expanded(child: _buildListOfQuestions(ctx)),
            SizedBox(width: double.infinity, child: _buildSaveButton(ctx))
          ],
        ));
  }

  Widget _buildNumOfQuestionsSelected(BuildContext ctx) {
    final int numOfQuestionsSelected = _calculateNumOfSelected();
    final String content = 'Liczba wybranych pytań: $numOfQuestionsSelected';

    Text title = Text(content,
        style: TextStyle(
            color: Colors.white,
            fontSize: Theme.of(ctx).textTheme.subhead.fontSize));

    return Container(
      color: Colors.blue.shade500,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: title,
          )
        ],
      ),
    );
  }

  Widget _buildListOfQuestions(BuildContext ctx) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget._questions.length,
        itemBuilder: (context, index) {
          return _Question(this._questions[index], this._isSelected[index],
              (bool val) {
            setState(() {
              this._isSelected[index] = !this._isSelected[index];
            });
          });
        });
  }

  Widget _buildSaveButton(BuildContext ctx) {
    return RaisedButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      color: Colors.green,
      textColor: Colors.white,
      child: Text('Dodaj'),
      onPressed: () {},
    );
  }

  int _calculateNumOfSelected() {
    return _isSelected
        .map((selected) => selected ? 1 : 0)
        .reduce((acc, elem) => acc + elem);
  }
}

class _Question extends StatelessWidget {
  final Question _question;
  final bool _isSelected;
  final Function _onChanged;

  const _Question(this._question, this._isSelected, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        title: Text(_question.content),
        value: _isSelected,
        onChanged: _onChanged);
  }
}

class SaveQuestionsRouteParams {
  final List<Question> questions;

  const SaveQuestionsRouteParams(this.questions);
}
