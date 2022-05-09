import 'package:example/src/domain/authentication/authentication.dart';
import 'package:flutter/foundation.dart';

@immutable
class Message {
  const Message({required this.value, required this.author});

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      value: map['value'] as String,
      author: User.fromMap(map['author'] as Map<String, dynamic>),
    );
  }

  final String value;
  final User author;

  Map<String, Object> toMap() {
    return {'value': value, 'author': author.toMap()};
  }

  @override
  String toString() => 'Message(value: $value, author: $author)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message && other.value == value && other.author == author;
  }

  @override
  int get hashCode => value.hashCode ^ author.hashCode;
}
