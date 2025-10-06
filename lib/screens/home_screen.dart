








  
 

 
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'MyProfileScreen.dart';
// import 'services.dart';
// import 'notifications_page.dart';
// import 'chat_page.dart';
// import 'my_tasks_screen.dart';
// import '../helpers/backend.dart';
// import 'status_screen.dart';
// import '../helpers/colors.dart';
// class HomeScreen extends StatefulWidget {
//   final String role;
//   final Map<String, dynamic> userData;

//   HomeScreen({required this.role, required this.userData});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   final GlobalKey<ServicesScreenState> _servicesKey =
//       GlobalKey<ServicesScreenState>();

//   List<dynamic> conversations = [];
//   bool isLoadingConversations = true;
//   int unreadMessagesCount = 0;
//   int unseenNotificationsCount = 0;
//   late IO.Socket socket;
//   //late StatusController statusController;
//   @override
//   void initState() {
//     super.initState();
//     fetchConversations();
//     fetchUnseenNotifications();
//     initSocket();
//   }

//   void initSocket() {
//     socket = IO.io(Backend.baseUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     socket.connect();

//     socket.onConnect((_) {
//       print("Socket connected");
//       socket.emit('user_online', widget.userData['id']);
//     });

//     socket.on('new_message', (data) {
//       if (data['receiverId'] == widget.userData['id']) {
//         setState(() {
//           unreadMessagesCount += 1;
//         });
//       }
//     });

//     socket.on('update_conversation_list', (data) {
//       fetchConversations();
//     });

//     socket.on('notification_received', (data) {
//       if (data['userId'] == widget.userData['id']) {
//         setState(() => unseenNotificationsCount += 1);
//       }
//     });
//   }

//   Future<void> fetchConversations() async {
//     setState(() => isLoadingConversations = true);
//     try {
//       final userId = widget.userData['id'];
//       if (userId == null) return;

//       final url = Uri.parse("${Backend.baseUrl}/conversations?user_id=$userId");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           conversations = (data['conversations'] as List<dynamic>?) ?? [];
//           unreadMessagesCount = conversations.fold<int>(0, (sum, c) {
//             final count = c['unread_count'];
//             if (count is int) return sum + count;
//             if (count is double) return sum + count.toInt();
//             return sum;
//           });
//         });
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to load conversations')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching conversations: $e')),
//       );
//     } finally {
//       setState(() => isLoadingConversations = false);
//     }
//   }

//   Future<void> fetchUnseenNotifications() async {
//     try {
//       final userId = widget.userData['id'];
//       final url = Uri.parse("${Backend.baseUrl}/notifications?user_id=$userId");
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           unseenNotificationsCount = data['unseen_count'] ?? 0;
//         });
//       }
//     } catch (e) {
//       print("Error fetching unseen notifications: $e");
//     }
//   }

//   void resetUnreadMessages() {
//     setState(() => unreadMessagesCount = 0);
//   }

//   void resetUnseenNotifications() {
//     setState(() => unseenNotificationsCount = 0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pages = [
//       ServicesScreen(
//         key: _servicesKey,
//         currentUserId: widget.userData["id"] ?? -1,
//       ),
//       MyTasksScreen(
//         currentUserId: widget.userData["id"] ?? -1,
//         role: widget.role,
//       ),
//      MessagesTab(
//   conversations: conversations,
//   currentUserId: widget.userData['id'] ?? -1,
//   onRefresh: fetchConversations,
//   socket: socket,
//   role: widget.role,
//   onConversationSeen: (conversationId) {  // 🔹 Add this
//     setState(() {
//       for (var c in conversations) {
//         if (c['conversation_id'] == conversationId) {
//           c['unread_count'] = 0;
//           break;
//         }
//       }
//       // Update total unreadMessagesCount
//      unreadMessagesCount = conversations.fold<int>(0, (sum, c) {
//   final dynamic count = c['unread_count'];
//   final num safeCount;

//   if (count == null) {
//     safeCount = 0;
//   } else if (count is int || count is double) {
//     safeCount = count;
//   } else if (count is String) {
//     safeCount = int.tryParse(count) ?? 0;
//   } else {
//     safeCount = 0;
//   }

//   return sum + safeCount.toInt();
// });



//     });
//   },
// ),

