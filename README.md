Provide a quick way to publish and consume messages on [Mercure](https://github.com/dunglas/mercure).

## The features

This project use [Dio](https://pub.dev/packages/dio) as HTTP client for making get request and listen for server side event.

### Consuming messages

```dart
import 'package:mercure_client/mercure_client.dart';

main() async {
  final Mercure mercure = Mercure(
    url: 'http://example.com/.well-known/mercure', // your mercure hub url
    topics: ['/books/{id}'], // your mercure topic
  );

  await mercure.listen((event) {
    print(event.data);
  });
}
```
