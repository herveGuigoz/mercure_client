part of 'models.dart';

class Message extends Equatable {
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
  List<Object?> get props => [value, author];
}
