

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../helpers/backend.dart';
// import 'chat_page.dart';
// import '../helpers/colors.dart';
// class NotificationsPage extends StatefulWidget {
//   final int userId;
//   final String role;

//   const NotificationsPage({Key? key, required this.userId, required this.role})
//       : super(key: key);

//   @override
//   _NotificationsPageState createState() => _NotificationsPageState();
// }

// class _NotificationsPageState extends State<NotificationsPage> {
//   bool isLoading = true;
//   List<dynamic> notifications = [];
//   int unseenCount = 0;

//   IO.Socket? socket;

//   @override
//   void initState() {
//     super.initState();
//     connectSocket();
//     fetchNotifications();
//   }

// Color getCardColor(dynamic notif) {
//     if (notif['title'] != null) {
//       if (notif['title'].contains("Accepted")) return Colors.green.shade700;
//       if (notif['title'].contains("Rejected")) return Colors.red.shade600;
//       if (notif['title'].contains("Completed")) return AppColors.darkBlue;
//     }
//     return notif['is_seen'] ? Colors.white : const Color(0xFFD9E1F0);
//   }



//   // ---------------- SOCKET.IO ----------------
//   void connectSocket() {
//     socket = IO.io(Backend.socketUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket?.connect();

//     socket?.onConnect((_) {
//       // join user room
//       socket?.emit('join', "user_${widget.userId}");
//     });

//     socket?.on('new_notification', (data) {
//       setState(() {
//         notifications.insert(0, data); // Add on top
//         unseenCount += 1;
//       });
//     });

//     socket?.onDisconnect((_) {});
//   }

//   @override
//   void dispose() {
//     socket?.disconnect();
//     super.dispose();
//   }

//   // ---------------- FETCH NOTIFICATIONS ----------------
//   Future<void> fetchNotifications() async {
//     setState(() => isLoading = true);
//     try {
//       final url =
//           Uri.parse("${Backend.baseUrl}/notifications?user_id=${widget.userId}");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           notifications = (data['notifications'] as List<dynamic>?) ?? [];
//           unseenCount = data['unseen_count'] ?? 0;
//         });

//         if (unseenCount > 0) await markNotificationsSeen();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching notifications: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // ---------------- MARK SEEN ----------------
//   Future<void> markNotificationsSeen() async {
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/notifications/mark_seen");
//       await http.post(url, body: {'user_id': widget.userId.toString()});
//       setState(() => unseenCount = 0);
//     } catch (e) {
//       debugPrint("Error marking notifications seen: $e");
//     }
//   }

