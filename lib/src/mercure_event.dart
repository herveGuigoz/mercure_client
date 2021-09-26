import 'dart:convert';

import 'mercure_error.dart';

/// {@template mercure_client.MercureEvent}
/// A class that allows building a [MercureEvent] from Server-Sent-Events.
/// {@endtemplate}
class MercureEvent {
  /// {@macro mercure_client.MercureEvent}
  factory MercureEvent.parse(String raw) {
    String? eventType;
    String? data;
    String? id;
    int? retry;

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
          eventType = value;
          break;
        case 'data':
          data = '$data$value\n';
          break;
        case 'id':
          id = value;
          break;
        case 'retry':
          retry = int.parse(value);
          break;
        default:
          // The field is ignored.
          continue;
      }
    }

    return MercureEvent._(id, data, eventType, retry);
  }

  MercureEvent._(
    String? id,
    String? data,
    String? eventType,
    int? retry,
  )   : _id = id ?? '',
        _data = data ?? '',
        _eventType = eventType ?? 'message',
        _retry = retry ?? 0;

  final String _id;
  final String _data;
  final String _eventType;
  final int _retry;

  /// The SSE's id property
  String get id => _id;

  /// The SSE's event content
  String get data => _data;

  /// The SSE's event property (a specific event type)
  String get eventType => _eventType;

  /// The SSE's retry property (the reconnection time)
  int? get retry => _retry;
}
