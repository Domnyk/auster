import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:zefir/model/room.dart';

typedef ErrorBuilder = Widget Function(
    BuildContext context, OperationException exception);

typedef LoadingBuilder = Widget Function(BuildContext context);

typedef RoomBuilder = Widget Function(BuildContext context, Room room);
