import 'package:flutter/foundation.dart';
import 'package:zefir/model/room_state.dart';

class RoomPreview {
  String _name;
  RoomState _state;
  int _deviceToken; // Token of a player on which application is running

  String get name => _name;
  RoomState get state => _state;
  int get deviceToken => _deviceToken;

  RoomPreview({@required String name, @required RoomState roomState})
      : _name = name,
        _state = roomState;

  RoomPreview.parse(final Map<String, dynamic> data, int deviceToken) {
    _name = data['name'];
    _state = RoomStateParser.parse(data['state']);
    _deviceToken = deviceToken;
  }

  @override
  String toString() {
    return 'RoomPreview[name=$_name, state=${_state.toString()}]';
  }
}
