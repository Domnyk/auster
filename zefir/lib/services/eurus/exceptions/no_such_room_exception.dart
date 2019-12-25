import 'package:zefir/services/eurus/exceptions/game_exception.dart';

class NoSuchRoomException extends GameException {
  String cause;
  String roomCode;

  NoSuchRoomException(this.roomCode)
      : super('there is no room for which this code matches: ' + roomCode);
  NoSuchRoomException.withCustomMsg(this.cause) : super(cause);
}
