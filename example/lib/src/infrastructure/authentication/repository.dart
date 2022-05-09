import 'package:example/src/domain/authentication/authentication.dart';
import 'package:uuid/uuid.dart';

class AuthenticationRepository implements AuthenticationFacade {
  const AuthenticationRepository();
  
  @override
  Future<User> login({required String username}) {
    return Future.value(
      User(id: const Uuid().v4(), username: username),
    );
  }

  @override
  Future<void> logOut() => Future.value();
}
