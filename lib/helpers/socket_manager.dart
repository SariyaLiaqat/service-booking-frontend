import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'backend.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  IO.Socket? socket;
  int? _userId;
  final _storage = const FlutterSecureStorage();

  // ------------------ STREAM CONTROLLERS ------------------
  static final _newMessageController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get onNewMessage => _newMessageController.stream;

  static final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get onTyping => _typingController.stream;

  static final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get onUserStatus => _statusController.stream;

  static final _deleteController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get onMessageDeleted => _deleteController.stream;

  static final _editController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get onMessageEdited => _editController.stream;

  // ------------------ INIT SOCKET ------------------
  Future<void> initSocket() async {
    if (socket != null && socket!.connected) return; // Already connected

    final idStr = await _storage.read(key: 'user_id');
    if (idStr == null) {
      print("⚠️ No user logged in, socket not initialized.");
      return;
    }

    _userId = int.tryParse(idStr);

    socket = IO.io(
      Backend.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Connection': 'upgrade'})
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("⚡ Socket connected (User $_userId)");
      socket!.emit('user_online', _userId);
    });

    socket!.onDisconnect((_) => print("❌ Socket disconnected"));
    socket!.onConnectError((err) => print("🚨 Socket connection error: $err"));

    // Listen to all events and add to streams
    socket!.on('new_message', (data) => _newMessageController.add(Map<String, dynamic>.from(data)));
    socket!.on('user_typing', (data) => _typingController.add(Map<String, dynamic>.from(data)));
    socket!.on('user_status_change', (data) => _statusController.add(Map<String, dynamic>.from(data)));
    socket!.on('message_deleted', (data) => _deleteController.add(Map<String, dynamic>.from(data)));
    socket!.on('message_edited', (data) => _editController.add(Map<String, dynamic>.from(data)));

    // ✅ Update FCM token
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && _userId != null) {
      try {
        await http.post(
          Uri.parse("${Backend.baseUrl}/users/update-token"),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"user_id": _userId, "fcm_token": token}),
        );
      } catch (e) {
        print("FCM update failed: $e");
      }
    }
  }

  void sendMessage(int conversationId, int senderId, int receiverId, String message, int tempId, {String? type, String? fileUrl}) {
    emit('send_message', {
      "conversationId": conversationId,
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
      "tempId": tempId,
      "type": type ?? "text",      // 👈 ADD THIS
      "fileUrl": fileUrl,          // 👈 ADD THIS
    });
  }

  void setTyping(int userId, bool isTyping) {
    emit('typing', {"userId": userId, "isTyping": isTyping});
  }
// ✅ Add these 2 below
void joinConversation(int conversationId, int userId) {
  emit('join_conversation', {'conversationId': conversationId, 'userId': userId});
}

void leaveConversation(int conversationId, int userId) {
  emit('leave_conversation', {'conversationId': conversationId, 'userId': userId});
}
  void emit(String event, dynamic data) {
    if (socket != null && socket!.connected) {
      socket!.emit(event, data);
    } else {
      print("⚠️ Socket not connected. Event skipped: $event");
    }
  }

  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.emit('user_offline', _userId);
      socket!.disconnect();
      print("🚪 Socket disconnected manually.");
    }
  }

  // ------------------ CLEANUP ------------------
  void dispose() {
    _newMessageController.close();
    _typingController.close();
    _statusController.close();
    _deleteController.close();
    _editController.close();
  }
}
