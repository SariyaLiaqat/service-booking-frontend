

// ///////////////////////
// ///
// ///


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

// class HomeScreen extends StatefulWidget {
//   final String role;
//   final Map<String, dynamic> userData;

//   HomeScreen({required this.role, required this.userData});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   final GlobalKey<ServicesScreenState> _servicesKey = GlobalKey<ServicesScreenState>();

//   List<dynamic> conversations = [];
//   bool isLoadingConversations = true;
//   int unreadMessagesCount = 0;
//   int unseenNotificationsCount = 0;

//   late IO.Socket socket;

//   @override
//   void initState() {
//     super.initState();
//     fetchConversations();
//     fetchUnseenNotifications();
//     initSocket();
//   }

//   void initSocket() {
//     socket = IO.io(
//       Backend.baseUrl,
//       <String, dynamic>{'transports': ['websocket'], 'autoConnect': true},
//     );

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
//           unreadMessagesCount = conversations.fold<int>(
//             0,
//             (sum, c) {
//               final count = c['unread_count'];
//               if (count is int) return sum + count;
//               if (count is double) return sum + count.toInt();
//               return sum;
//             },
//           );
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load conversations')),
//         );
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
//       MessagesTab(
//         conversations: conversations,
//         currentUserId: widget.userData['id'] ?? -1,
//         onRefresh: fetchConversations,
//       ),
//       NotificationsPage(
//         userId: widget.userData["id"] ?? -1,
//         role: widget.role,
//       ),
//       MyProfileScreen(
//         userData: widget.userData,
//         currentUserId: widget.userData['id'],
//         onProfileUpdated: () => _servicesKey.currentState?.fetchProviders(),
//       ),
//     ];

//     return Scaffold(
//       body: IndexedStack(index: _currentIndex, children: pages),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               blurRadius: 10,
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor:Color(0xFF0A66C2),
//           unselectedItemColor: Color(0xFF5C74B1),
//           onTap: (index) {
//             setState(() => _currentIndex = index);
//             if (index == 2) resetUnreadMessages();
//             if (index == 3) resetUnseenNotifications();
//           },
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'Services',
//             ),
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
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person),
//               label: 'Profile',
//             ),
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

//   MessagesTab({
//     required this.conversations,
//     required this.currentUserId,
//     required this.onRefresh,
//   });

//   @override
//   _MessagesTabState createState() => _MessagesTabState();
// }

// class _MessagesTabState extends State<MessagesTab> {
//   List<dynamic> filteredConversations = [];
//   final TextEditingController _searchController = TextEditingController();

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
//             .where((c) => (c['other_user_name'] ?? '').toLowerCase().contains(query))
//             .toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFFFFFF),
//      appBar: PreferredSize(
//   preferredSize: const Size.fromHeight(70), // thoda height increase
//   child: AppBar(
//     backgroundColor: const Color(0xFF0A66C2), // Premium LinkedIn Blue
//     elevation: 6, // subtle shadow for depth
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         bottom: Radius.circular(20), // Rounded bottom corners
//       ),
//     ),
//     titleSpacing: 16, // padding from left
//     title: const Text(
//       "My Chats",
//       style: TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.bold,
//         fontSize: 20,
//       ),
//     ),
//     centerTitle: false, // title left-aligned
//   ),
// ),

//       body: Column(
//         children: [
//          Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//   child: TextField(
//     controller: _searchController,
//     style: const TextStyle(
//       color: Color(0xFF2A3A69), // Premium dark text
//       fontWeight: FontWeight.w500,
//     ),
//     decoration: InputDecoration(
//       hintText: 'Search chats...',
//       hintStyle: const TextStyle(color: Color(0xFF5C74B1)),
//       prefixIcon: const Icon(Icons.search, color: Color(0xFF5C74B1)),
//       filled: true,
//       fillColor: const Color(0xFFD9E1F0), // Light blue background
//       contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(25), // Rounded fully
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(25),
//         borderSide: const BorderSide(
//           color: Color(0xFF0A66C2), // LinkedIn blue focus
//           width: 2,
//         ),
//       ),
//     ),
//   ),
// ),

