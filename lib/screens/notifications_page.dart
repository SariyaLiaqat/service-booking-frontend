







// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:provider/provider.dart';
// import '../helpers/backend.dart';
// import '../helpers/coolors.dart';
// import '../providers/NotificationProvider.dart';
// import 'chat_page.dart';

// class NotificationsPage extends StatefulWidget {
//   final int userId;
//   final String role;

//   const NotificationsPage({Key? key, required this.userId, required this.role})
//       : super(key: key);

//   @override
//   _NotificationsPageState createState() => _NotificationsPageState();
// }

// class _NotificationsPageState extends State<NotificationsPage> {
//   IO.Socket? socket;

//   @override
//   void initState() {
//     super.initState();
//     connectSocket();
//     // Fetch notifications via Provider
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       fetchNotifications(context);
//     });
//   }

//   void connectSocket() {
//     socket = IO.io(Backend.socketUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket?.connect();

//     socket?.onConnect((_) {
//       socket?.emit('join', "user_${widget.userId}");
//     });

//     socket?.on('new_notification', (data) {
//       Provider.of<NotificationProvider>(context, listen: false)
//           .addNotification(data);
//     });

//     socket?.onDisconnect((_) {});
//   }

//   @override
//   void dispose() {
//     socket?.disconnect();
//     super.dispose();
//   }

//   // ---------------- FETCH NOTIFICATIONS ----------------
//   Future<void> fetchNotifications(BuildContext context) async {
//     final notifProvider =
//         Provider.of<NotificationProvider>(context, listen: false);
//     notifProvider.setLoading(true);

//     try {
//       final url =
//           Uri.parse("${Backend.baseUrl}/notifications?user_id=${widget.userId}");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         notifProvider.setNotifications(
//           (data['notifications'] as List<dynamic>?) ?? [],
//           data['unseen_count'] ?? 0,
//         );

//         if (notifProvider.unseenCount > 0) {
//           await markNotificationsSeen(context);
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching notifications: $e')),
//       );
//     } finally {
//       notifProvider.setLoading(false);
//     }
//   }

//   // ---------------- MARK SEEN ----------------
//   Future<void> markNotificationsSeen(BuildContext context) async {
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/notifications/mark_seen");
//       await http.post(url, body: {'user_id': widget.userId.toString()});
//       Provider.of<NotificationProvider>(context, listen: false).markAllSeen();
//     } catch (e) {
//       debugPrint("Error marking notifications seen: $e");
//     }
//   }

//   // ---------------- DELETE SINGLE ----------------
//   Future<void> deleteNotification(BuildContext context, int notifId) async {
//     final notifProvider =
//         Provider.of<NotificationProvider>(context, listen: false);

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: const Color(0xFFD9E1F0),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Confirm Delete',
//             style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
//         content: const Text('Are you sure you want to delete this notification?',
//             style: TextStyle(color: Color(0xFF2A3A69))),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     try {
//       final url = Uri.parse("${Backend.baseUrl}/notifications/$notifId");
//       final response = await http.delete(url);
//       if (response.statusCode == 200) {
//         notifProvider.deleteNotification(notifId);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Notification deleted successfully ✅')),
//         );
//       } else {
//         throw Exception('Failed to delete notification');
//       }
//     } catch (e) {
//       debugPrint("Error deleting notification: $e");
//     }
//   }

//   // ---------------- DELETE ALL ----------------
//   Future<void> deleteAllNotifications(BuildContext context) async {
//     final notifProvider =
//         Provider.of<NotificationProvider>(context, listen: false);

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: kBackgroundColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Confirm Delete All',
//             style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
//         content: const Text('Are you sure you want to delete all notifications?',
//             style: TextStyle(color: kTextPrimary)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete All'),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     try {
//       final url = Uri.parse("${Backend.baseUrl}/notifications/delete_all");
//       final response = await http.post(
//         url,
//         body: {'user_id': widget.userId.toString()},
//       );

//       if (response.statusCode == 200) {
//         notifProvider.clearAll();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('All notifications deleted successfully ✅')),
//         );
//       } else {
//         throw Exception('Failed to delete all notifications');
//       }
//     } catch (e) {
//       debugPrint("Error deleting all notifications: $e");
//     }
//   }

