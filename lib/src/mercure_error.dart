import 'package:http/http.dart';

/// {@template mercure_client.mercure_exception}
/// Exception that will skill retry feature.
/// {@endtemplate}
abstract class MercureException implements Exception {
  /// {@macro mercure_client.mercure_exception}
  const MercureException();

  /// Exception when request contains empty topics list or malformed url.
  factory MercureException.request(
    Uri uri,
    List<String> topics,
  ) = MercureRequestException;

  /// Exception when response failed with bad status code.
  factory MercureException.statusCode(
    StreamedResponse response,
  ) = MercureResponseException;

  /// Exception when response return unexpected content type header.
  factory MercureException.contentType(
    StreamedResponse response,
  ) = MercureContentTypeException;
}

/// {@template mercure_client.mercure_request_exception}
/// Exception that will be thrown if topics list is empty or uri is malformed.
/// {@endtemplate}
class MercureRequestException extends MercureException {
  /// {@macro mercure_client.mercure_request_exception}
  MercureRequestException(this.uri, this.topics);

  /// Parsed uniform resource identifier
  final Uri uri;

  /// Expressions matching one or several topics
  final List<String> topics;

  @override
  String toString() {
    if (topics.isEmpty) {
      return 'Missing one or many expression matching one or several topics';
    }
    return 'Mercure: Malformed Uniform Resource Identifier (URI): $uri';
  }
}

/// {@template mercure_client.mercure_response_exception}
/// Exception when response failed with bad status code.
/// {@endtemplate}
class MercureResponseException extends MercureException {
  /// {@macro mercure_client.mercure_response_exception}
  const MercureResponseException(this.response);

  /// The response returned by the server.
  final StreamedResponse response;

  /// The response status code
  int get statusCode => response.statusCode;

  /// The request uri
  String get uri => response.request!.url.toString();

  @override
  String toString() {
    return 'Mercure: Connection failed with $statusCode status code for $uri';
  }
}

/// {@template mercure_client.mercure_content_type_exception}
/// Exception when response return unexpected content type header.
/// {@endtemplate}
class MercureContentTypeException extends MercureException {
  /// {@macro mercure_client.mercure_content_type_exception}
  MercureContentTypeException(this.response);

  /// The response returned by the server.
  final StreamedResponse response;

  /// The actual content type header returned by the response.
  String get contentType => response.headers['content-type'] ?? '';

  /// The request uri
  String get uri => response.request!.url.toString();

  @override
  String toString() {
    return 'Mercure: Response content-type is $contentType while "text/event-stream" was expected for $uri';
  }
}

/// {@template mercure_client.mercure_event_excepion}
/// Exception when server returned malformed event.
/// {@endtemplate}
class MercureEventException implements Exception {
  /// {@macro mercure_client.mercure_event_excepion}
  MercureEventException(this.event);

  /// The event recieved by the server.
  final String event;

  @override
  String toString() {
    return 'Mercure: Invalid event $event';
  }
}
