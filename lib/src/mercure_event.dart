import 'dart:convert';

import 'package:mercure_client/src/mercure_error.dart';

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
  factory MercureEvent.raw(String raw) {
    var id = '';
    var data = '';
    var type = 'message';
    var retry = 0;

    final pattern = RegExp(r'^(?<key>[^:]*)(?::)?(?:)?(?<value>.*)?$');
    final lines = const LineSplitter().convert(raw);

    for (final line in lines) {
      final matches = pattern.firstMatch(line);

      if (matches == null) {
        throw MercureEventException(line);
      }

      final key = matches.namedGroup('key');
      final value = (matches.namedGroup('value') ?? '').trim();

      if (key == null || key.isEmpty) {
        continue;
      }

      switch (key) {
        case 'event':
          type = value;
        case 'data':
          data = '$data$value';
        case 'id':
          id = value;
        case 'retry':
          retry = int.parse(value);
        default:
          // The field is ignored.
          continue;
      }
    }

    return MercureEvent(id: id, data: data, type: type, retry: retry);
  }

  /// The SSE's id property
  final String id;

  /// The SSE's event content
  final String data;

  /// The SSE's event property (a specific event type)
  final String type;

  /// The SSE's retry property (the reconnection time)
  final int retry;

  @override
  String toString() {
    return 'MercureEvent(id: $id, data: $data, type: $type, retry: $retry)';
  }
}
