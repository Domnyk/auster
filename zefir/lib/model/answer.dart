class Answer {
  final int id;
  final String content;
  final int playerToken;

  Answer(this.id, this.content, this.playerToken);

  Answer.fromGraphQl(dynamic data)
      : id = int.parse(data['id'].toString(),
            radix: 10), // TODO: Without toStirng() it throws exception. WTF?
        content = data['content'],
        playerToken = null;

  Answer.fromGraphQlWithPlayerToken(dynamic data)
      : id = int.parse(data['id'].toString(),
            radix: 10), // TODO: Without toStirng() it throws exception. WTF?
        content = data['content'],
        playerToken = int.parse(data['player']['token'].toString(), radix: 10);
}
