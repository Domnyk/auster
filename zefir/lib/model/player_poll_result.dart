class PlayerPollResult {
  final int pastPoints;
  final String question;
  final String correctAnswer;
  final String choosedAnswer;
  final bool wasOwner;

  PlayerPollResult(this.pastPoints, this.question, this.correctAnswer,
      this.choosedAnswer, this.wasOwner);
}
