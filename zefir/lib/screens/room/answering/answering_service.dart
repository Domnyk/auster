import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/services/eurus/mutations.dart';

class AnsweringSerice {
  static Stream<int> fakeStream() async* {
    const oneSec = const Duration(seconds: 1);
    yield 1;
  }

  static Widget buildSubmitButton(BuildContext ctx, int token, String answer) {
    return Mutation(
      options: _buildMutationOptions(ctx),
      builder: (RunMutation runMutation, QueryResult result) {
        return RaisedButton(
            onPressed: () {
              developer.log(
                  'Running mutation with token $token and answer: $answer');
              runMutation({'token': token, 'answer': answer});
              // stateStorage
              //     .update(token, RoomState.WAIT_FOR_OTHER_QUESTIONS)
              //     .then((_) => Navigator.of(ctx).pushNamed(
              //         '/waitForOtherQuestions',
              //         arguments: WaitForOtherQuestionsRouteParams(token)));
            },
            color: Colors.green,
            textColor: Colors.white,
            child: Text('Dodaj odpowiedź'));
      },
    );
  }

  static MutationOptions _buildMutationOptions(BuildContext ctx) {
    return MutationOptions(document: Mutations.SEND_ANSWER);
  }
}
