import 'dart:io';

import 'package:example/src/presentation/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  HttpOverrides.runWithHttpOverrides(
    () => runApp(const ProviderScope(child: MercureChat())),
    HandshakeOverride(),
  );
}

class HandshakeOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
