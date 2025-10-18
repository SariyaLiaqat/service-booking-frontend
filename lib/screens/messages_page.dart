
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../helpers/my_colors.dart';
// import 'notifications_page.dart';
// import 'chat_page.dart';

// import '../helpers/backend.dart';
// import 'status_screen.dart';
// import '../helpers/colors.dart';
// // ---------------- MessagesTab ----------------
// class MessagesTab extends StatefulWidget {
//   final List<dynamic> conversations;
//   final int currentUserId;
//   final Future<void> Function() onRefresh;
//   final IO.Socket socket;
//   final String role;
//   final int unseenNotificationsCount;
//   // add this in MessagesTab
// final void Function(int conversationId)? onConversationSeen;  // 🔹 add this

//   MessagesTab({
//     Key? key,
//     required this.conversations,
//     required this.currentUserId,
//     required this.onRefresh,
//     required this.socket,
//     required this.role,
//     this.onConversationSeen, // 🔹 add this
//     required this.unseenNotificationsCount,
//   }) : super(key: key);

//   @override
//   _MessagesTabState createState() => _MessagesTabState();
// }







// String formatChatTime(BuildContext context, String? dateTimeStr) {
//   if (dateTimeStr == null) return '';

//   final dateTime = DateTime.parse(dateTimeStr).toLocal(); // convert to local
//   final now = DateTime.now();

//   final today = DateTime(now.year, now.month, now.day);
//   final yesterday = today.subtract(Duration(days: 1));
//   final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

//   if (msgDate == today) {
//     // Today → show time
//     return TimeOfDay.fromDateTime(dateTime).format(context);
//   } else if (msgDate == yesterday) {
//     return 'Yesterday';
//   } else {
//     // Older → show date
//     return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
//   }
// }

// class _MessagesTabState extends State<MessagesTab> {
//   List<dynamic> filteredConversations = [];
//   final TextEditingController _searchController = TextEditingController();
//   bool _isChatsSelected = true;
//   int _localUnseenNotificationsCount = 0;
//   @override
//   void initState() {
//     super.initState();
//     filteredConversations = widget.conversations;
//     _searchController.addListener(_filterChats);
//      _localUnseenNotificationsCount = widget.unseenNotificationsCount;
//     widget.socket.on('messages_seen', (data) {
//   final seenConversationId = data['conversationId'];
//   setState(() {
//     for (var conv in filteredConversations) {
//       if (conv['conversation_id'] == seenConversationId) {
//         conv['has_been_seen'] = true; // mark green
//       }
//     }
//   });
// });
// ///////////////////



// // 🔹 Add new_message listener here
//   widget.socket.on('new_message', (data) {
//   final convId = data['conversationId'];
//   final message = data['message'];
//   final createdAt = data['created_at'];
//   final otherUserId = data['other_user_id'];
//   final otherUserName = data['other_user_name'];
//   final otherUserAvatar = data['other_user_avatar'];

//   setState(() {
//     // Find conversation
//     final index = filteredConversations.indexWhere(
//       (conv) => conv['conversation_id'] == convId
//     );

//     if (index != -1) {
//       // Update existing conversation
//       filteredConversations[index]['last_message'] = message;
//       filteredConversations[index]['last_message_time'] = createdAt;
//       filteredConversations[index]['unread_count'] =
//           (filteredConversations[index]['unread_count'] ?? 0) + 1;
//     } else {
//       // Add new conversation
//       filteredConversations.insert(0, {
//         'conversation_id': convId,
//         'other_user_id': otherUserId,
//         'other_user_name': otherUserName,
//         'other_user_avatar': otherUserAvatar,
//         'last_message': message,
//         'last_message_time': createdAt,
//         'unread_count': 1,
//         'has_been_seen': false,
//       });
//     }

//     // Sort so latest message always on top
//     filteredConversations.sort((a, b) {
//       final aTime = a['last_message_time'] != null
//           ? DateTime.parse(a['last_message_time'])
//           : DateTime(2000);
//       final bTime = b['last_message_time'] != null
//           ? DateTime.parse(b['last_message_time'])
//           : DateTime(2000);
//       return bTime.compareTo(aTime);
//     });
//   });
// });



//   }

// @override
//   void dispose() {
//     _searchController.dispose();
//     widget.socket.off('messages_seen'); // remove listener
//     super.dispose();
//   }

//   @override
// void didUpdateWidget(covariant MessagesTab oldWidget) {
//   super.didUpdateWidget(oldWidget);

//   // ✅ check if unseenNotificationsCount changed
//   if (oldWidget.unseenNotificationsCount != widget.unseenNotificationsCount) {
//     setState(() {
//       _localUnseenNotificationsCount = widget.unseenNotificationsCount;
//     }); // rebuild badge
//   }

