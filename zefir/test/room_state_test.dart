import 'package:test/test.dart';
import 'package:zefir/model/room_state.dart';

void main() {
  group('RoomStateParser', () {
    group('merge()', () {
      test('mergin ANSWERING with WAIT_FOR_POLL', () {
        RoomState fromBackend = RoomState.ANSWERING;
        RoomState fromDb = RoomState.WAIT_FOR_OTHER_POLLS;
        RoomState expectedResult = RoomState.WAIT_FOR_OTHER_POLLS;

        RoomState actualResult = RoomStateUtils.merge(fromDb, fromBackend);

        expect(actualResult == expectedResult, isTrue);
      });
    });
  });
}
