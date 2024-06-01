import 'package:example/src/app/theme/theme.dart';
import 'package:example/src/messages/view/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MercureChat extends ConsumerWidget {
  const MercureChat({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      restorationScopeId: 'mercure',
      theme: theme,
      home: const MessagesView(),
    );
  }
}
