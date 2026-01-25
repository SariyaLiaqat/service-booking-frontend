class Message {
  final int id;
  final int senderId;
  final String text;
  final DateTime? createdAt;
  final String? type;      // 👈 Added this
  final String? fileUrl;   // 👈 Added this

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    this.createdAt,
    this.type,             // 👈 Added this
    this.fileUrl,          // 👈 Added this
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      text: json['message'] ?? '',
      type: json['type'],                         // 👈 Map from JSON
      fileUrl: json['file_url'] ?? json['fileUrl'], // 👈 Map from JSON
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])?.toLocal()
          : null,
    );
  }
}