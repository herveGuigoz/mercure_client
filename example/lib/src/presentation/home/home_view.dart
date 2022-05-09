import 'package:example/src/application/authentication/controller.dart';
import 'package:example/src/application/messages/controller.dart';
import 'package:example/src/domain/messages/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class HomeView extends ConsumerWidget {
  const HomeView({Key? key}) : super(key: key);

  static const String path = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 768),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final message in messages) MessageTile(message),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  const Input(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Input extends ConsumerStatefulWidget {
  const Input({Key? key}) : super(key: key);

  @override
  ConsumerState<Input> createState() => _InputState();
}

class _InputState extends ConsumerState<Input> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextFormField(
            controller: _textController,
            decoration: const InputDecoration(hintText: 'Say something..'),
          ),
        ),
        const Gap(16),
        IconButton(
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              ref.read(messagesProvider.notifier).send(_textController.text);
              _textController.text = '';
            }
          },
          icon: const Icon(Icons.chat),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class MessageTile extends ConsumerWidget {
  const MessageTile(this.message, {Key? key}) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isAuthor = message.author == user;

    return Theme(
      data: ThemeData(
        brightness: isAuthor ? Brightness.dark : Brightness.light,
      ),
      child: Align(
        alignment: isAuthor ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: isAuthor ? const Color(0xFF23262B) : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            boxShadow: const [
              BoxShadow(
                color: Color(0X1A000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            title: Text(message.value),
            subtitle: isAuthor ? null : Text(message.author.username),
          ),
        ),
      ),
    );
  }
}
