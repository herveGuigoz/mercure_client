import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  }) : assert(topics.isNotEmpty, 'Missing topics');

  /// URL exposed by a hub to receive updates from one or many topics.
  final String url;

  /// An expression matching one or several topics
  final List<String> topics;

  /// Authorization HTTP header
  final String? token;

  /// The identifier of the last event dispatched by the publisher
  /// at the time of the generation of this resource.
  String? lastEventId;

  /// Util to parse Unit8List to MercureEvent
  final _buffer = StringBuffer();

  /// Regex to find end of MercureEvent
  static const String _kEndOfMessage = '\r\n\r\n|\n\n|\r\r';

  @override
  Stream<MercureEvent> _subscribe() async* {
    final request = await _createRequest();

    // Send the HTTP request
    final response = await request.close();

    // Check HTTP status
    if (response.statusCode != 200) {
      throw MercureException(response.statusCode, request.uri.toString());
    }

    // Check Content type
    final mime = response.headers.contentType?.mimeType;
    if ('text/event-stream' != mime) {
      throw ContentTypeException(mime!, request.uri.toString());
    }

    yield* response.transform<MercureEvent>(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          final raw = utf8.decode(data, allowMalformed: true);

          if (raw.isEmpty) {
            return;
          }

          _buffer.write(raw);

          if (RegExp(_kEndOfMessage).hasMatch(raw)) {
            final event = MercureEvent.parse(_buffer.toString());
            lastEventId = event.id;
            _buffer.clear();
            sink.add(event);
          }
        },
      ),
    );
  }

  Future<HttpClientRequest> _createRequest() async {
    final uri = Uri.parse(url).replace(
      queryParameters: <String, String>{
        for (final topic in topics) 'topic': topic
      },
    );
    // Create a HTTP request
    final httpClient = HttpClient();
    final httpRequest = await httpClient.getUrl(uri);
    httpRequest.headers.set('Accept', 'text/event-stream');
    httpRequest.headers.set('Cache-Control', 'no-cache');
    if (lastEventId != null) {
      httpRequest.headers.set('Last-Event-ID', lastEventId!);
    }

    return httpRequest;
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
      _controller.addError(error);
      _controller.close();
    }

    _subscription = _subscribe().listen(
      _controller.add,
      onError: onError,
      onDone: _retry,
      cancelOnError: false,
    );
  }
}
