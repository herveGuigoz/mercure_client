import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'mercure_client.dart';

/// {@template mercure_client.Mercure}
/// A class that allows subscibe and publish to Mercure hub.
/// {@endtemplate}
class Mercure extends MercureClient {
  /// {@macro mercure_client.Mercure}
  Mercure(
    String url,
    String topic, {
    String token,
    String lastEventId,
    bool showLogs = false,
  }) : super(url, topic, _client, token: token, lastId: lastEventId) {
    if (showLogs) {
      _client.interceptors.add(LogInterceptor());
    }
  }

  /// Http client
  static final Dio _client = Dio();

  /// Publish data in mercure hub for given topic
  static Future<Response<T>> publish<T>({
    @required String url,
    @required String topic,
    @required String data,
  }) async {
    final response = await _client.post<T>(url, data: {
      'topic': topic,
      'data': data,
    });

    return response;
  }
}
