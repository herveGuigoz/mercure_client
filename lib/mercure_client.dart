library mercure_client;

export 'src/mercure.dart' if (dart.library.html) 'src/mercure_html.dart'
    show Mercure;
export 'src/mercure_error.dart';
export 'src/mercure_event.dart';
