import 'package:dio/dio.dart';

/// {@template mercure_client.MercureClient}
/// Exception when request failed or for malformed event.
/// {@endtemplate}
class MercureError implements Exception {
  /// {@macro mercure_client.MercureError}
  MercureError({
    this.response,
    this.error,
  });

  /// Response info, it may be `null` if the request can't reach to
  /// the http server, for example, occurring a dns error, network is not available.
  Response response;

  /// The error/exception object
  dynamic error;
}
