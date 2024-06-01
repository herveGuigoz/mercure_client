import 'package:mercure_client/src/mercure_event.dart';
// ignore: always_use_package_imports
import 'mercure_io.dart' if (dart.library.html) 'mercure_html.dart';

/// {@template mercure_client.mercure}
/// A class that allows subscibe and publish to Mercure hub.
/// {@endtemplate}
abstract class Mercure extends Stream<MercureEvent> {
  /// {@macro mercure_client.mercure}
  factory Mercure({
    required String url,
    required List<String> topics,
    String? token,
    String? lastEventId,
  }) = MercureClient;
}
