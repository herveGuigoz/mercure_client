import 'package:example/src/application/authentication/controller.dart';
import 'package:example/src/presentation/home/home_view.dart';
import 'package:example/src/presentation/login/login_view.dart';
import 'package:example/src/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

class MercureChat extends ConsumerStatefulWidget {
  const MercureChat({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MercureChat> createState() => _MercureChatState();
}

class _MercureChatState extends ConsumerState<MercureChat> {
  bool get isLoggedIn => ref.read(userProvider) != null;

  late final _router = GoRouter(
    refreshListenable: GoRouterRefreshStream(
      ref.read(userProvider.notifier).stream,
    ),
    routes: [
      GoRoute(
        path: HomeView.path,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: LoginView.path,
        builder: (context, state) => const LoginView(),
      ),
    ],
    redirect: (state) {
      if (isLoggedIn) {
        return state.location == HomeView.path ? null : HomeView.path;
      } else {
        return state.location == LoginView.path ? null : LoginView.path;
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'app',
      theme: lightTheme,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}
