import 'package:uuid/v4.dart';

import 'package:offline_first_poc/models/synchronizable.dart';
import 'package:uuid/validation.dart';

class Note extends Synchronizable {
  final String id;
  final String content;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
    super.isSync = false,
    super.isDeleted = false,
  });

  factory Note.fromMap(Map<String, dynamic> map, {bool isSync = false}) {
    return Note(
      id: map['id'] is num ? map['id'].toString() : map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      isSync: map['isSync'] ?? isSync,
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  factory Note.generate(String content) {
    return Note(
      id: const UuidV4().generate(),
      content: content,
      createdAt: DateTime.now(),
    );
  }

  bool get hasTempId => UuidValidation.isValidUUID(fromString: id);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isSync': isSync,
      'isDeleted': isDeleted,
    };
  }

  @override
  bool operator ==(covariant Note other) {
    if (identical(this, other)) return true;

    return other.id == id && other.content == content && other.createdAt == createdAt;
  }

  @override
  int get hashCode => id.hashCode ^ content.hashCode ^ createdAt.hashCode;

  @override
  String toString() =>
      'Note(id: $id, content: $content, createdAt: ${createdAt.toIso8601String()}, isSync: $isSync, isDeleted: $isDeleted)';

  Note copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    bool? isSync,
    bool? isDeleted,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isSync: isSync ?? this.isSync,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
