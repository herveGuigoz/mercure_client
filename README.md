Provide a quick way to publish and consume messages on [Mercure](https://github.com/dunglas/mercure).

## The features

This project use [Dio](https://pub.dev/packages/dio) as HTTP client for making get request and listen fo server side event.

### Consuming messages

```dart
import 'package:mercure_client/mercure_client.dart';

main() {
  final Mercure mercure = Mercure(
    'http://example.com/.well-known/mercure', // your mercure hub url
    '/books/{id}', // your mercure topic
  );

  mercure.subscribe((event) {
    print(event.data);
  });
}
```

### Publishing Messages

```dart
Mercure.publish(
  url: 'http://example.com/.well-known/mercure',
  topic: '/books',
  data: 'some data',
).then((response) {
  print(response.statusCode);
});
```