//   filteredConversations = widget.conversations;
//   _filterChats();
// }


//   void _filterChats() {
//   final query = _searchController.text.toLowerCase();
//   setState(() {
//     if (query.isEmpty) {
//       filteredConversations = List.from(widget.conversations);
//     } else {
//       filteredConversations = widget.conversations
//           .where((c) => (c['other_user_name'] ?? '').toLowerCase().contains(query))
//           .toList();
//     }

//     // 🔹 SORT BY LAST MESSAGE TIME
//     filteredConversations.sort((a, b) {
//       final aTime = a['last_message_time'] != null
//           ? DateTime.parse(a['last_message_time'])
//           : DateTime(2000);
//       final bTime = b['last_message_time'] != null
//           ? DateTime.parse(b['last_message_time'])
//           : DateTime(2000);
//       return bTime.compareTo(aTime);
//     });
//   });
// }

// int unseenNotificationsCount = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.background,

//     appBar: PreferredSize(
//   preferredSize: const Size.fromHeight(70),
//   child: AppBar(
//     backgroundColor: MyColors.surface,

//     elevation: 6,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//     ),
//     titleSpacing: 16,
//     title: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween, // left + right
//       children: [
//         // Left: My Chats
//         GestureDetector(
//           onTap: () => setState(() => _isChatsSelected = true),
//           child: Text(
//             "My Chats",
//             style: TextStyle(
//               color: _isChatsSelected ? Colors.white : Colors.white70,
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//             ),
//           ),
//         ),

//         // Right: Notifications icon with badge
//         Stack(
//           children: [
//            IconButton(
//   icon: Icon(Icons.notifications_none, color: Colors.white, size: 28),
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => NotificationsPage(
//           userId: widget.currentUserId,
//           role: widget.role,
//         ),
//       ),
//     ).then((_) {
//       // Reset local count when user comes back
//       setState(() {
//         _localUnseenNotificationsCount = 0;
//       });
//     });
//   },
// ),


//             if (_localUnseenNotificationsCount > 0)
//   Positioned(
//     right: 6,
//     top: 6,
//     child: Container(
//       width: 14,
//       height: 14,
//       decoration: BoxDecoration(
//         color: Colors.red,
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.white, width: 2),
//       ),
//       child: Center(
//         child: Text(
//           '$_localUnseenNotificationsCount',
//           style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
//         ),
//       ),
//     ),
//   ),

//           ],
//         ),
//       ],
//     ),
//   ),
// ),
//       body: Column(
//   children: [
//     // Search Bar
//     Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: TextField(
//         controller: _searchController,
//         style: const TextStyle(
//           color: MyColors.textPrimary,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           hintText: 'Search chats...',
//           hintStyle: const TextStyle(color: MyColors.textSecondary),
//          prefixIcon: const Icon(Icons.search, color: MyColors.textSecondary),
//           filled: true,
//           fillColor: MyColors.inputFill,
//           contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//          border: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(25),
//     borderSide: BorderSide.none,
//   ),
//   focusedBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(25),
//     borderSide: const BorderSide(color: MyColors.inputFocusedBorder, width: 2),
//   ),
//         ),
//       ),
//     ),

//     // Chat List / Status
//     Expanded(
//       child: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 300),
//         transitionBuilder: (child, animation) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(1, 0),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           );
//         },
//         child: _isChatsSelected
//             ? RefreshIndicator(
//                 key: const ValueKey('chats'),
//                 onRefresh: widget.onRefresh,
//                 color: MyColors.primary,
//                 child: filteredConversations.isEmpty
//                     ? ListView(
//                         children: [
//                           Center(
//                             child: Padding(
//                               padding: EdgeInsets.all(20),
//                               child: Text(
//                                 widget.conversations.isEmpty
//                                     ? 'No conversations yet'
//                                     : 'No results found',
//                                 style: TextStyle(fontSize: 16, color: MyColors.textSecondary),

//                               ),
//                             ),
//                           )
//                         ],
//                       )
//                     :ListView.builder(
//   itemCount: filteredConversations.length,
//   itemBuilder: (context, index) {
//     final conv = filteredConversations[index];
//     final convoId = conv['conversation_id'];
//     if (convoId == null) return SizedBox();

//     final otherName = conv['other_user_name'] ?? 'Unknown';
//     final otherAvatar = conv['other_user_avatar'];
//     final lastMessage = conv['last_message'] ?? '';
//     final unreadCount = conv['unread_count'] ?? 0;

