import 'package:example/src/domain/authentication/authentication.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateNotifierProvider<AuthenticationController, User?>(
  (ref) => AuthenticationController(),
);

class AuthenticationController extends StateNotifier<User?> {
  AuthenticationController({
    AuthenticationFacade authenticationFacade = const AuthenticationFacade(),
  })  : _authenticationFacade = authenticationFacade,
        super(null);

  final AuthenticationFacade _authenticationFacade;

  Future<void> logIn({required String username}) async {
    state = await _authenticationFacade.login(username: username);
  }

  Future<void> logOut() async {
    await _authenticationFacade.logOut();
    state = null;
  }
}
