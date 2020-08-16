import 'package:mercure_client/mercure_client.dart';

void main() {
  final events = <MercureEvent>[];

  final mercure = Mercure(
    'http://example.com/.well-known/mercure', // your mercure hub url
    '/books/{id}', // your mercure topic
  );

  mercure.subscribe(events.add);

  /// Publish message to the hub
  // ignore: unused_element
  Future<void> publisher(Book book) async {
    await Mercure.publish<Book>(
      url: 'http://example.com/.well-known/mercure',
      topic: '/books',
      data: book.toString(),
    );
  }
}

class Book {
  Book(this.title);

  final String title;
}
