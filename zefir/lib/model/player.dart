import 'package:zefir/model/answer.dart';

class Player {
  final int token;
  final String name;
  final int points;
  final Answer polledAnswer;

  Player(
    this.token,
    this.name,
    this.points,
    this.polledAnswer,
  );

  Player.fromGraphQl(Map<String, dynamic> data)
      : token = data['token'],
        name = data['name'],
        points = int.tryParse(data['points'].toString(), radix: 10),
        polledAnswer =
            data.containsKey('polledAnswer') && data['polledAnswer'] != null
                ? Answer.fromGraphQl(data['polledAnswer'])
                : null;

  @override
  String toString() {
    return 'Player[name=$name, token=$token, points=$points]';
  }
}
