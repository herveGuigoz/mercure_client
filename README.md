
## The features

Provide a quick way to publish and consume messages on [Mercure](https://github.com/dunglas/mercure).

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