//     // 🔹 Example: color logic for last message text
//     // 🔹 Message color logic
// //final unreadCount = conv['unread_count'] ?? 0;
// final hasBeenSeen = conv['has_been_seen'] ?? false; // backend/socket
// Color messageColor;

// if (unreadCount > 0) {
//   messageColor = Colors.red; // unread by you
// } else if (hasBeenSeen) {
//   messageColor = Colors.green; // receiver has seen
// } else {
//   messageColor = MyColors.textSecondary; // dark blue = new chat
// }



//                         return GestureDetector(
//   onTap: () async {
//     final otherUserId = conv['other_user_id'] ?? conv['provider_id'] ?? -1;
//     if (otherUserId == -1) return;

//     // Open Chat Page
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ChatPage(
//           conversationId: convoId,
//           currentUserId: widget.currentUserId,
//           otherUserId: otherUserId,
//         ),
//       ),
//     );
// setState(() {
//   conv['unread_count'] = 0;
// });

// // 2️⃣ Emit socket event
// try {
//   widget.socket.emit('mark_messages_seen', {
//     'conversationId': convoId,
//     'userId': widget.currentUserId,
//   });
// } catch (e) {
//   debugPrint("Socket error: $e");
// }

// // 3️⃣ Backend API call
// try {
//   await http.post(
//     Uri.parse("${Backend.baseUrl}/conversations/$convoId/seen"),
//     body: jsonEncode({'user_id': widget.currentUserId}),
//     headers: {"Content-Type": "application/json"},
//   );
// } catch (e) {
//   debugPrint("Error marking conversation seen: $e");
// }

// // 4️⃣ Update badge
// widget.onConversationSeen?.call(convoId);

//   },




//   child: Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     color: Colors.transparent,
//    child: Row(
//   children: [
//     // 🟢 Premium Avatar with Initial + Glow Ring
// // 🟢 Premium Avatar with Initial + Glow Ring
// Container(
//   padding: const EdgeInsets.all(2.5), // glowing border thickness
//   decoration: BoxDecoration(
//     shape: BoxShape.circle,
//     gradient: LinearGradient(
//       colors: [
//         Colors.blueAccent.withOpacity(0.9),
//         Colors.purpleAccent.withOpacity(0.9),
//       ],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ),
//   ),
//   child: ClipOval(
//     child: Container(
//       color: _getColorFromName(otherName),
//       child: (otherAvatar != null && otherAvatar.toString().isNotEmpty)
//           ? Image.network(
//               "${Backend.baseUrl}/$otherAvatar",
//               fit: BoxFit.cover,
//               width: 56,
//               height: 56,
//               errorBuilder: (context, error, stackTrace) => _buildInitialAvatar(otherName),
//             )
//           : _buildInitialAvatar(otherName),
//     ),
//   ),
// ),

//     SizedBox(width: 12),
//     Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             otherName,
//             style: TextStyle(
//               color: MyColors.textPrimary,

//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             lastMessage,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: messageColor,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     ),
//     SizedBox(width: 8),
//     // 🔹 Add formatted time here
//    Text(
//   formatChatTime(context, conv['last_message_time']),
//   style: TextStyle(
//     color: MyColors.textSecondary,

//     fontSize: 12,
//   ),
// ),

//     if (unreadCount > 0) ...[
//       SizedBox(width: 8),
//       Container(
//         padding: EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color: MyColors.error,

//           shape: BoxShape.circle,
//         ),
//         child: Text(
//           '$unreadCount',
//           style: TextStyle(color: Colors.white, fontSize: 12),
//         ),
//       ),
//     ],
//   ],
// ),




//   ),
// );                     
//                         },
//                       ),
//               )

//             : StatusPage(
//                 key: const ValueKey('status'),
//                 currentUserId: widget.currentUserId,
//                 isProvider: widget.role == "provider",
//               ),
//       ),
//     ),
//   ],
    
//       )

//     );
//   }





//   // 🔹 Generate consistent random color from name
// Color _getColorFromName(String name) {
//   final colors = [
//     Colors.deepPurple,
//     Colors.teal,
//     Colors.indigo,
//     Colors.orange,
//     Colors.pinkAccent,
//     Colors.cyan,
//     Colors.blueGrey,
//     Colors.deepOrangeAccent,
//     Colors.green,
//     Colors.redAccent,
//   ];

//   if (name.isEmpty) return Colors.grey;
//   int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
//   return colors[hash % colors.length];
// }




// Widget _buildInitialAvatar(String name) {
//   final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
//   final letterColor = _getColorFromName(name); // random stylish color per user
  
//   return Container(
//     width: 56,
//     height: 56,
//     alignment: Alignment.center,
//     decoration: BoxDecoration(
//       color: MyColors.surface, // ✅ background fixed
//       shape: BoxShape.circle,
//     ),
//     child: Text(
//       initial,
//       style: TextStyle(
//         color: letterColor, // ✅ first letter color changes dynamically
//         fontWeight: FontWeight.bold,
//         fontSize: 22,
//       ),
//     ),
//   );
// }


// }



















import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/my_colors.dart';
import 'notifications_page.dart';
import 'chat_page.dart';
import '../helpers/backend.dart';
import 'status_screen.dart';
//import '../helpers/colors.dart';
import '../helpers/socket_manager.dart'; // ✅ SocketManager import

class MessagesTab extends StatefulWidget {
  final List<dynamic> conversations;
  final int currentUserId;
  final Future<void> Function() onRefresh;
  final String role;
  final int unseenNotificationsCount;
  final void Function(int conversationId)? onConversationSeen;

  MessagesTab({
    Key? key,
    required this.conversations,
    required this.currentUserId,
    required this.onRefresh,
    required this.role,
    this.onConversationSeen,
    required this.unseenNotificationsCount,
  }) : super(key: key);

  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  List<dynamic> filteredConversations = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isChatsSelected = true;
  int _localUnseenNotificationsCount = 0;
  late final socket = SocketManager().socket!; // ✅ Use singleton socket

  @override
  void initState() {
    super.initState();
    filteredConversations = widget.conversations;
    _searchController.addListener(_filterChats);
    _localUnseenNotificationsCount = widget.unseenNotificationsCount;

    // 🔹 Listen for messages seen
    socket.on('messages_seen', (data) {
      final seenConversationId = data['conversationId'];
      setState(() {
        for (var conv in filteredConversations) {
          if (conv['conversation_id'] == seenConversationId) {
            conv['has_been_seen'] = true;
          }
        }
      });
    });

    // 🔹 Listen for new messages
    socket.on('new_message', (data) {
      final convId = data['conversationId'];
      final message = data['message'];
      final createdAt = data['created_at'];
      final otherUserId = data['other_user_id'];
      final otherUserName = data['other_user_name'];
      final otherUserAvatar = data['other_user_avatar'];

      setState(() {
        final index = filteredConversations.indexWhere(
            (conv) => conv['conversation_id'] == convId);

        if (index != -1) {
          filteredConversations[index]['last_message'] = message;
          filteredConversations[index]['last_message_time'] = createdAt;
          filteredConversations[index]['unread_count'] =
              (filteredConversations[index]['unread_count'] ?? 0) + 1;
        } else {
          filteredConversations.insert(0, {
            'conversation_id': convId,
            'other_user_id': otherUserId,
            'other_user_name': otherUserName,
            'other_user_avatar': otherUserAvatar,
            'last_message': message,
            'last_message_time': createdAt,
            'unread_count': 1,
            'has_been_seen': false,
          });
        }

        filteredConversations.sort((a, b) {
          final aTime = a['last_message_time'] != null
              ? DateTime.parse(a['last_message_time'])
              : DateTime(2000);
          final bTime = b['last_message_time'] != null
              ? DateTime.parse(b['last_message_time'])
              : DateTime(2000);
          return bTime.compareTo(aTime);
        });
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    socket.off('messages_seen');
    socket.off('new_message');
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessagesTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.unseenNotificationsCount !=
        widget.unseenNotificationsCount) {
      setState(() {
        _localUnseenNotificationsCount = widget.unseenNotificationsCount;
      });
    }

    filteredConversations = widget.conversations;
    _filterChats();
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredConversations = List.from(widget.conversations);
      } else {
        filteredConversations = widget.conversations
            .where((c) =>
                (c['other_user_name'] ?? '').toLowerCase().contains(query))
            .toList();
      }

      filteredConversations.sort((a, b) {
        final aTime = a['last_message_time'] != null
            ? DateTime.parse(a['last_message_time'])
            : DateTime(2000);
        final bTime = b['last_message_time'] != null
            ? DateTime.parse(b['last_message_time'])
            : DateTime(2000);
        return bTime.compareTo(aTime);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: MyColors.surface,
          elevation: 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          titleSpacing: 16,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isChatsSelected = true),
                child: Text(
                  "My Chats",
                  style: TextStyle(
                    color: _isChatsSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none,
                        color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsPage(
                            userId: widget.currentUserId,
                            role: widget.role,
                          ),
                        ),
                      ).then((_) {
                        setState(() {
                          _localUnseenNotificationsCount = 0;
                        });
                      });
                    },
                  ),
                  if (_localUnseenNotificationsCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '$_localUnseenNotificationsCount',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: MyColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: const TextStyle(color: MyColors.textSecondary),
                prefixIcon:
                    const Icon(Icons.search, color: MyColors.textSecondary),
                filled: true,
                fillColor: MyColors.inputFill,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                      color: MyColors.inputFocusedBorder, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: _isChatsSelected
                  ? RefreshIndicator(
                      key: const ValueKey('chats'),
                      onRefresh: widget.onRefresh,
                      color: MyColors.primary,
                      child: filteredConversations.isEmpty
                          ? ListView(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      widget.conversations.isEmpty
                                          ? 'No conversations yet'
                                          : 'No results found',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: MyColors.textSecondary),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : ListView.builder(
                              itemCount: filteredConversations.length,
                              itemBuilder: (context, index) {
                                final conv = filteredConversations[index];
                                final convoId = conv['conversation_id'];
                                if (convoId == null) return SizedBox();
                                final otherName =
                                    conv['other_user_name'] ?? 'Unknown';
                                final otherAvatar = conv['other_user_avatar'];
                                final lastMessage = conv['last_message'] ?? '';
                                final unreadCount = conv['unread_count'] ?? 0;
                                final hasBeenSeen =
                                    conv['has_been_seen'] ?? false;

                                Color messageColor;
                                if (unreadCount > 0) {
                                  messageColor = Colors.red;
                                } else if (hasBeenSeen) {
                                  messageColor = Colors.green;
                                } else {
                                  messageColor = MyColors.textSecondary;
                                }

                                return GestureDetector(
                                  onTap: () async {
                                    final otherUserId = conv['other_user_id'] ??
                                        conv['provider_id'] ??
                                        -1;
                                    if (otherUserId == -1) return;

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatPage(
                                          conversationId: convoId,
                                          currentUserId: widget.currentUserId,
                                          otherUserId: otherUserId,
                                        ),
                                      ),
                                    );

                                    setState(() {
                                      conv['unread_count'] = 0;
                                    });

                                    // 🔹 Emit socket event
                                    try {
                                      socket.emit('mark_messages_seen', {
                                        'conversationId': convoId,
                                        'userId': widget.currentUserId,
                                      });
                                    } catch (e) {
                                      debugPrint("Socket error: $e");
                                    }

                                    // 🔹 Backend call
                                    try {
                                      await http.post(
                                        Uri.parse(
                                            "${Backend.baseUrl}/conversations/$convoId/seen"),
                                        body: jsonEncode(
                                            {'user_id': widget.currentUserId}),
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                      );
                                    } catch (e) {
                                      debugPrint(
                                          "Error marking conversation seen: $e");
                                    }

                                    widget.onConversationSeen?.call(convoId);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(2.5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blueAccent
                                                    .withOpacity(0.9),
                                                Colors.purpleAccent
                                                    .withOpacity(0.9),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: Container(
                                              color: _getColorFromName(otherName),
                                              child: (otherAvatar != null &&
                                                      otherAvatar
                                                          .toString()
                                                          .isNotEmpty)
                                                  ? Image.network(
                                                      "${Backend.baseUrl}/$otherAvatar",
                                                      fit: BoxFit.cover,
                                                      width: 56,
                                                      height: 56,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          _buildInitialAvatar(
                                                              otherName),
                                                    )
                                                  : _buildInitialAvatar(otherName),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                otherName,
                                                style: TextStyle(
                                                  color: MyColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                lastMessage,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: messageColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          formatChatTime(
                                              context, conv['last_message_time']),
                                          style: TextStyle(
                                            color: MyColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (unreadCount > 0) ...[
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: MyColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$unreadCount',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    )
                  : StatusPage(
                      key: const ValueKey('status'),
                      currentUserId: widget.currentUserId,
                      isProvider: widget.role == "provider",
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.deepPurple,
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.pinkAccent,
      Colors.cyan,
      Colors.blueGrey,
      Colors.deepOrangeAccent,
      Colors.green,
      Colors.redAccent,
    ];
    if (name.isEmpty) return Colors.grey;
    int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    return colors[hash % colors.length];
  }

  Widget _buildInitialAvatar(String name) {
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final letterColor = _getColorFromName(name);
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MyColors.surface,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: letterColor,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}

// ✅ formatChatTime function stays the same
String formatChatTime(BuildContext context, String? dateTimeStr) {
  if (dateTimeStr == null) return '';
  final dateTime = DateTime.parse(dateTimeStr).toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));
  final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
  if (msgDate == today) return TimeOfDay.fromDateTime(dateTime).format(context);
  if (msgDate == yesterday) return 'Yesterday';
  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
}
