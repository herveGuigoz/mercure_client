import 'dart:async';
import 'dart:developer';

import 'package:example/src/application/authentication/controller.dart';
import 'package:example/src/domain/authentication/authentication.dart';
import 'package:example/src/domain/messages/messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messagesProvider =
    StateNotifierProvider.autoDispose<MessagesController, List<Message>>(
  (ref) {
    final user = ref.watch(userProvider);
    return MessagesController(messageFacade: MessageFacade(), user: user!);
  },
);

class MessagesController extends StateNotifier<List<Message>> {
  MessagesController({
    required this.messageFacade,
    required this.user,
  }) : super([]) {
    _messagesSubscription = messageFacade.subscribe(
      topics: ['http://localhost/messages/{id}'],
    ).listen(
      (event) => state = [...state, event],
      onError: (Object error) => log('$error', name: 'MessagesController'),
      onDone: () => log('Stream closed', name: 'MessagesController'),
    );
  }

  final MessageFacade messageFacade;
  final User user;
  late final StreamSubscription<Message> _messagesSubscription;

  Future<void> send(String value) async {
    await messageFacade.dispatch(
      topic: 'http://localhost/messages/1',
      value: value,
      author: user,
    );
  }

  @override
  void dispose() {
    _messagesSubscription.cancel();
    super.dispose();
  }
}
