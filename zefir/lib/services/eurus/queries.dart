class Queries {
  static const String FETCH_ROOM = """
  query fetchRoom(\$token: Int!) {
    player(token: \$token) {
      room {
        name,
        joinCode,
        maxRounds,
        maxPlayers,
        currRound,
        currPlayer {
          name,
          points,
          token
        },
        currAnswers {
          id,
          content,
          player {
            token
          }
        },
        currQuestion {
          content
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
  """;

  static const String FETCH_PLAYERS = """
  query fetchPlayers(\$token: Int!) {
    player(token: \$token) {
      room {
        players {
          name
        }
      }
    }
  }  
  """;

  static const String FETCH_ROOM_PREVIEW = """
  query fetchRoom(\$token: Int!) {
    player(token: \$token) {
      room {
        name,
        state
      }
    }
  }
  """;

  static const String FEETCH_ROOM_STATE = """
  query fetchRoom(\$token: Int!) {
    player(token: \$token) {
      room {
        state
      }
    }
  }
  """;
}
