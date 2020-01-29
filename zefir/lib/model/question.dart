class Question {
  final String content;
  final bool picked;

  static String format(String content) {
    String result =
        content.substring(0, 1).toUpperCase() + content.substring(1).trim();

    if (result.substring(result.length - 1) != '?') {
      result += '?';
    }

    return result;
  }

  Question(this.content, this.picked);

  Question.fromGraphQl(dynamic data)
      : content = data['content'],
        picked = data['picked'] == true;
}
