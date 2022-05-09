import 'dart:async';
import 'dart:developer';
import 'dart:html';

import 'mercure.dart';
import 'mercure_error.dart';
import 'mercure_event.dart';

/// {@template mercure_client.mercure_client}
/// A class that allows subscibe and publish to Mercure hub using [EventSource]
/// interface.
/// https://html.spec.whatwg.org/multipage/server-sent-events.html#the-eventsource-interface
/// {@endtemplate}
class MercureClient extends Stream<MercureEvent> implements Mercure {
  /// {@macro mercure_client.mercure}
  MercureClient({
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

  /// Format request uri
  Uri get hubUri {
    final queryParameters = <String>[
      for (final topic in topics) 'topic=${Uri.encodeComponent(topic)}',
      if (token != null) 'authorization=$token',
      if (lastEventId != null) 'Last-Event-ID=$lastEventId',
    ].join('&');

    final uri = Uri.tryParse('$url?$queryParameters');

    if (uri == null || !uri.hasAbsolutePath || topics.isEmpty) {
      throw MercureException.request(url, topics);
    }

    return uri;
  }

  @override
  StreamSubscription<MercureEvent> listen(
    void Function(MercureEvent event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final eventSource = EventSourceController(hubUrl: hubUri.toString());

    return eventSource.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

/// {@template mercure_client.event_source_controller}
/// Build [EventSource] and subscribe to events.
/// {@endtemplate}
class EventSourceController {
  /// {@macro mercure_client.event_source_controller}
  EventSourceController({
    required this.hubUrl,
  })  : _eventSource = EventSource(hubUrl),
        _controller = StreamController<MercureEvent>(sync: true) {
    _subscriptions = [
      _eventSource.onOpen.listen(_onOpen),
      _eventSource.onError.listen(_onError),
      _eventSource.onMessage.listen(_onMessage),
    ];
    _controller
      ..onPause = _pause
      ..onResume = _resume
      ..onCancel = _cancel;
  }

  /// URL exposed by a hub to receive updates from one or many topics.
  final String hubUrl;

  final EventSource _eventSource;

  final StreamController<MercureEvent> _controller;

  /// Stream of [MercureEvent] from [EventSource].
  Stream<MercureEvent> get stream => _controller.stream;

  late final List<StreamSubscription> _subscriptions;

  void _onOpen(Event event) {
    log('Subscription opened at ${DateTime.now()}', name: 'Mercure');
  }

  void _onError(Event event) {
    // https://html.spec.whatwg.org/multipage/server-sent-events.html#sse-processing-model
    if (_eventSource.readyState == 2) {
      _controller.addError(MercureException.eventSource(hubUrl));
      _eventSource.close();
    } else {
      // The connection was closed and the user agent is reconnecting.
      log('Subscription closed at ${DateTime.now()}', name: 'Mercure');
    }
  }

  void _onMessage(MessageEvent event) {
    try {
      _controller.add(MercureEvent(
        id: event.lastEventId,
        data: event.data as String,
        type: event.type,
        retry: 0,
      ));
    } catch (error) {
      _controller.addError(MercureEventException(event.type));
    }
  }

  void _pause() {
    for (final subscription in _subscriptions) {
      subscription.pause();
    }
  }

  void _resume() {
    for (final subscription in _subscriptions) {
      subscription.resume();
    }
  }

  void _cancel() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _eventSource.close();
    _controller.close();
    log('Subscription closed at ${DateTime.now()}', name: 'Mercure');
  }
}
