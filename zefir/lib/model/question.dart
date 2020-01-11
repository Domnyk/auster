class Question {
  final String content;
  final bool picked;

  Question.fromGraphQl(dynamic data)
      : content = data['content'],
        picked = data['picked'] == true;
}
