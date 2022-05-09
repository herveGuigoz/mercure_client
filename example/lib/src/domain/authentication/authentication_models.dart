import 'package:flutter/foundation.dart';

@immutable
class User {
  const User({required this.id, required this.username});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'] as String, username: map['username'] as String);
  }

  final String id;
  final String username;

  Map<String, Object> toMap() => {'id': id, 'username': username};

  @override
  String toString() => 'User(id: $id, username: $username)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id && other.username == username;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode;
}
