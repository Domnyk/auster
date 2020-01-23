import 'package:sqflite/sqflite.dart';
import 'package:zefir/model/question.dart';

class QuestionStorage {
  final Future<Database> _database;

  QuestionStorage(this._database);

  Future<void> addAll(List<Question> questions) async {
    questions.forEach((q) async {
      await add(q);
    });
  }

  Future<void> add(Question question) async {
    final db = await _database;
    final Map<String, dynamic> params = {'question': question.content};

    await db.insert('questions', params);
  }
}