//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: widget.onRefresh,
//               color:  Color(0xFF0A66C2),
//               child: filteredConversations.isEmpty
//                   ? ListView(
//                       children: [
//                         Center(
//                           child: Padding(
//                             padding: EdgeInsets.all(20),
//                             child: Text(
//                               widget.conversations.isEmpty
//                                   ? 'No conversations yet'
//                                   : 'No results found',
//                               style: TextStyle(fontSize: 16, color: Color(0xFF5C74B1)),
//                             ),
//                           ),
//                         )
//                       ],
//                     )
//                   : ListView.builder(
//                       itemCount: filteredConversations.length,
//                       itemBuilder: (context, index) {
//                         final conv = filteredConversations[index];
//                         final convoId = conv['conversation_id'];
//                         if (convoId == null) return SizedBox();

//                         final otherName = conv['other_user_name'] ?? 'Unknown';
//                         final otherAvatar = conv['other_user_avatar'];
//                         final lastMessage = conv['last_message'] ?? '';
//                         final unreadCount = conv['unread_count'] ?? 0;

//                         return Card(
//                           margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 2,
//                           child: ListTile(
//                             leading: CircleAvatar(
//                               backgroundImage: (otherAvatar != null && otherAvatar.toString().isNotEmpty)
//                                   ? NetworkImage("${Backend.baseUrl}/$otherAvatar")
//                                   : null,
//                               child: (otherAvatar == null || otherAvatar.toString().isEmpty)
//                                   ? Icon(Icons.person, color: Color(0xFF0A66C2),)
//                                   : null,
//                               backgroundColor: Color(0xFFD9E1F0),
//                             ),
//                             title: Text(
//                               otherName,
//                               style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text(
//                               lastMessage,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(color: Color(0xFF5C74B1)),
//                             ),
//                             trailing: unreadCount > 0
//                                 ? CircleAvatar(
//                                     radius: 12,
//                                     backgroundColor: Colors.red,
//                                     child: Text(
//                                       '$unreadCount',
//                                       style: TextStyle(color: Colors.white, fontSize: 12),
//                                     ),
//                                   )
//                                 : null,
//                             onTap: () {
//                               final otherUserId = conv['other_user_id'] ?? conv['provider_id'] ?? -1;
//                               if (otherUserId == -1) return;

//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => ChatPage(
//                                     conversationId: convoId,
//                                     currentUserId: widget.currentUserId,
//                                     otherUserId: otherUserId,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





///////////////////////
///
///


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../widgets/status_widget.dart';

import 'MyProfileScreen.dart';
import 'services.dart';
import 'notifications_page.dart';
import 'chat_page.dart';
import 'my_tasks_screen.dart';
import '../helpers/backend.dart';

import 'package:image_picker/image_picker.dart';
class HomeScreen extends StatefulWidget {
  final String role;
  final Map<String, dynamic> userData;

  HomeScreen({required this.role, required this.userData});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ServicesScreenState> _servicesKey = GlobalKey<ServicesScreenState>();

  List<dynamic> conversations = [];
  bool isLoadingConversations = true;
  int unreadMessagesCount = 0;
  int unseenNotificationsCount = 0;

  late IO.Socket socket;
late StatusController statusController;
  @override
  void initState() {
    super.initState();
    fetchConversations();
    fetchUnseenNotifications();
    initSocket();
   final int currentUserId = widget.userData['id'] ?? -1;
statusController = StatusController(currentUserId: currentUserId);
statusController.fetchStatuses(); // fetch initial statuses


  }

