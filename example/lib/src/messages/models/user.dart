part of 'models.dart';

class User extends Equatable {
  const User({required this.id, required this.username});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'] as String, username: map['username'] as String);
  }

  final String id;
  final String username;

  Map<String, Object> toMap() => {'id': id, 'username': username};

  @override
  List<Object?> get props => [id, username];
}