//       NotificationsPage(userId: widget.userData["id"] ?? -1, role: widget.role),
//       MyProfileScreen(
//         userData: widget.userData,
//         currentUserId: widget.userData['id'],
//         //   onProfileUpdated: () => _servicesKey.currentState?.fetchProviders(),
//       ),
//     ];

//     return Scaffold(
//       body: IndexedStack(index: _currentIndex, children: pages),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Color(0xFF0A66C2),
//           unselectedItemColor: Color(0xFF5C74B1),
//           onTap: (index) {
//             setState(() => _currentIndex = index);
//             if (index == 2) resetUnreadMessages();
//             if (index == 3) resetUnseenNotifications();
//           },
//           items: [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Services'),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.check_circle_outline),
//               label: 'Tasks',
//             ),
//             BottomNavigationBarItem(
//               icon: Stack(
//                 children: [
//                   Icon(Icons.message),
//                   if (unreadMessagesCount > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Text(
//                           '$unreadMessagesCount',
//                           style: TextStyle(color: Colors.white, fontSize: 10),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               label: 'Messages',
//             ),
//             BottomNavigationBarItem(
//               icon: Stack(
//                 children: [
//                   Icon(Icons.notifications),
//                   if (unseenNotificationsCount > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Text(
//                           '$unseenNotificationsCount',
//                           style: TextStyle(color: Colors.white, fontSize: 10),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               label: 'Notifications',
//             ),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------------- MessagesTab ----------------
// class MessagesTab extends StatefulWidget {
//   final List<dynamic> conversations;
//   final int currentUserId;
//   final Future<void> Function() onRefresh;
//   final IO.Socket socket;
//   final String role;
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
//   }) : super(key: key);

//   @override
//   _MessagesTabState createState() => _MessagesTabState();
// }

// class _MessagesTabState extends State<MessagesTab> {
//   List<dynamic> filteredConversations = [];
//   final TextEditingController _searchController = TextEditingController();
//   bool _isChatsSelected = true;
//   @override
//   void initState() {
//     super.initState();
//     filteredConversations = widget.conversations;
//     _searchController.addListener(_filterChats);
//   }

//   @override
//   void didUpdateWidget(covariant MessagesTab oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     filteredConversations = widget.conversations;
//     _filterChats();
//   }

