class Player {
  final int token;
  final String name;
  final int points;
  // TODO: Add polled answers field

  Player(
    this.token,
    this.name,
    this.points,
  );

  Player.fromGraphQl(dynamic data)
      : token = data['token'],
        name = data['name'],
        points = data['points'];

  @override
  String toString() {
    return 'Player[name=$name, token=$token, points=$points]';
  }
}
