import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'mercure_event.dart';
import 'mercure_request.dart';

/// {@template mercure_client.MercureClient}
/// A class that allows subscribing to a Mercure hub to get updates from
/// by using one or several query parameters named topic.
/// {@endtemplate}
abstract class MercureClient extends MercureRequest {
  /// {@macro mercure_client.MercureClient}
  MercureClient(
    String url,
    String topic,
    Dio dio, {
    String token,
    String lastEventId,
  })  : assert(url != null, 'mercure hub must be provided'),
        assert(topic != null, 'topic must be provided'),
        assert(dio != null, 'http client must be provided'),
        super(
          dio: dio,
          url: url,
          topic: topic,
          token: token,
          lastEventId: lastEventId,
        );

  /// Stream of [MercureEvent]
  StreamSubscription<MercureEvent> _subscription;

  /// Returns a [StreamSubscription] which handles events.
  Future<StreamSubscription<MercureEvent>> subscribe(
    void Function(MercureEvent) onData, {
    Function onError,
    bool cancelOnError,
  }) async {
    await _subscription?.cancel();

    try {
      final response = await connect();

      _subscription = response.listen(
        onData,
        onDone: () async => subscribe(
          onData,
          onError: onError,
          cancelOnError: cancelOnError,
        ),
        onError: onError,
        cancelOnError: cancelOnError ?? true,
      );
    } catch (err) {
      onError(err);
    }

    return _subscription;
  }

  /// Close [StreamController]
  @mustCallSuper
  Future<void> close() async {
    await _subscription?.cancel();
  }
}
