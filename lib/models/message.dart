// lib/models/message.dart
class Message {
  final int id;
  final int senderId;
  final String text;
  final DateTime? createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      text: json['message'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])?.toLocal()
          : null,
    );
  }
}
