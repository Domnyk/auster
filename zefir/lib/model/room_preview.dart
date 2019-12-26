import 'package:flutter/foundation.dart';
import 'package:zefir/model/room_state.dart';

class RoomPreview {
  String _name;
  RoomState _state;

  String get name => _name;
  RoomState get state => _state;

  RoomPreview({@required String name, @required RoomState roomState})
      : _name = name,
        _state = roomState;

  RoomPreview.parse(final Map<String, dynamic> data) {
    _name = data['name'];
    _state = RoomStateParser.parse(data['state']);
  }

  @override
  String toString() {
    return 'RoomPreview[name=$_name, state=${_state.toString()}]';
  }
}
