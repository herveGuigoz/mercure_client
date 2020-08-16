import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'mercure_error.dart';
import 'mercure_event.dart';

const String _kEndOfMessage = '/\r\n\r\n|\n\n|\r\r/';

/// {@template mercure_client.MercureClient}
/// A class that allows subscribing to a Mercure hub to get updates from
/// by using one or several query parameters named topic.
/// {@endtemplate}
abstract class MercureClient {
  /// {@macro mercure_client.MercureClient}
  MercureClient(
    this._url,
    this._topic,
    this._dio, {
    String token,
    String lastId,
  })  : _token = token,
        _lastId = lastId,
        assert(_url != null, 'mercure hub must be provided'),
        assert(_topic != null, 'topic must be provided'),
        assert(_dio != null, 'http client must be provided');

  // http client
  final Dio _dio;

  /// URL exposed by a hub to receive updates from one or many topics.
  final String _url;

  /// An expression matching one or several topics
  // todo(_topics) list of topics.
  final String _topic;

  /// Authorization HTTP header
  final String _token;

  /// The identifier of the last event dispatched by the publisher
  /// at the time of the generation of this resource.
  String _lastId;

  /// Stream of [MercureEvent]
  final _controller = StreamController<MercureEvent>.broadcast();

  /// Subscribe to Server-Sent-Events
  Future<void> _connect() async {
    final headers = <String, Object>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    if (_lastId != null) {
      headers['Last-Event-ID'] = _lastId;
    }

    Response<ResponseBody> response;

    try {
      response = await _dio.get<ResponseBody>(
        _url,
        queryParameters: <String, String>{'topic': _topic},
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
        ), // set responseType to `stream`
      );
    } on DioError catch (e) {
      _controller.addError(MercureError(response: e.response, error: e.error));
    }

    if (response.statusCode == 204) {
      _controller.addError(MercureError(
        response: response,
        error: 'Server forbid connection retry by responding 204 status code.',
      ));
    }

    utf8.decoder.bind(response.data.stream).listen((raw) {
      if (raw.isEmpty) {
        return;
      }

      if (RegExp(_kEndOfMessage).hasMatch(raw)) {
        try {
          final event = MercureEvent.parse(raw);
          _lastId = event.id;
          _controller.add(event);
        } on MercureError catch (e) {
          _controller.addError(e);
        }
      }
    }).onDone(() async {
      if (!_controller.isClosed && _controller.hasListener) {
        await _connect();
      }
    });
  }

  /// Returns a [StreamSubscription] which handles events.
  StreamSubscription<MercureEvent> subscribe(
    void Function(MercureEvent) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    _connect();

    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Close [StreamController]
  @mustCallSuper
  Future<void> close() async {
    await _controller.close();
  }
}
