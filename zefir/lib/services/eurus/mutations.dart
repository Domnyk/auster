class Mutations {
  static const String CREATE_NEW_ROOM = """
    mutation newRoom(\$name: String!, \$rounds: Int!, \$players: Int!) {
      newRoom(name: \$name, players: \$players, rounds: \$rounds) {
        joinCode,
      }
    }
  """;

  static const String JOIN_ROOM = """
  mutation joinRoomM(\$roomCode: String!, \$playerName: String!) {
    joinRoom(roomCode:\$roomCode, playerName:\$playerName) {
      name,
      token,
      room {
        name,
        joinCode,
        maxRounds,
        maxPlayers,
        currRound,
        currPlayer {
          name,
          token
        },
        currAnswers {
          id
        },
        currQuestion {
          content
        },
        state,
        players {
          name,
          token
        }
      }
    }
  }
  """;

  static const String ADD_QUESTION = """
  mutation AddQuestion(\$token: Int!, \$question: String!) {
    sendQuestion(token: \$token, content: \$question) {
      content,
      player { 
        name,
        token 
      }
    }
  }
  """;

  static const String SEND_ANSWER = """
  mutation sendAnswer(\$token:Int!, \$answer:String!) {
    sendAnswer(token: \$token, content: \$answer) {
      player {
        room {
          name,
          joinCode,
          maxRounds,
          maxPlayers,
          currRound,
          currPlayer {
            name,
            token
          },
          currAnswers {
            id,
            content
          },
          currQuestion {
            content
          },
          state,
          players {
            name,
            token,
            points
          }
        }
      }
    }
  }
  """;

  static const String POLL_ANSWER = """
  mutation chooseAnswer(\$token: Int!, \$answerId: Int!) {
    pollAnswer(token:\$token, answer: \$answerId) {
      id,
      content,
      question {
        content
      },
      player {
        room {
          name,
          joinCode,
          maxRounds,
          maxPlayers,
          currRound,
          currPlayer {
            name,
            token,
            points
          },
          currAnswers {
            id,
            content,
            player {
              name
            }
          },
          currQuestion {
            content,
            player {
              name
            }
          },
          state,
          players {
            name,
            token,
            points,
            polledAnswer {
              id,
              content
            }
          },
          allQuestions {
            content,
            picked
          }  
        }
      }
    }
  }
  """;
}
