import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ------------------- MODEL -------------------
class Status {
  final int id;
  final int providerId;
  final String type; // 'image' or 'video'
  final String url;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int userId;

  Status({
    required this.id,
    required this.providerId,
    required this.type,
    required this.url,
    required this.createdAt,
    this.expiresAt,
    required this.userId,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'],
      userId: json['provider_id'], 
      providerId: json['provider_id'],
      type: json['status_type'],
      url: json['media_url'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }
}

// ------------------- CONTROLLER -------------------
class StatusController extends ChangeNotifier {
  List<Status> statuses = [];
  late IO.Socket socket;
  final int currentUserId;

  StatusController({required this.currentUserId}) {
    initSocket();
    fetchStatuses();
  }

  void initSocket() {
  socket = IO.io(
    Backend.baseUrl,
    <String, dynamic>{'transports': ['websocket'], 'autoConnect': true},
  );

  socket.connect();

  socket.onConnect((_) {
    print("Status socket connected");
    socket.emit('user_online', currentUserId);
  });

  socket.on('status_updated', (data) {
    final status = Status.fromJson(data);
    statuses.removeWhere((s) => s.id == status.id);
    statuses.insert(0, status);
    notifyListeners();
  });

  socket.on('status_removed', (data) {
    final providerId = data['provider_id'];
    statuses.removeWhere((s) => s.userId == providerId);
    notifyListeners();
  });
}


  // Fetch statuses from backend
  Future<void> fetchStatuses() async {
  try {
    final userId = currentUserId;
    final url = Uri.parse("${Backend.baseUrl}/statuses/fetch?user_id=$userId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      statuses = (data['statuses'] as List<dynamic>?)
                  ?.map((s) => Status.fromJson(s))
                  .toList() ?? [];
      notifyListeners();
    } else {
      print("Failed to fetch statuses: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching statuses: $e");
  }
}



  // Upload status
  Future<void> uploadStatus(String filePath, String type) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${Backend.baseUrl}/statuses/upload"),
      );
      request.fields['provider_id'] = currentUserId.toString();
      request.fields['status_type'] = type;
      request.files.add(await http.MultipartFile.fromPath('media', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Status uploaded successfully");
      } else {
        print("❌ Error uploading status: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception uploading status: $e");
    }
  }
}

// ------------------- UI WIDGETS -------------------
class StatusCircle extends StatelessWidget {
  final Status status;
  final VoidCallback onTap;

  const StatusCircle({Key? key, required this.status, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: status.type == 'image'
                ? NetworkImage("${Backend.baseUrl}/${status.url}")
                : null,
            child: status.type == 'video'
                ? Icon(Icons.videocam, color: Colors.white, size: 24)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- STATUS VIEWER -------------------
void showStatusViewer(BuildContext context, Status status) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: status.type == 'image'
                  ? InteractiveViewer(
                      child: Image.network("${Backend.baseUrl}/${status.url}"),
                    )
                  : Center(child: Icon(Icons.videocam, color: Colors.white, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Uploaded: ${status.createdAt.toLocal()}",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ------------------- STATUS LIST WIDGET -------------------
class StatusList extends StatelessWidget {
  final StatusController controller;

  const StatusList({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.statuses.length,
        itemBuilder: (context, index) {
          final status = controller.statuses[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: StatusCircle(
              status: status,
              onTap: () => showStatusViewer(context, status),
            ),
          );
        },
      ),
    );
  }
}
