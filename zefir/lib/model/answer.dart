class Answer {
  final int id;
  final String content;

  Answer(this.id, this.content);

  Answer.fromGraphQl(dynamic data)
      : id = int.parse(data['id'].toString(),
            radix: 10), // TODO: Without toStirng() it throws exception. WTF?
        content = data['content'];
}
