import 'package:example/src/domain/authentication/authentication.dart';
import 'package:example/src/domain/messages/messages_models.dart';
import 'package:example/src/infrastructure/messages/mercure.dart';

abstract class MessageFacade {
  factory MessageFacade() = MessageRepository;

  Stream<Message> subscribe({
    required List<String> topics,
  });

  Future<void> dispatch({
    required String topic,
    required String value,
    required User author,
  });
}
