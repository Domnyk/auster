class Answer {
  final int id;
  final String content;

  Answer.fromGraphQl(dynamic data)
      : id = int.parse(data['id'], radix: 10),
        content = data['content'];
}
