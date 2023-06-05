import 'basic_model.dart';

class ChatHistory {
  /// Generate by database.
  final int? id;

  /// User's first chat.
  final String content;

  /// [DateTime].
  final DateTime dateTime;

  const ChatHistory({
    this.id,
    required this.content,
    required this.dateTime,
  });

  factory ChatHistory.fromMap(Map<String, dynamic> map) => ChatHistory(
        id: map["id"],
        content: map["content"],
        dateTime: DateTime.fromMillisecondsSinceEpoch(map["dateTime"]),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) "id": id,
        "content": content,
        "dateTime": dateTime.millisecondsSinceEpoch,
      };

  @override
  String toString() {
    return 'ChatHistory{id: $id, content: $content, dateTime: $dateTime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHistory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          dateTime == other.dateTime;

  @override
  int get hashCode => id.hashCode ^ content.hashCode ^ dateTime.hashCode;
}

class DetailedChatHistory {
  int? id;
  final Role role;
  final String content;
  final DateTime dateTime;

  DetailedChatHistory({
    this.id,
    required this.role,
    required this.content,
    required this.dateTime,
  });

  factory DetailedChatHistory.fromMap(Map<String, dynamic> map) =>
      DetailedChatHistory(
        id: map["id"],
        role: Role.parse(map["role"]),
        content: map["content"],
        dateTime: DateTime.fromMillisecondsSinceEpoch(map["dateTime"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "role": role.name,
        "content": content,
        "dateTime": dateTime.millisecondsSinceEpoch
      };

  @override
  String toString() {
    return 'DetailedChatHistory{id: $id, role: $role, content: $content, dateTime: $dateTime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailedChatHistory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          content == other.content &&
          dateTime == other.dateTime;

  @override
  int get hashCode =>
      id.hashCode ^ role.hashCode ^ content.hashCode ^ dateTime.hashCode;
}