//   // ---------------- DELETE SINGLE ----------------
//  Future<void> deleteNotification(int notifId) async {
//   final confirm = await showDialog<bool>(
//     context: context,
//     builder: (_) => AlertDialog(
//       backgroundColor: const Color(0xFFD9E1F0), // Soft background
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       title: const Text(
//         'Confirm Delete',
//         style: TextStyle(
//           color: Color(0xFF0A66C2),
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       content: const Text(
//         'Are you sure you want to delete this notification?',
//         style: TextStyle(
//           color: Color(0xFF2A3A69),
//         ),
//       ),
//       actions: [
//         TextButton(
//           style: TextButton.styleFrom(
//             backgroundColor: Colors.white,
//             foregroundColor: const Color(0xFF0A66C2),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//           onPressed: () => Navigator.pop(context, false),
//           child: const Text(
//             'Cancel',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//         ),
//         TextButton(
//           style: TextButton.styleFrom(
//             backgroundColor: const Color(0xFFE63946), // Red delete button
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//           onPressed: () => Navigator.pop(context, true),
//           child: const Text(
//             'Delete',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     ),
//   );

//   if (confirm != true) return;

//   try {
//     final url = Uri.parse("${Backend.baseUrl}/notifications/$notifId");
//     final response = await http.delete(url);
//     if (response.statusCode == 200) {
//       setState(() {
//         notifications.removeWhere((n) => n['id'] == notifId);
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Notification deleted successfully ✅'),
//           backgroundColor: const Color(0xFF0A66C2),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     } else {
//       throw Exception('Failed to delete notification');
//     }
//   } catch (e) {
//     debugPrint("Error deleting notification: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Error deleting notification: $e',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFFE63946),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
// }




//   // ---------------- DELETE ALL ----------------
//   Future<void> deleteAllNotifications() async {
//   final confirm = await showDialog<bool>(
//     context: context,
//     builder: (_) => AlertDialog(
//       backgroundColor: const Color(0xFFD9E1F0), // Soft background
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       title: const Text(
//         'Confirm Delete All',
//         style: TextStyle(
//           color: Color(0xFF0A66C2),
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       content: const Text(
//         'Are you sure you want to delete all notifications?',
//         style: TextStyle(
//           color: Color(0xFF2A3A69),
//         ),
//       ),
//       actions: [
//         TextButton(
//           style: TextButton.styleFrom(
//             backgroundColor: Colors.white,
//             foregroundColor: const Color(0xFF0A66C2),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//           onPressed: () => Navigator.pop(context, false),
//           child: const Text(
//             'Cancel',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//         ),
//         TextButton(
//           style: TextButton.styleFrom(
//             backgroundColor: const Color(0xFFE63946), // Red delete button
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//           onPressed: () => Navigator.pop(context, true),
//           child: const Text(
//             'Delete All',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     ),
//   );

//   if (confirm != true) return;

//   try {
//     final url = Uri.parse("${Backend.baseUrl}/notifications/delete_all");
//     final response = await http.post(
//       url,
//       body: {'user_id': widget.userId.toString()},
//     );

//     if (response.statusCode == 200) {
//       setState(() => notifications.clear());
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('All notifications deleted successfully ✅'),
//           backgroundColor: const Color(0xFF0A66C2),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     } else {
//       throw Exception('Failed to delete all notifications');
//     }
//   } catch (e) {
//     debugPrint("Error deleting all notifications: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Error deleting all notifications: $e',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFFE63946),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
// }


//   // ---------------- CARD WIDGET ----------------
//   Widget buildNotificationCard(dynamic notif) {
//   final senderName = (notif['sender_name'] != null &&
//           notif['sender_name'].toString().trim().isNotEmpty)
//       ? notif['sender_name']
//       : 'Unknown User';

//   final message = notif['message'] ?? '';
//   final avatar = notif['sender_avatar'];
//   final createdAt = notif['created_at'] != null
//       ? DateTime.tryParse(notif['created_at'])?.toLocal()
//       : null;
//  // final isSeen = notif['is_seen'] ?? false;
//   final otherUserId = notif['sender_id'];
// Color cardColor = getCardColor(notif);
// bool isDarkCard = cardColor != Colors.white && cardColor != const Color(0xFFD9E1F0);
//   return Card(
//     color: getCardColor(notif),

//     margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//     elevation: 3,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     child: ListTile(
      
//      onTap: () {
//   if (notif['conversation_id'] != null && otherUserId != null) {
//     // Chat notification
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ChatPage(
//           conversationId: notif['conversation_id'],
//           currentUserId: widget.userId,
//           otherUserId: otherUserId,
//         ),
//       ),
//     );
//   } else {
//     // Task notification
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Notification"),
//         content: Text(notif['message'] ?? 'No details'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }
// },

//       leading: CircleAvatar(
//         radius: 24,
//         backgroundImage: (avatar != null && avatar.toString().isNotEmpty)
//             ? NetworkImage("${Backend.baseUrl}/$avatar")
//             : null,
//         backgroundColor: Colors.white,
//         child: (avatar == null || avatar.toString().isEmpty)
//             ? const Icon(Icons.person, color: AppColors.darkBlue)
//             : null,
//       ),
//       title: Flexible(
//         child: Text(
//           senderName,
//           maxLines: 1, // ✅ Single line
//           overflow: TextOverflow.ellipsis, // ✅ Agar lamba ho to ...
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: isDarkCard ? Colors.white : AppColors.darkBlue,
//           ),
//         ),
//       ),
//       subtitle: Text(
//         message,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style:  TextStyle(color: isDarkCard ? Colors.white70 :  Color(0xFF5C74B1),),
//       ),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (createdAt != null)
//             Text(
//               '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} '
//               '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
//               style: const TextStyle(fontSize: 11, color: Colors.grey),
//             ),
//           IconButton(
//             icon: const Icon(Icons.delete, color: AppColors.darkBlue,),
//             onPressed: () => deleteNotification(notif['id']),
//           ),
//         ],
//       ),
//     ),
//   );
// }




//   // ---------------- BUILD ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFD9E1F0),
//      appBar: AppBar(
//   backgroundColor:AppColors.darkBlue,
//   elevation: 4, // subtle shadow for depth
//   shape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.vertical(
//       bottom: Radius.circular(16), // rounded bottom corners
//     ),
//   ),
//   toolbarHeight: 60, // slightly taller for premium feel
//   titleSpacing: 16,  // padding from left
//   title: const Text(
//     'Notifications',
//     style: TextStyle(
//       color: Colors.white,
//       fontSize: 18,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
//   actions: [
//     IconButton(
//       icon: const Icon(Icons.delete_sweep, color: Colors.white),
//       onPressed: () => deleteAllNotifications(),
//     ),
//   ],
// ),

//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF2A3A69)))
//           : notifications.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No notifications yet',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Color(0xFF5C74B1),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: fetchNotifications,
//                   color: const Color(0xFF2A3A69),
//                   child: ListView.builder(
//                     itemCount: notifications.length,
//                     itemBuilder: (context, index) =>
//                         buildNotificationCard(notifications[index]),
//                   ),
//                 ),
//     );
//   }
// }

















import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../helpers/backend.dart';
import 'chat_page.dart';
import '../helpers/colors.dart';
class NotificationsPage extends StatefulWidget {
  final int userId;
  final String role;

  const NotificationsPage({Key? key, required this.userId, required this.role})
      : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = true;
  List<dynamic> notifications = [];
  int unseenCount = 0;

  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    connectSocket();
    fetchNotifications();
  }

Color getCardColor(dynamic notif) {
    if (notif['title'] != null) {
      if (notif['title'].contains("Accepted")) return Colors.green.shade600;
      if (notif['title'].contains("Rejected")) return Colors.red.shade400;
      if (notif['title'].contains("Completed")) return  Colors.blueAccent;
    }
    return notif['is_seen'] ? Colors.white : const Color(0xFFD9E1F0);
  }



  // ---------------- SOCKET.IO ----------------
  void connectSocket() {
    socket = IO.io(Backend.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.onConnect((_) {
      // join user room
      socket?.emit('join', "user_${widget.userId}");
    });

    socket?.on('new_notification', (data) {
      setState(() {
        notifications.insert(0, data); // Add on top
        unseenCount += 1;
      });
    });

    socket?.onDisconnect((_) {});
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }

  // ---------------- FETCH NOTIFICATIONS ----------------
  Future<void> fetchNotifications() async {
    setState(() => isLoading = true);
    try {
      final url =
          Uri.parse("${Backend.baseUrl}/notifications?user_id=${widget.userId}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          notifications = (data['notifications'] as List<dynamic>?) ?? [];
          unseenCount = data['unseen_count'] ?? 0;
        });
        if (notifications.isNotEmpty) {
  // Group chat messages by conversation_id
  Map<String, dynamic> grouped = {};
  for (var notif in notifications) {
    if (notif['conversation_id'] != null) {
      String key = notif['conversation_id'].toString();
      if (!grouped.containsKey(key)) {
        grouped[key] = {...notif, 'count': 1};
      } else {
        grouped[key]['count'] += 1; // increment message count
        // optional: update last message
        grouped[key]['message'] = notif['message'];
        grouped[key]['created_at'] = notif['created_at'];
      }
    } else {
      // Task notification
      grouped[notif['id'].toString()] = notif;
    }
  }
  notifications = grouped.values.toList();
}


        if (unseenCount > 0) await markNotificationsSeen();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching notifications: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }










  // ---------------- MARK SEEN ----------------
  Future<void> markNotificationsSeen() async {
    try {
      final url = Uri.parse("${Backend.baseUrl}/notifications/mark_seen");
      await http.post(url, body: {'user_id': widget.userId.toString()});
      setState(() => unseenCount = 0);
    } catch (e) {
      debugPrint("Error marking notifications seen: $e");
    }
  }

  // ---------------- DELETE SINGLE ----------------
 Future<void> deleteNotification(int notifId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFFD9E1F0), // Soft background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Confirm Delete',
        style: TextStyle(
          color: Color(0xFF0A66C2),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        'Are you sure you want to delete this notification?',
        style: TextStyle(
          color: Color(0xFF2A3A69),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0A66C2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFE63946), // Red delete button
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    final url = Uri.parse("${Backend.baseUrl}/notifications/$notifId");
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      setState(() {
        notifications.removeWhere((n) => n['id'] == notifId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification deleted successfully ✅'),
          backgroundColor: const Color(0xFF0A66C2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      throw Exception('Failed to delete notification');
    }
  } catch (e) {
    debugPrint("Error deleting notification: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error deleting notification: $e',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE63946),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}




  // ---------------- DELETE ALL ----------------
  Future<void> deleteAllNotifications() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFFD9E1F0), // Soft background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Confirm Delete All',
        style: TextStyle(
          color: Color(0xFF0A66C2),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        'Are you sure you want to delete all notifications?',
        style: TextStyle(
          color: Color(0xFF2A3A69),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0A66C2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFE63946), // Red delete button
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Delete All',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    final url = Uri.parse("${Backend.baseUrl}/notifications/delete_all");
    final response = await http.post(
      url,
      body: {'user_id': widget.userId.toString()},
    );

    if (response.statusCode == 200) {
      setState(() => notifications.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications deleted successfully ✅'),
          backgroundColor: const Color(0xFF0A66C2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      throw Exception('Failed to delete all notifications');
    }
  } catch (e) {
    debugPrint("Error deleting all notifications: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error deleting all notifications: $e',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE63946),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}


  // ---------------- CARD WIDGET ----------------
  Widget buildNotificationCard(dynamic notif) {
  final senderName = (notif['sender_name'] != null &&
          notif['sender_name'].toString().trim().isNotEmpty)
      ? notif['sender_name']
      : 'Unknown User';

 // final message = notif['message'] ?? '';
  final avatar = notif['sender_avatar'];
  final createdAt = notif['created_at'] != null
      ? DateTime.tryParse(notif['created_at'])?.toLocal()
      : null;
 // final isSeen = notif['is_seen'] ?? false;
  final otherUserId = notif['sender_id'];
Color cardColor = getCardColor(notif);
bool isDarkCard = cardColor != Colors.white && cardColor != const Color(0xFFD9E1F0);
  return Card(
    color: getCardColor(notif),

    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      
     onTap: () {
  if (notif['conversation_id'] != null && otherUserId != null) {
    // Chat notification
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
  } else {
    // Task notification
   showDialog(
  context: context,
  builder: (_) => AlertDialog(
    backgroundColor: const Color(0xFFD9E1F0), // Soft pastel background
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20), // Rounded corners
    ),
    elevation: 8, // Subtle shadow for depth
    title: Row(
      children: const [
        Icon(Icons.notifications, color: AppColors.darkBlue),
        SizedBox(width: 8),
        Text(
          "Notification",
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    content: Text(
      notif['message'] ?? 'No details',
      style: const TextStyle(
        color: Color(0xFF2A3A69),
        fontSize: 15,
      ),
    ),
    actions: [
      TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text(
          "OK",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  ),
);

  }
},

      leading: CircleAvatar(
        radius: 24,
        backgroundImage: (avatar != null && avatar.toString().isNotEmpty)
            ? NetworkImage("${Backend.baseUrl}/$avatar")
            : null,
        backgroundColor: Colors.white,
        child: (avatar == null || avatar.toString().isEmpty)
            ? const Icon(Icons.person, color: AppColors.darkBlue)
            : null,
      ),
      title: Flexible(
        child: Text(
          senderName,
          maxLines: 1, // ✅ Single line
          overflow: TextOverflow.ellipsis, // ✅ Agar lamba ho to ...
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkCard ? Colors.white : AppColors.darkBlue,
          ),
        ),
      ),
    subtitle: Text(
  (notif['conversation_id'] != null ? 'Chat from $senderName: ' : '') +
  notif['message'] +
  ((notif['count'] ?? 1) > 1 ? ' (+${notif['count']-1} more)' : ''),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(color: isDarkCard ? Colors.white70 : Color(0xFF5C74B1)),
),


      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (createdAt != null)
            Text(
              '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} '
              '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.darkBlue,),
            onPressed: () => deleteNotification(notif['id']),
          ),
        ],
      ),
    ),
  );
}




  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E1F0),
     appBar: AppBar(
  backgroundColor:AppColors.darkBlue,
  elevation: 4, // subtle shadow for depth
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(16), // rounded bottom corners
    ),
  ),
  toolbarHeight: 60, // slightly taller for premium feel
  titleSpacing: 16,  // padding from left
  title: const Text(
    'Notifications',
    style: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.delete_sweep, color: Colors.white),
      onPressed: () => deleteAllNotifications(),
    ),
  ],
),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2A3A69)))
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5C74B1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchNotifications,
                  color: const Color(0xFF2A3A69),
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) =>
                        buildNotificationCard(notifications[index]),
                  ),
                ),
    );
  }
}
