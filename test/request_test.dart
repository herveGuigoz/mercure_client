import 'package:mercure_client/src/mercure_io.dart';
import 'package:test/test.dart';

void main() {
  const hub = 'https://localhost';

  group('#encoding', () {
    test('content type is text/event-stream', () {
      final request = MercureRequest('hub', ['*']);
      expect(request.headers['Accept'], equals('text/event-stream'));
    });

    test('Multiple topics query parameters', () {
      final request = MercureRequest.build(hub, ['a', 'b']);
      expect(request.toString(), equals('https://localhost?topic=a&topic=b'));
    });
  });
}
