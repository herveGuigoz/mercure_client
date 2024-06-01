import 'dart:async';
import 'dart:convert';

import 'package:example/src/messages/bloc/hub.dart';
import 'package:example/src/messages/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final userProvider = Provider<User>((ref) {
  const uuid = Uuid();
  return User(id: uuid.v4(), username: 'john.doe');
});

final hubProvider = Provider<Hub>((ref) {
  return Hub(
    url: const String.fromEnvironment(
      'HUB_URL',
      defaultValue: 'http://localhost:80/.well-known/mercure',
    ),
    jwt: const String.fromEnvironment(
      'TOKEN',
      defaultValue: 'eyJhbGciOiJIUzI1NiJ9.eyJtZXJjdXJlIjp7InB1Ymxpc2giOlsiKiJdLCJzdWJzY3JpYmUiOlsiKiJdfX0.bVXdlWXwfw9ySx7-iV5OpUSHo34RkjUdVzDLBcc6l_g',
    ),
  );
});

final messagesProvider = StreamNotifierProvider<MessagesNotifier, List<Message>>(
  () => MessagesNotifier(topic: Uri.http('example.com', '/rooms/1')),
);

class MessagesNotifier extends StreamNotifier<List<Message>> {
  MessagesNotifier({required this.topic});

  final Uri topic;

  List<Message> _state = [];

  @protected
  Hub get hub => ref.read(hubProvider);

  @protected
  User get user => ref.read(userProvider);

  @override
  Stream<List<Message>> build() async* {
    final stream = hub.subscribe(topics: [topic.toString()]);

    await for (final event in stream) {
      _state = [..._state, Message.fromMap(jsonDecode(event.data) as Map<String, dynamic>)];
      yield _state;
    }
  }

  Future<void> send(String value) async {
    final message = Message(value: value, author: user);
    await hub.publish(topic: topic, data: jsonEncode(message.toMap()));
  }
}
