import 'package:example/src/domain/authentication/authentication_models.dart';
import 'package:example/src/infrastructure/authentication/repository.dart';

abstract class AuthenticationFacade {
  const factory AuthenticationFacade() = AuthenticationRepository;

  /// Creates a new user with the provided [username].
  Future<User> login({required String username});

  /// Signs out the current user.
  Future<void> logOut();
}
