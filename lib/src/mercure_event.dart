import 'dart:convert';

import 'mercure_error.dart';

/// {@template mercure_client.MercureEvent}
/// A class that allows building a [MercureEvent] from Server-Sent-Events.
/// {@endtemplate}
class MercureEvent {
  /// {@macro mercure_client.MercureEvent}
  MercureEvent({
    required this.id,
    required this.data,
    required this.type,
    required this.retry,
  });

  /// {@macro mercure_client.MercureEvent}
  MercureEvent.raw(String raw) {
    var _id = '', _data = '', _type = 'message', _retry = 0;

    final _pattern = RegExp(r'^(?<name>[^:]*)(?::)?(?: )?(?<value>.*)?$');
    final lines = const LineSplitter().convert(raw);

    for (final line in lines) {
      final matches = _pattern.firstMatch(line);

      if (matches == null) {
        throw MercureEventException(line);
      }

      final name = matches.namedGroup('name');
      final value = matches.namedGroup('value') ?? '';

      if (name == null || name.isEmpty) {
        continue;
      }

      switch (name) {
        case 'event':
          _type = value;
          break;
        case 'data':
          _data = '$_data$value\n';
          break;
        case 'id':
          _id = value;
          break;
        case 'retry':
          _retry = int.parse(value);
          break;
        default:
          // The field is ignored.
          continue;
      }
    }

    id = _id;
    data = _data;
    type = _type;
    retry = _retry;
  }

  /// The SSE's id property
  late final String id;

  /// The SSE's event content
  late final String data;

  /// The SSE's event property (a specific event type)
  late final String type;

  /// The SSE's retry property (the reconnection time)
  late final int retry;

  @override
  String toString() {
    return 'MercureEvent(id: $id, data: $data, type: $type, retry: $retry)';
  }
}