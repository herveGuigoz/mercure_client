import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mercure_client/src/mercure.dart';
import 'package:mercure_client/src/mercure_error.dart';
import 'package:mercure_client/src/mercure_event.dart';

/// {@template mercure_client.mercure_client}
/// A class that allows subscibe and publish to Mercure hub.
/// {@endtemplate}
class MercureClient extends RetryStream<MercureEvent> implements Mercure {
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

  @override
  Stream<MercureEvent> subscribe() async* {
    final client = http.Client();

    try {
      final response = await client.send(
        MercureRequest(
          url,
          topics,
          authorization: token,
          lastEventId: lastEventId,
        ),
      );

      if (response.statusCode != 200) {
        throw MercureException.statusCode(response);
      }

      // Check Content type
      final mime = response.headers['content-type'] ?? '';
      if (!RegExp(r'^text\/event-stream(;|$)').hasMatch(mime)) {
        throw MercureException.contentType(response);
      }

      yield* response.stream.transform<MercureEvent>(_streamTransformer());
    } on HandshakeException catch (_) {
      log('Mercure: Handshake failed at ${DateTime.now()}');
      throw MercureException.eventSource(url);
    } on SocketException catch (_) {
      log('Mercure: Connection failed at ${DateTime.now()}');
      throw MercureException.eventSource(url);
    } on TimeoutException catch (_) {
      log('Mercure: Connection timeout at ${DateTime.now()}');
      throw MercureException.eventSource(url);
    } finally {
      log('Mercure: Subscription closed at ${DateTime.now()}');
      client.close();
    }
  }

  StreamTransformer<List<int>, MercureEvent> _streamTransformer() {
    return StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        final raw = utf8.decode(data, allowMalformed: true).trim();

        if (raw.isEmpty || raw.startsWith(':')) {
          return;
        }

        try {
          final event = MercureEvent.raw(raw);
          lastEventId = event.id;
          sink.add(event);
        } catch (error) {
          sink.addError(error);
        }
      },
    );
  }
}

/// {@template mercure_client.mercure}
/// Wrapper around [http.Request].
/// {@endtemplate}
class MercureRequest extends http.Request {
  /// {@macro mercure_client.mercurerequest}
  MercureRequest(
    String hub,
    List<String> topics, {
    this.authorization,
    this.lastEventId,
  }) : super('GET', build(hub, topics));

  /// Format request uri
  static Uri build(String hub, List<String> topics) {
    final queryParameters = <String>[
      for (final topic in topics) 'topic=${Uri.encodeComponent(topic)}',
    ].join('&');

    final uri = Uri.tryParse('$hub?$queryParameters');

    if (uri == null || !uri.hasAbsolutePath || topics.isEmpty) {
      throw MercureException.request(hub, topics);
    }

    return uri;
  }

  /// Types of data that can be sent back.
  static const accept = 'text/event-stream';

  /// Caching instructions
  static const cacheControl = 'no-cache';

  /// Authorization HTTP header.
  final String? authorization;

  /// Last event id provided by the hub
  final String? lastEventId;

  @override
  Map<String, String> get headers {
    return {
      'Accept': accept,
      'Cache-Control': cacheControl,
      if (authorization != null) 'Authorization': 'Bearer $authorization',
      if (lastEventId != null) 'Last-Event-ID': lastEventId!,
    };
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
    onCancel: () => _subscription?.cancel(),
  );

  StreamSubscription<void>? _subscription;

  /// The Stream used at subscription time
  Stream<T> subscribe();

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
        _controller
          ..addError(error)
          ..close();
      } else {
        log('Mercure: $error');
        _retry();
      }
    }

    log('Subscription opened at ${DateTime.now()}', name: 'Mercure');

    _subscription = subscribe().listen(
      _controller.add,
      onError: onError,
      onDone: _retry,
      cancelOnError: false,
    );
  }
}
