import 'package:example/src/application/authentication/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({
    Key? key,
  }) : super(key: key);

  static const String path = '/login';

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref
            .read(userProvider.notifier)
            .logIn(username: _textController.text);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 768),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's talk with us!",
                    style: theme.textTheme.titleLarge,
                  ),
                  const Gap(24),
                  TextFormField(
                    controller: _textController,
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                    ),
                    validator: (input) {
                      return (input?.isEmpty ?? true)
                          ? 'Username is required'
                          : null;
                    },
                  ),
                  const Gap(24),
                  ElevatedButton(
                    onPressed: login,
                    child: const Text('Log in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
