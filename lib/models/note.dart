class Note {
  final String? id;
  final String content;
  final DateTime createdAt;

  const Note({
    this.id,
    required this.content,
    required this.createdAt,
  });

  bool get isSync => id != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map, String id) {
    return Note(
      id: id,
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  bool operator ==(covariant Note other) {
    if (identical(this, other)) return true;

    return other.id == id && other.content == content && other.createdAt == createdAt;
  }

  @override
  int get hashCode => id.hashCode ^ content.hashCode ^ createdAt.hashCode;

  @override
  String toString() => 'Note(id: $id, content: $content, createdAt: ${createdAt.toIso8601String()})';
}
