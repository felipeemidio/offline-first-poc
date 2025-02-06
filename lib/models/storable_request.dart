// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dio/dio.dart';

class StorableRequest {
  final String path;
  final String method;
  final dynamic body;
  final DateTime createdAt;
  int attempts;

  StorableRequest({
    required this.path,
    required this.method,
    required this.body,
    required this.createdAt,
    this.attempts = 0,
  });

  String toStorableString() {
    return '$method|$path|${body != null ? jsonEncode(body) : ''}|${createdAt.toIso8601String()}|$attempts';
  }

  factory StorableRequest.fromStorableString(String json) {
    final splitValues = json.split('|');
    if (splitValues.length != 5) {
      throw const FormatException('Invalid StorableRequest string');
    }
    return StorableRequest(
      method: splitValues[0],
      path: splitValues[1],
      body: splitValues[2].isEmpty ? null : jsonDecode(splitValues[2]),
      createdAt: DateTime.parse(splitValues[3]),
      attempts: int.parse(splitValues[4]),
    );
  }

  factory StorableRequest.fromDio(RequestOptions dioResquest) {
    return StorableRequest(
      method: dioResquest.method,
      path: dioResquest.uri.path,
      body: dioResquest.data,
      createdAt: DateTime.now(),
      attempts: 0,
    );
  }

  @override
  bool operator ==(covariant StorableRequest other) {
    if (identical(this, other)) return true;
    return other.path == path && other.method == method && jsonEncode(other.body) == jsonEncode(body);
  }

  @override
  int get hashCode {
    return path.hashCode ^ method.hashCode ^ jsonEncode(body).hashCode;
  }
}