//   void _filterChats() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       if (query.isEmpty) {
//         filteredConversations = List.from(widget.conversations);
//       } else {
//         filteredConversations = widget.conversations
//             .where(
//               (c) => (c['other_user_name'] ?? '').toLowerCase().contains(query),
//             )
//             .toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: AppBar(
//           backgroundColor: AppColors.darkBlue,
//           elevation: 6,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//           ),
//           titleSpacing: 16,
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               GestureDetector(
//                 onTap: () => setState(() => _isChatsSelected = true),
//                 child: Text(
//                   "My Chats",
//                   style: TextStyle(
//                     color: _isChatsSelected ? Colors.white : Colors.white70,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => setState(() => _isChatsSelected = false),
//                 child: Text(
//                   "Status",
//                   style: TextStyle(
//                     color: !_isChatsSelected ? Colors.white : Colors.white70,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),

//       body: Column(
//   children: [
//     // Search Bar
//     Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: TextField(
//         controller: _searchController,
//         style: const TextStyle(
//           color: Color(0xFF2A3A69),
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           hintText: 'Search chats...',
//           hintStyle: const TextStyle(color: Color(0xFF5C74B1)),
//           prefixIcon: const Icon(Icons.search, color: Color(0xFF5C74B1)),
//           filled: true,
//           fillColor: const Color(0xFFD9E1F0),
//           contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(25),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(25),
//             borderSide: const BorderSide(
//               color: AppColors.darkBlue,
//               width: 2,
//             ),
//           ),
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
//                 color: AppColors.darkBlue,
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
//                                 style: TextStyle(fontSize: 16, color: Color(0xFF5C74B1)),
//                               ),
//                             ),
//                           )
//                         ],
//                       )
//                     : ListView.builder(
//                         itemCount: filteredConversations.length,
//                         itemBuilder: (context, index) {
//                           final conv = filteredConversations[index];
//                           final convoId = conv['conversation_id'];
//                           if (convoId == null) return SizedBox();

//                           final otherName = conv['other_user_name'] ?? 'Unknown';
//                           final otherAvatar = conv['other_user_avatar'];
//                           final lastMessage = conv['last_message'] ?? '';
//                           final unreadCount = conv['unread_count'] ?? 0;

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

//     // 1️⃣ Update local unread_count
//     setState(() {
//       conv['unread_count'] = 0;
//     });

//     // 2️⃣ Emit socket event
//     try {
//       widget.socket.emit('mark_messages_seen', {
//         'conversationId': convoId,
//         'userId': widget.currentUserId,
//       });
//     } catch (e) {
//       debugPrint("Socket error: $e");
//     }

//     // 3️⃣ 🔹 Backend API call to mark conversation as seen
//     try {
//       await http.post(
//         Uri.parse("${Backend.baseUrl}/conversations/$convoId/seen"),
//         body: jsonEncode({'user_id': widget.currentUserId}),
//         headers: {"Content-Type": "application/json"},
//       );
//     } catch (e) {
//       debugPrint("Error marking conversation seen: $e");
//     }

//     // 4️⃣ Call callback to HomeScreen to update badge
//     widget.onConversationSeen?.call(convoId);
//   },
//   child: Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     color: Colors.transparent,
//     child: Row(
//       children: [
//         CircleAvatar(
//           radius: 28,
//           backgroundImage: (otherAvatar != null && otherAvatar.toString().isNotEmpty)
//               ? NetworkImage("${Backend.baseUrl}/$otherAvatar")
//               : null,
//           child: (otherAvatar == null || otherAvatar.toString().isEmpty)
//               ? Icon(Icons.person, color: AppColors.darkBlue)
//               : null,
//           backgroundColor: Color(0xFFD9E1F0),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 otherName,
//                 style: TextStyle(
//                   color: Color(0xFF0A66C2),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 lastMessage,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: Color(0xFF5C74B1),
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (unreadCount > 0)
//           Container(
//             padding: EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.red,
//               shape: BoxShape.circle,
//             ),
//             child: Text(
//               '$unreadCount',
//               style: TextStyle(color: Colors.white, fontSize: 12),
//             ),
//           ),
//       ],
//     ),
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
// }
















  


  








  
 

 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'MyProfileScreen.dart';
import 'services.dart';
import 'notifications_page.dart';
import 'chat_page.dart';
import 'my_tasks_screen.dart';
import '../helpers/backend.dart';
import 'status_screen.dart';
import '../helpers/colors.dart';
class HomeScreen extends StatefulWidget {
  final String role;
  final Map<String, dynamic> userData;

  HomeScreen({required this.role, required this.userData});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ServicesScreenState> _servicesKey =
      GlobalKey<ServicesScreenState>();

  List<dynamic> conversations = [];
  bool isLoadingConversations = true;
  int unreadMessagesCount = 0;
  int unseenNotificationsCount = 0;
  late IO.Socket socket;
  //late StatusController statusController;
  @override
  void initState() {
    super.initState();
    fetchConversations();
    fetchUnseenNotifications();
    initSocket();
  }

  void initSocket() {
    socket = IO.io(Backend.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.onConnect((_) {
      print("Socket connected");
      socket.emit('user_online', widget.userData['id']);
    });

    socket.on('new_message', (data) {
      if (data['receiverId'] == widget.userData['id']) {
        setState(() {
          unreadMessagesCount += 1;
        });
      }
    });

    socket.on('update_conversation_list', (data) {
      fetchConversations();
    });

    socket.on('notification_received', (data) {
      if (data['userId'] == widget.userData['id']) {
        setState(() => unseenNotificationsCount += 1);
      }
    });
  }

  Future<void> fetchConversations() async {
    setState(() => isLoadingConversations = true);
    try {
      final userId = widget.userData['id'];
      if (userId == null) return;

      final url = Uri.parse("${Backend.baseUrl}/conversations?user_id=$userId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          conversations = (data['conversations'] as List<dynamic>?) ?? [];
          unreadMessagesCount = conversations.fold<int>(0, (sum, c) {
            final count = c['unread_count'];
            if (count is int) return sum + count;
            if (count is double) return sum + count.toInt();
            return sum;
          });
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load conversations')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching conversations: $e')),
      );
    } finally {
      setState(() => isLoadingConversations = false);
    }
  }

  Future<void> fetchUnseenNotifications() async {
    try {
      final userId = widget.userData['id'];
      final url = Uri.parse("${Backend.baseUrl}/notifications?user_id=$userId");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          unseenNotificationsCount = data['unseen_count'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching unseen notifications: $e");
    }
  }

  void resetUnreadMessages() {
    setState(() => unreadMessagesCount = 0);
  }

  void resetUnseenNotifications() {
    setState(() => unseenNotificationsCount = 0);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ServicesScreen(
        key: _servicesKey,
        currentUserId: widget.userData["id"] ?? -1,
      ),
      MyTasksScreen(
        currentUserId: widget.userData["id"] ?? -1,
        role: widget.role,
        
      ),
     MessagesTab(
  conversations: conversations,
  currentUserId: widget.userData['id'] ?? -1,
  onRefresh: fetchConversations,
  socket: socket,
  role: widget.role,
  onConversationSeen: (conversationId) {  // 🔹 Add this
    setState(() {
      for (var c in conversations) {
        if (c['conversation_id'] == conversationId) {
          c['unread_count'] = 0;
          break;
        }
      }
      // Update total unreadMessagesCount
     unreadMessagesCount = conversations.fold<int>(0, (sum, c) {
  final dynamic count = c['unread_count'];
  final num safeCount;

  if (count == null) {
    safeCount = 0;
  } else if (count is int || count is double) {
    safeCount = count;
  } else if (count is String) {
    safeCount = int.tryParse(count) ?? 0;
  } else {
    safeCount = 0;
  }

  return sum + safeCount.toInt();
});



    });
  },
),

      NotificationsPage(userId: widget.userData["id"] ?? -1, role: widget.role),
      MyProfileScreen(
        userData: widget.userData,
        currentUserId: widget.userData['id'],
        //   onProfileUpdated: () => _servicesKey.currentState?.fetchProviders(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF0A66C2),
          unselectedItemColor: Color(0xFF5C74B1),
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 2) resetUnreadMessages();
            if (index == 3) resetUnseenNotifications();
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Services'),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.message),
                  if (unreadMessagesCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadMessagesCount',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.notifications),
                  if (unseenNotificationsCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unseenNotificationsCount',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}





// ---------------- MessagesTab ----------------
class MessagesTab extends StatefulWidget {
  final List<dynamic> conversations;
  final int currentUserId;
  final Future<void> Function() onRefresh;
  final IO.Socket socket;
  final String role;
  // add this in MessagesTab
final void Function(int conversationId)? onConversationSeen;  // 🔹 add this

  MessagesTab({
    Key? key,
    required this.conversations,
    required this.currentUserId,
    required this.onRefresh,
    required this.socket,
    required this.role,
    this.onConversationSeen, // 🔹 add this
  }) : super(key: key);

  @override
  _MessagesTabState createState() => _MessagesTabState();
}


String formatChatTime(BuildContext context, String? dateTimeStr) {
  if (dateTimeStr == null) return '';

  final dateTime = DateTime.parse(dateTimeStr).toLocal(); // convert to local
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));
  final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (msgDate == today) {
    // Today → show time
    return TimeOfDay.fromDateTime(dateTime).format(context);
  } else if (msgDate == yesterday) {
    return 'Yesterday';
  } else {
    // Older → show date
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }
}

class _MessagesTabState extends State<MessagesTab> {
  List<dynamic> filteredConversations = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isChatsSelected = true;
  @override
  void initState() {
    super.initState();
    filteredConversations = widget.conversations;
    _searchController.addListener(_filterChats);
    widget.socket.on('messages_seen', (data) {
  final seenConversationId = data['conversationId'];
  setState(() {
    for (var conv in filteredConversations) {
      if (conv['conversation_id'] == seenConversationId) {
        conv['has_been_seen'] = true; // mark green
      }
    }
  });
});
///////////////////



// 🔹 Add new_message listener here
  widget.socket.on('new_message', (data) {
  final convId = data['conversationId'];
  final message = data['message'];
  final createdAt = data['created_at'];
  final otherUserId = data['other_user_id'];
  final otherUserName = data['other_user_name'];
  final otherUserAvatar = data['other_user_avatar'];

  setState(() {
    // Find conversation
    final index = filteredConversations.indexWhere(
      (conv) => conv['conversation_id'] == convId
    );

    if (index != -1) {
      // Update existing conversation
      filteredConversations[index]['last_message'] = message;
      filteredConversations[index]['last_message_time'] = createdAt;
      filteredConversations[index]['unread_count'] =
          (filteredConversations[index]['unread_count'] ?? 0) + 1;
    } else {
      // Add new conversation
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

    // Sort so latest message always on top
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
    widget.socket.off('messages_seen'); // remove listener
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessagesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
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
          .where((c) => (c['other_user_name'] ?? '').toLowerCase().contains(query))
          .toList();
    }

    // 🔹 SORT BY LAST MESSAGE TIME
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: AppColors.darkBlue,
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
              GestureDetector(
                onTap: () => setState(() => _isChatsSelected = false),
                child: Text(
                  "Status",
                  style: TextStyle(
                    color: !_isChatsSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
  children: [
    // Search Bar
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Color(0xFF2A3A69),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search chats...',
          hintStyle: const TextStyle(color: Color(0xFF5C74B1)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF5C74B1)),
          filled: true,
          fillColor: const Color(0xFFD9E1F0),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: AppColors.darkBlue,
              width: 2,
            ),
          ),
        ),
      ),
    ),

    // Chat List / Status
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
                color: AppColors.darkBlue,
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
                                style: TextStyle(fontSize: 16, color: Color(0xFF5C74B1)),
                              ),
                            ),
                          )
                        ],
                      )
                    :ListView.builder(
  itemCount: filteredConversations.length,
  itemBuilder: (context, index) {
    final conv = filteredConversations[index];
    final convoId = conv['conversation_id'];
    if (convoId == null) return SizedBox();

    final otherName = conv['other_user_name'] ?? 'Unknown';
    final otherAvatar = conv['other_user_avatar'];
    final lastMessage = conv['last_message'] ?? '';
    final unreadCount = conv['unread_count'] ?? 0;

    // 🔹 Example: color logic for last message text
    // 🔹 Message color logic
//final unreadCount = conv['unread_count'] ?? 0;
final hasBeenSeen = conv['has_been_seen'] ?? false; // backend/socket
Color messageColor;

if (unreadCount > 0) {
  messageColor = Colors.red; // unread by you
} else if (hasBeenSeen) {
  messageColor = Colors.green; // receiver has seen
} else {
  messageColor = Color(0xFF0A66C2); // dark blue = new chat
}



                        return GestureDetector(
  onTap: () async {
    final otherUserId = conv['other_user_id'] ?? conv['provider_id'] ?? -1;
    if (otherUserId == -1) return;

    // Open Chat Page
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

    // 1️⃣ Update local unread_count
   // 1️⃣ Update local unread_count
setState(() {
  conv['unread_count'] = 0;
});

// 2️⃣ Emit socket event
try {
  widget.socket.emit('mark_messages_seen', {
    'conversationId': convoId,
    'userId': widget.currentUserId,
  });
} catch (e) {
  debugPrint("Socket error: $e");
}

// 3️⃣ Backend API call
try {
  await http.post(
    Uri.parse("${Backend.baseUrl}/conversations/$convoId/seen"),
    body: jsonEncode({'user_id': widget.currentUserId}),
    headers: {"Content-Type": "application/json"},
  );
} catch (e) {
  debugPrint("Error marking conversation seen: $e");
}

// 4️⃣ Update badge
widget.onConversationSeen?.call(convoId);

  },




  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    color: Colors.transparent,
   child: Row(
  children: [
    CircleAvatar(
      radius: 28,
      backgroundImage: (otherAvatar != null && otherAvatar.toString().isNotEmpty)
          ? NetworkImage("${Backend.baseUrl}/$otherAvatar")
          : null,
      child: (otherAvatar == null || otherAvatar.toString().isEmpty)
          ? Icon(Icons.person, color: AppColors.darkBlue)
          : null,
      backgroundColor: Color(0xFFD9E1F0),
    ),
    SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            otherName,
            style: TextStyle(
              color: Color(0xFF0A66C2),
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
    // 🔹 Add formatted time here
   Text(
  formatChatTime(context, conv['last_message_time']),
  style: TextStyle(
    color: Color(0xFF5C74B1),
    fontSize: 12,
  ),
),

    if (unreadCount > 0) ...[
      SizedBox(width: 8),
      Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$unreadCount',
          style: TextStyle(color: Colors.white, fontSize: 12),
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
      
      )

    );
  }
}


