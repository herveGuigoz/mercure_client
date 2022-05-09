// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:example/src/domain/authentication/authentication.dart';
import 'package:example/src/domain/messages/messages.dart';
import 'package:mercure_client/mercure_client.dart';

/// Allow to define ip adress
/// ex: flutter run --dart-define SERVER_NAME=127.0.0.1
const serverName = bool.hasEnvironment('SERVER_NAME')
    ? String.fromEnvironment('SERVER_NAME')
    : 'localhost';

const bearer =
    'eyJhbGciOiJIUzI1NiJ9.eyJtZXJjdXJlIjp7InB1Ymxpc2giOlsiKiJdfX0.vhMwOaN5K68BTIhWokMLOeOJO4EPfT64brd8euJOA4M';

class MessageRepository implements MessageFacade {
  MessageRepository({
    this.mercureHubURL = 'http://$serverName/.well-known/mercure',
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final Dio _dio;

  final String mercureHubURL;

  @override
  Stream<Message> subscribe({required List<String> topics}) {
    return Mercure(
      url: mercureHubURL,
      topics: topics,
    ).map(
      (event) => Message.fromMap(jsonDecode(event.data)),
    );
  }

  @override
  Future<void> dispatch({
    required String topic,
    required String value,
    required User author,
  }) async {
    await _dio.post(
      mercureHubURL,
      data: {
        'topic': topic,
        'data': jsonEncode({'value': value, 'author': author.toMap()}),
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': 'Bearer $bearer',
          'Content-Type': Headers.formUrlEncodedContentType,
        },
      ),
    );
  }
}
