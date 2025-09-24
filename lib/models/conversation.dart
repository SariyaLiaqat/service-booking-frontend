// lib/models/conversation.dart
class Conversation {
  final int id;
  final String providerName;
  final String? providerImage;
  final String lastMessage;
  final DateTime? lastMessageTime;

  Conversation({
    required this.id,
    required this.providerName,
    this.providerImage,
    required this.lastMessage,
    this.lastMessageTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      providerName: json['provider_name'] ?? 'Provider',
      providerImage: json['provider_image'],
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.tryParse(json['last_message_time'])?.toLocal()
          : null,
    );
  }
}
