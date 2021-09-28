import 'dart:convert';

import 'package:mercure_client/src/mercure.dart';
import 'package:test/test.dart';

void main() {
  group('#encoding', () {
    test('content type is text/event-stream', () {
      final request = MercureRequest('hub', ['*']);
      expect(request.headers['Accept'], equals('text/event-stream'));
    });
  });
}