  void initSocket() {
    socket = IO.io(
      Backend.baseUrl,
      <String, dynamic>{'transports': ['websocket'], 'autoConnect': true},
    );

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
          unreadMessagesCount = conversations.fold<int>(
            0,
            (sum, c) {
              final count = c['unread_count'];
              if (count is int) return sum + count;
              if (count is double) return sum + count.toInt();
              return sum;
            },
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load conversations')),
        );
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
      ),
      NotificationsPage(
        userId: widget.userData["id"] ?? -1,
        role: widget.role,
      ),
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
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor:Color(0xFF0A66C2),
          unselectedItemColor: Color(0xFF5C74B1),
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 2) resetUnreadMessages();
            if (index == 3) resetUnseenNotifications();
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Services',
            ),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),

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

  MessagesTab({
    Key? key,
    required this.conversations,
    required this.currentUserId,
    required this.onRefresh,
    required this.socket,
    required this.role,
  }) : super(key: key);

  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  List<dynamic> filteredConversations = [];
  final TextEditingController _searchController = TextEditingController();
  late StatusController statusController;

  @override
  void initState() {
    super.initState();
    filteredConversations = widget.conversations;
    _searchController.addListener(_filterChats);

    // Initialize StatusController
   final int currentUserId = int.tryParse(widget.currentUserId.toString()) ?? -1;
statusController = StatusController(currentUserId: currentUserId);

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: widget.role == "provider"
    ? FloatingActionButton(
        child: Icon(Icons.add_a_photo),
        onPressed: () async {
          final filePath = await pickFile();
          if (filePath != null) {
            await statusController.uploadStatus(filePath, 'image');
            await statusController.fetchStatuses(); // refresh immediately
          }
        },
      )
    : null,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF0A66C2),
          elevation: 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          titleSpacing: 16,
          title: const Text(
            "My Chats",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
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
                    color: Color(0xFF0A66C2),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Status Circles
         Container(
  height: 80,
  child: AnimatedBuilder(
    animation: statusController,
    builder: (context, _) {
      if (statusController.statuses.isEmpty) {
        return Center(child: Text('No statuses yet'));
      }
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statusController.statuses.length,
        itemBuilder: (context, index) {
          final status = statusController.statuses[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: StatusCircle(
              status: status,
              onTap: () => showStatusViewer(context, status),
            ),
          );
        },
      );
    },
  ),
),


          // Chat List
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              color: Color(0xFF0A66C2),
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
                  : ListView.builder(
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conv = filteredConversations[index];
                        final convoId = conv['conversation_id'];
                        if (convoId == null) return SizedBox();

                        final otherName = conv['other_user_name'] ?? 'Unknown';
                        final otherAvatar = conv['other_user_avatar'];
                        final lastMessage = conv['last_message'] ?? '';
                        final unreadCount = conv['unread_count'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (otherAvatar != null && otherAvatar.toString().isNotEmpty)
                                  ? NetworkImage("${Backend.baseUrl}/$otherAvatar")
                                  : null,
                              child: (otherAvatar == null || otherAvatar.toString().isEmpty)
                                  ? Icon(Icons.person, color: Color(0xFF0A66C2))
                                  : null,
                              backgroundColor: Color(0xFFD9E1F0),
                            ),
                            title: Text(
                              otherName,
                              style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(0xFF5C74B1)),
                            ),
                            trailing: unreadCount > 0
                                ? CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Text(
                                      '$unreadCount',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              final otherUserId = conv['other_user_id'] ?? conv['provider_id'] ?? -1;
                              if (otherUserId == -1) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    conversationId: convoId,
                                    currentUserId: widget.currentUserId,
                                    otherUserId: otherUserId,
                                  ),
                                ),
                              ).then((_) {
                                setState(() {
                                  conv['unread_count'] = 0;
                                });

                                try {
                                  widget.socket.emit('mark_messages_seen', {
                                    'conversationId': convoId,
                                    'userId': widget.currentUserId,
                                  });
                                } catch (e) {
                                  debugPrint("Socket error: $e");
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      
    );
    
  }
}

// ---------------- PICK FILE ----------------
Future<String?> pickFile() async {
  try {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) return pickedFile.path;
  } catch (e) {
    print("Error picking file: $e");
  }
  return null;
}
