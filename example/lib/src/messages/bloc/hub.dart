import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:mercure_client/mercure_client.dart';

class Hub {
  Hub({required this.url, required this.jwt}) {
    validateJwt();
  }

  final String url;

  final String jwt;

  Stream<MercureEvent> subscribe({required List<String> topics}) async* {
    final stream = Mercure(url: url, token: jwt, topics: topics);

    await for (final event in stream) {
      yield event;
    }
  }

  Future<void> publish({
    required Uri topic,
    required String data,
    bool private = false,
  }) async {
    await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'topic': topic.toString(), 'data': data, if (private) 'private ': 'on'},
    );
  }

  void validateJwt() {
    final isValid = RegExp(r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]*$').hasMatch(jwt);
    if (!isValid) {
      Error.throwWithStackTrace('The provided JWT is not valid.', StackTrace.current);
    }
  }
}
