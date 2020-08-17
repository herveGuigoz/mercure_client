import 'dart:convert';

import 'package:mercure_client/mercure_client.dart';

void main() {
  final books = <Book>[];

  final mercure = Mercure(
    'http://example.com/.well-known/mercure', // your mercure hub url
    '/books/{id}', // your mercure topic
    token: 'your_jwt_token', // Bearer authorization
    lastEventId: 'last_event_id', // in case your stored last recieved event
    showLogs: true, // Default to false
  );

  /// Subscribe to mercure hub
  mercure.subscribe((event) {
    books.add(Book.fromJson(json.decode(event.data) as Map<String, Object>));
  });

  /// Publish message to the hub
  // ignore: unused_element
  Future<void> publisher(Book book) async {
    await Mercure.publish<Book>(
      url: 'http://example.com/.well-known/mercure',
      topic: '/books',
      data: json.encode(book.toJson()),
    );
  }
}

class Book {
  Book(this.id, this.title);

  factory Book.fromJson(Map<String, Object> json) {
    return Book(
      json['id'] as int,
      json['title'] as String,
    );
  }

  final int id;
  final String title;

  Map<String, Object> toJson() => <String, Object>{'id': id, 'title': title};
}