//   // ---------------- CARD WIDGET ----------------
//   Color getCardColor(dynamic notif) {
//     if (notif['title'] != null) {
//       if (notif['title'].contains("Accepted") ||
//           notif['title'].contains("Rejected") ||
//           notif['title'].contains("Completed")) {
//         return const Color(0xFFDDE6F5);
//       }
//     }

//     if (notif['conversation_id'] != null) {
//       return notif['is_seen'] ? kCardColor : kSecondaryColor.withOpacity(0.15);
//     }

//     return notif['is_seen'] ? kCardColor : const Color(0xFFDDE6F5);
//   }

//   Widget buildNotificationCard(dynamic notif) {
//     // final notifProvider =
//     //     Provider.of<NotificationProvider>(context, listen: false);
//     final senderName = (notif['sender_name'] != null &&
//             notif['sender_name'].toString().trim().isNotEmpty)
//         ? notif['sender_name']
//         : 'Unknown User';
//     final avatar = notif['sender_avatar'];
//     final createdAt = notif['created_at'] != null
//         ? DateTime.tryParse(notif['created_at'])?.toLocal()
//         : null;
//     final otherUserId = notif['sender_id'];

//     return Card(
//       color: getCardColor(notif),
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         onTap: () {
//           if (notif['conversation_id'] != null && otherUserId != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ChatPage(
//                   conversationId: notif['conversation_id'],
//                   currentUserId: widget.userId,
//                   otherUserId: otherUserId,
//                 ),
//               ),
//             );
//           }
//         },
//         leading: CircleAvatar(
//           radius: 22,
//           backgroundImage: (avatar != null && avatar.toString().isNotEmpty)
//               ? NetworkImage("${Backend.baseUrl}/$avatar")
//               : null,
//           child: (avatar == null || avatar.toString().isEmpty)
//               ? Text(senderName[0].toUpperCase())
//               : null,
//         ),
//         title: Text(senderName, maxLines: 1, overflow: TextOverflow.ellipsis),
//         subtitle: Text(
//           notif['message'] ?? '',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (createdAt != null)
//               Text(
//                 '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} '
//                 '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
//                 style: const TextStyle(fontSize: 11, color: Colors.grey),
//               ),
//             IconButton(
//               icon: const Icon(Icons.delete, color: redAccent),
//               onPressed: () =>
//                   deleteNotification(context, notif['id'] as int),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------- BUILD ----------------
//   @override
//   Widget build(BuildContext context) {
//     final notifProvider = Provider.of<NotificationProvider>(context);
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: kBackgroundColor,
//         elevation: 4,
//         title: const Text('Notifications',
//             style: TextStyle(
//               color: kTextPrimary,
//               fontWeight: FontWeight.bold,
//             )),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_sweep, color: kTextPrimary),
//             onPressed: () => deleteAllNotifications(context),
//           ),
//         ],
//       ),
//       body: notifProvider.isLoading
//           ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
//           : notifProvider.notifications.isEmpty
//               ? const Center(
//                   child: Text('No notifications yet'),
//                 )
//               : RefreshIndicator(
//                   onRefresh: () => fetchNotifications(context),
//                   color: kPrimaryColor,
//                   child: ListView.builder(
//                     itemCount: notifProvider.notifications.length,
//                     itemBuilder: (context, index) =>
//                         buildNotificationCard(notifProvider.notifications[index]),
//                   ),
//                 ),
//     );
//   }
// }
















import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import '../helpers/backend.dart';
import '../helpers/coolors.dart';
import '../providers/NotificationProvider.dart';
import 'chat_page.dart';

class NotificationsPage extends StatefulWidget {
  final int userId;
  final String role;
  final String tab; // 'messages' or 'tasks'

  const NotificationsPage({Key? key, required this.userId, required this.role, required this.tab})
      : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    connectSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchNotifications(context);
    });
  }

  void connectSocket() {
    socket = IO.io(Backend.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();
    socket?.onConnect((_) {
      socket?.emit('join', "user_${widget.userId}");
    });

    socket?.on('new_notification', (data) {
      Provider.of<NotificationProvider>(context, listen: false).addNotification(data);
    });

    socket?.onDisconnect((_) {});
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }

  Future<void> fetchNotifications(BuildContext context) async {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    notifProvider.setLoading(true);

    try {
      final url = Uri.parse("${Backend.baseUrl}/notifications?user_id=${widget.userId}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        notifProvider.setNotifications(
          (data['notifications'] as List<dynamic>?) ?? [],
          data['unseen_count'] ?? 0,
        );

        // Mark only relevant tab notifications seen
        if (widget.tab == 'messages') {
          if (notifProvider.unseenMessageCount > 0) notifProvider.markMessagesSeen();
        } else if (widget.tab == 'tasks') {
          if (notifProvider.unseenTaskCount > 0) notifProvider.markTasksSeen();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notifications: $e')),
      );
    } finally {
      notifProvider.setLoading(false);
    }
  }

  Future<void> deleteNotification(BuildContext context, int notifId) async {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFD9E1F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Delete', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this notification?', style: TextStyle(color: Color(0xFF2A3A69))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("${Backend.baseUrl}/notifications/$notifId");
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        notifProvider.deleteNotification(notifId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted successfully ✅')),
        );
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      debugPrint("Error deleting notification: $e");
    }
  }

  Future<void> deleteAllNotifications(BuildContext context) async {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Delete All', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete all notifications?', style: TextStyle(color: kTextPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete All')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("${Backend.baseUrl}/notifications/delete_all");
      final response = await http.post(url, body: {'user_id': widget.userId.toString()});
      if (response.statusCode == 200) {
        notifProvider.clearAll();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications deleted successfully ✅')),
        );
      } else {
        throw Exception('Failed to delete all notifications');
      }
    } catch (e) {
      debugPrint("Error deleting all notifications: $e");
    }
  }

  Color getCardColor(dynamic notif) {
    if (notif['title'] != null) {
      if (notif['title'].contains("Accepted") || notif['title'].contains("Rejected") || notif['title'].contains("Completed")) {
        return const Color(0xFFDDE6F5);
      }
    }
    if (notif['conversation_id'] != null) {
      return notif['is_seen'] ? kCardColor : kSecondaryColor.withOpacity(0.15);
    }
    return notif['is_seen'] ? kCardColor : const Color(0xFFDDE6F5);
  }

  Widget buildNotificationCard(dynamic notif) {
    final senderName = (notif['sender_name'] != null && notif['sender_name'].toString().trim().isNotEmpty)
        ? notif['sender_name']
        : 'Unknown User';
    final avatar = notif['sender_avatar'];
    final createdAt = notif['created_at'] != null ? DateTime.tryParse(notif['created_at'])?.toLocal() : null;
    final otherUserId = notif['sender_id'];

    return Card(
      color: getCardColor(notif),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          if (notif['conversation_id'] != null && otherUserId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  conversationId: notif['conversation_id'],
                  currentUserId: widget.userId,
                  otherUserId: otherUserId,
                ),
              ),
            );
          }
        },
        leading: CircleAvatar(
          radius: 22,
          backgroundImage: (avatar != null && avatar.toString().isNotEmpty) ? NetworkImage("${Backend.baseUrl}/$avatar") : null,
          child: (avatar == null || avatar.toString().isEmpty) ? Text(senderName[0].toUpperCase()) : null,
        ),
        title: Text(senderName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(notif['message'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (createdAt != null)
              Text('${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} '
                  '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            IconButton(
              icon: const Icon(Icons.delete, color: redAccent),
              onPressed: () => deleteNotification(context, notif['id'] as int),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);

    // 🔹 Choose correct tab notifications
    final List<dynamic> tabNotifications =
        widget.tab == 'messages' ? notifProvider.messageNotifications : notifProvider.taskNotifications;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 4,
        title: Text(
          widget.tab == 'messages' ? 'Messages' : 'Tasks',
          style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: kTextPrimary),
            onPressed: () => deleteAllNotifications(context),
          ),
        ],
      ),
      body: notifProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : tabNotifications.isEmpty
              ? Center(child: Text('No ${widget.tab} notifications yet'))
              : RefreshIndicator(
                  onRefresh: () => fetchNotifications(context),
                  color: kPrimaryColor,
                  child: ListView.builder(
                    itemCount: tabNotifications.length,
                    itemBuilder: (context, index) => buildNotificationCard(tabNotifications[index]),
                  ),
                ),
    );
  }
}
