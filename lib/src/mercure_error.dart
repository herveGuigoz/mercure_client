/// {@template mercure_client.mercure_exception}
/// Exception when response failed with bad status code.
/// {@endtemplate}
class MercureException implements Exception {
  /// {@macro mercure_client.mercure_exception}
  MercureException(this.statusCode, this.uri);

  /// The response status code
  final int statusCode;

  /// The request uri
  final String uri;

  @override
  String toString() {
    return 'Connection failed with $statusCode status code for $uri';
  }
}

/// {@template mercure_client.content_type_exception}
/// Exception when response return unexpected content type header.
/// {@endtemplate}
class ContentTypeException implements Exception {
  /// {@macro mercure_client.content_type_exception}
  const ContentTypeException(this.contentType, this.uri);

  /// The actual content type header returned by the response.
  final String contentType;

  /// The request uri
  final String uri;

  @override
  String toString() {
    return 'Response content-type is $contentType while "text/event-stream" was expected for $uri';
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
    return 'Invalid event $event';
  }
}
