import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/coolors.dart';
import 'package:open_filex/open_filex.dart';
import '../widgets/image_viewer.dart';

class AttachmentBubble extends StatelessWidget {
  final Map<String, dynamic> message;

  const AttachmentBubble({super.key, required this.message});

  // 1. Updated isMe to check 'sender_id' (matching your buildMessageBubble)
  bool get isMe => message['sender_id'] == message['currentUserId'];

  @override
  Widget build(BuildContext context) {
    final type = message['type'];
    final dynamic fileData = message['file'];
    
    // 2. Map 'message' field to caption (since that's where we saved the text)
    final caption = message['message'] ?? '';
    final bool isDefaultCaption = caption == "Sent an attachment";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          // Use your logic: Primary for me, Card for others
          color: isMe ? kPrimaryColor : kCardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 18.0 : 4.0),
            topRight: Radius.circular(isMe ? 4.0 : 18.0),
            bottomLeft: const Radius.circular(18.0),
            bottomRight: const Radius.circular(18.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPreview(type, fileData, context),

            // 3. Status Progress
            if (message['status'] == 'sending')
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: LinearProgressIndicator(minHeight: 2, color: Colors.white),
              ),

            // 4. Caption logic: Only show if it's not the default placeholder
            if (caption.isNotEmpty && !isDefaultCaption) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  caption,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white : kTextPrimary,
                  ),
                ),
              ),
            ],

            // 5. Time and Status
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message['created_at'] != null)
                    Text(
                      _formatTime(message['created_at']),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  const SizedBox(width: 4),
                  if (isMe)
                    Icon(
                      message['status'] == 'sent' ? Icons.done_all : Icons.access_time,
                      size: 12,
                      color: Colors.white70,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  Widget _buildPreview(String type, dynamic fileData, BuildContext context) {
    // 6. Robust path detection
    final String path = (fileData is File) 
        ? fileData.path 
        : (message['fileUrl'] ?? message['file_url'] ?? '');
    
    final bool isNetwork = path.startsWith('http');

    if (path.isEmpty) return const Icon(Icons.error);

    switch (type) {
      case 'image':
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImageViewer(
                  file: isNetwork ? File(path) : (fileData is File ? fileData : File(path)),
                  // Note: Ensure ImageViewer handles network strings if needed
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isNetwork
                ? Image.network(
                    path,
                    width: 220,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => 
                        const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  )
                : Image.file(
                    (fileData is File) ? fileData : File(path),
                    width: 220,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
          ),
        );

      case 'document':
        return GestureDetector(
          onTap: () => OpenFilex.open(path),
          child: _fileTile(Icons.picture_as_pdf, "Document"),
        );

      default:
        return _fileTile(Icons.insert_drive_file, "Attachment");
    }
  }

  Widget _fileTile(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isMe ? Colors.white : kPrimaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isMe ? Colors.white : kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}