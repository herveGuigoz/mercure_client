import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'mercure_error.dart';
import 'mercure_event.dart';

/// {@template mercure_client.MercureRequest}
/// A class that make http GET request to Mercure hub.
/// {@endtemplate}
abstract class MercureRequest {
  /// {@macro mercure_client.MercureRequest}
  MercureRequest({
    required this.dio,
    required this.url,
    required this.topic,
    this.token,
    this.lastEventId,
  });

  /// http client
  final Dio dio;

  /// URL exposed by a hub to receive updates from one or many topics.
  final String url;

  /// An expression matching one or several topics
  // todo(_topics) list of topics.
  final String topic;

  /// Authorization HTTP header
  final String? token;

  /// The identifier of the last event dispatched by the publisher
  /// at the time of the generation of this resource.
  String? lastEventId;

  /// Util to parse Unit8List to MercureEvent
  final buffer = StringBuffer();

  /// Regex to find end of MercureEvent
  static const String _kEndOfMessage = '\r\n\r\n|\n\n|\r\r';

  /// Make GET request to Mercure Hub and transform the Unit8List stream to
  /// Mercure Event stream
  Future<Stream<MercureEvent>> connect() async {
    final headers = <String, Object>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (lastEventId != null) {
      headers['Last-Event-ID'] = lastEventId!;
    }

    Response<ResponseBody> response;

    try {
      response = await dio.get<ResponseBody>(
        url,
        queryParameters: <String, String>{'topic': topic},
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
        ),
      );
    } on DioError catch (e) {
      throw MercureError(response: e.response, error: e.error);
    }

    if (response.statusCode != 200) {
      throw MercureError(
        response: response,
        error: 'Connection failed with ${response.statusCode} status code.',
      );
    }

    final stream = response.data!.stream.transform<MercureEvent>(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          final raw = utf8.decode(data, allowMalformed: true);

          if (raw.isEmpty) {
            return;
          }

          buffer.write(raw);

          if (RegExp(_kEndOfMessage).hasMatch(raw)) {
            final event = MercureEvent.parse(buffer.toString());
            lastEventId = event.id;
            buffer.clear();
            sink.add(event);
          }
        },
        handleError: (err, _, sink) => sink.addError(err, _),
      ),
    );

    return stream;
  }
}
