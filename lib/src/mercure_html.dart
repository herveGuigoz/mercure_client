import 'dart:async';
import 'dart:developer';
import 'dart:html';

import 'mercure_error.dart';
import 'mercure_event.dart';

/// {@template mercure_client.mercure}
/// A class that allows subscibe and publish to Mercure hub.
/// {@endtemplate}
class Mercure extends RetryStream<MercureEvent> {
  /// {@macro mercure_client.mercure}
  Mercure({
    required this.url,
    required this.topics,
    this.token,
    this.lastEventId,
  });

  /// URL exposed by a hub to receive updates from one or many topics.
  final String url;

  /// Expressions matching one or several topics
  final List<String> topics;

  /// Subscriber JWS
  final String? token;

  /// The identifier of the last event dispatched by the publisher
  /// at the time of the generation of this resource.
  String? lastEventId;

  @override
  Stream<MercureEvent> _subscribe() {
    final sc = StreamController<MercureEvent>();

    final topicsPart =
        topics.map((e) => 'topic=${Uri.encodeComponent(e)}').join('&');

    final fullUrl = '$url?$topicsPart';

    final es = EventSource(fullUrl);

    es.onMessage.listen((event) {
      final mercureEvent = MercureEvent.createFromParts(
          id: '', data: event.data as String, type: event.type, retry: 0);
      sc.add(mercureEvent);
    }, cancelOnError: true);

    es.onError.listen((event) {
      sc.addError(event);

      // is EventSource is closed, dispose everything
      if (es.readyState == 2) {
        // close stream
        sc.close();
        es.close();
      }
    }, cancelOnError: true);

    return sc.stream;
  }
}

/// Creates a [Stream] that will recreate and re-listen to the source
/// [Stream].
abstract class RetryStream<T> extends Stream<T> {
  late final StreamController<T> _controller = StreamController<T>(
    sync: true,
    onListen: _retry,
    onPause: () => _subscription!.pause(),
    onResume: () => _subscription!.resume(),
    onCancel: () {
      return _subscription?.cancel();
    },
  );

  StreamSubscription<void>? _subscription;

  /// The Stream used at subscription time
  Stream<T> _subscribe();

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void _retry() {
    void onError(Object error, StackTrace stacktrace) {
      _subscription!.cancel();
      _subscription = null;
      if (error is MercureException) {
        _controller.addError(error);
        _controller.close();
      } else {
        log('Mercure: $error');
        _retry();
      }
    }

    log('Mercure: Subscription opened at ${DateTime.now()}');

    _subscription = _subscribe().listen(
      _controller.add,
      onError: onError,
      onDone: _retry,
      cancelOnError: false,
    );
  }
}
