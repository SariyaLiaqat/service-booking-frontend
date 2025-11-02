


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'MyProfileScreen.dart';
// import 'services.dart';
// import 'messages_page.dart';
// import 'my_tasks_screen.dart';
// import '../helpers/backend.dart';
// import 'status_screen.dart';
// import '../helpers/my_colors.dart';
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
//       MessagesTab(
//         //   key: ValueKey(unseenNotificationsCount), // 🔹 add this
//         conversations: conversations,
//         currentUserId: widget.userData['id'] ?? -1,
//         onRefresh: fetchConversations,
//         socket: socket,
//         role: widget.role,
//         unseenNotificationsCount: unseenNotificationsCount,
//         onConversationSeen: (conversationId) {
//           // 🔹 Add this
//           setState(() {
//             for (var c in conversations) {
//               if (c['conversation_id'] == conversationId) {
//                 c['unread_count'] = 0;
//                 break;
//               }
//             }
//             // Update total unreadMessagesCount
//             unreadMessagesCount = conversations.fold<int>(0, (sum, c) {
//               final dynamic count = c['unread_count'];
//               final num safeCount;

//               if (count == null) {
//                 safeCount = 0;
//               } else if (count is int || count is double) {
//                 safeCount = count;
//               } else if (count is String) {
//                 safeCount = int.tryParse(count) ?? 0;
//               } else {
//                 safeCount = 0;
//               }

//               return sum + safeCount.toInt();
//             });
//           });
//         },
//       ),

//       StatusPage(
//         currentUserId: widget.userData["id"] ?? -1,
//         isProvider: widget.role == 'provider', // ya jo role decide kar rahi ho
//       ),

//       MyProfileScreen(
//         userData: widget.userData,
//         currentUserId: widget.userData['id'],
//         //   onProfileUpdated: () => _servicesKey.currentState?.fetchProviders(),
//       ),
//     ];

//     return Scaffold(
//       backgroundColor: MyColors.background,
//       body: IndexedStack(index: _currentIndex, children: pages),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         child: Container(
//           decoration: BoxDecoration(
//             color: MyColors.surface,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.25),
//                 blurRadius: 15,
//                 offset: Offset(0, 5),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(30),
//             child: BottomNavigationBar(
//               currentIndex: _currentIndex,
//               type: BottomNavigationBarType.fixed,
//               backgroundColor: MyColors.surface,
//               selectedItemColor: MyColors.primary,
//               unselectedItemColor: MyColors.textSecondary,
//               showSelectedLabels: true,
//               showUnselectedLabels: true,
//               onTap: (index) {
//                 setState(() => _currentIndex = index);
//                 if (index == 2) resetUnreadMessages();
//                 if (index == 3) resetUnseenNotifications();
//               },
//               items: [
//                 BottomNavigationBarItem(
//                   icon: AnimatedContainer(
//                     duration: Duration(milliseconds: 250),
//                     padding: _currentIndex == 0
//                         ? EdgeInsets.all(6)
//                         : EdgeInsets.all(0),
//                     decoration: _currentIndex == 0
//                         ? BoxDecoration(
//                             color: MyColors.primary.withOpacity(0.15),
//                             shape: BoxShape.circle,
//                           )
//                         : null,
//                     child: Icon(Icons.home),
//                   ),
//                   label: 'Services',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: AnimatedContainer(
//                     duration: Duration(milliseconds: 250),
//                     padding: _currentIndex == 1
//                         ? EdgeInsets.all(6)
//                         : EdgeInsets.all(0),
//                     decoration: _currentIndex == 1
//                         ? BoxDecoration(
//                             color: MyColors.primary.withOpacity(0.15),
//                             shape: BoxShape.circle,
//                           )
//                         : null,
//                     child: Icon(Icons.check_circle_outline),
//                   ),
//                   label: 'Tasks',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Stack(
//                     children: [
//                       AnimatedContainer(
//                         duration: Duration(milliseconds: 250),
//                         padding: _currentIndex == 2
//                             ? EdgeInsets.all(6)
//                             : EdgeInsets.all(0),
//                         decoration: _currentIndex == 2
//                             ? BoxDecoration(
//                                 color: MyColors.primary.withOpacity(0.15),
//                                 shape: BoxShape.circle,
//                               )
//                             : null,
//                         child: Icon(Icons.message),
//                       ),
//                       if (unreadMessagesCount > 0)
//                         Positioned(
//                           right: 0,
//                           top: 0,
//                           child: Container(
//                             padding: EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: MyColors.error,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Text(
//                               '$unreadMessagesCount',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   label: 'Messages',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: AnimatedContainer(
//                     duration: Duration(milliseconds: 250),
//                     padding: _currentIndex == 3
//                         ? EdgeInsets.all(6)
//                         : EdgeInsets.all(0),
//                     decoration: _currentIndex == 3
//                         ? BoxDecoration(
//                             color: MyColors.primary.withOpacity(0.15),
//                             shape: BoxShape.circle,
//                           )
//                         : null,
//                     child: Icon(Icons.star),
//                   ),
//                   label: 'Status',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: AnimatedContainer(
//                     duration: Duration(milliseconds: 250),
//                     padding: _currentIndex == 4
//                         ? EdgeInsets.all(6)
//                         : EdgeInsets.all(0),
//                     decoration: _currentIndex == 4
//                         ? BoxDecoration(
//                             color: MyColors.primary.withOpacity(0.15),
//                             shape: BoxShape.circle,
//                           )
//                         : null,
//                     child: Icon(Icons.person),
//                   ),
//                   label: 'Profile',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
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
import 'messages_page.dart';
import 'my_tasks_screen.dart';
import '../helpers/backend.dart';
import 'status_screen.dart';
import '../helpers/coolors.dart';
import '../widgets/status_widget.dart';
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
  int unseenStatusCount = 0;


  late IO.Socket socket;
  late StatusController statusController;
  @override
  void initState() {
    super.initState();
    statusController = StatusController(currentUserId: widget.userData['id']);
    fetchConversations();
    fetchUnseenNotifications();
    fetchUnseenCount();
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
//////---------------new
socket.on('new_status', (data) {
  final newStatus = Status.fromJson(data);

  if (newStatus.uploaderUserId != widget.userData['id']) {
    final existingIndex =
        statusController.publicStatuses.indexWhere((s) => s.id == newStatus.id);

    if (existingIndex != -1) {
      newStatus.isViewed = statusController.publicStatuses[existingIndex].isViewed;
      statusController.publicStatuses[existingIndex] = newStatus;
    } else {
      statusController.publicStatuses.insert(0, newStatus);
    }

    setState(() {
      unseenStatusCount = statusController.unviewedPublicCount;
    });
  }
});







//-------------------------
    socket.on('update_conversation_list', (data) {
      fetchConversations();
    });

    socket.on('notification_received', (data) {
      if (data['userId'] == widget.userData['id']) {
        setState(() => unseenNotificationsCount += 1);
      }
    });
  }
//-------------
void resetUnseenStatus() {
  setState(() => unseenStatusCount = 0);
}
// On app start / refresh, fetch unseen count
void fetchUnseenCount() async {
  try {
    final response = await http.get(Uri.parse(
        '${Backend.baseUrl}/statuses/fetch-public?user_id=${widget.userData['id']}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> statusesJson = data['statuses'] ?? [];

      // Convert JSON to Status objects
      statusController.publicStatuses = statusesJson
          .map((s) => Status.fromJson(s))
          .toList();

      setState(() {
        // Use getter from StatusController
        unseenStatusCount = statusController.unviewedPublicCount;
      });
    }
  } catch (e) {
    print("Error fetching unseen statuses: $e");
  }
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
        //   key: ValueKey(unseenNotificationsCount), // 🔹 add this
         conversations: conversations,
  currentUserId: widget.userData['id'] ?? -1,
  onRefresh: fetchConversations,
  role: widget.role,
  unseenNotificationsCount: unseenNotificationsCount,
        onConversationSeen: (conversationId) {
          // 🔹 Add this
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

      StatusPage(
        currentUserId: widget.userData["id"] ?? -1,
        isProvider: widget.role == 'provider', // ya jo role decide kar rahi ho
        onViewed: resetUnseenStatus,
      ),

      MyProfileScreen(
        userData: widget.userData,
        currentUserId: widget.userData['id'],
        //   onProfileUpdated: () => _servicesKey.currentState?.fetchProviders(),
      ),
    ];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: kCardColor,
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: kTextSecondary,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              onTap: (index) {
                setState(() => _currentIndex = index);
                if (index == 2) resetUnreadMessages();
                if (index == 3) resetUnseenNotifications();
               if (index == 3) resetUnseenStatus(); 
              },
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    padding: _currentIndex == 0
                        ? EdgeInsets.all(6)
                        : EdgeInsets.all(0),
                    decoration: _currentIndex == 0
                        ? BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Icon(Icons.home),
                  ),
                  label: 'Services',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    padding: _currentIndex == 1
                        ? EdgeInsets.all(6)
                        : EdgeInsets.all(0),
                    decoration: _currentIndex == 1
                        ? BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Icon(Icons.check_circle_outline),
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        padding: _currentIndex == 2
                            ? EdgeInsets.all(6)
                            : EdgeInsets.all(0),
                        decoration: _currentIndex == 2
                            ? BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              )
                            : null,
                        child: Icon(Icons.message),
                      ),
                      if (unreadMessagesCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadMessagesCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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
      AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: _currentIndex == 3 ? EdgeInsets.all(6) : EdgeInsets.all(0),
        decoration: _currentIndex == 3
            ? BoxDecoration(
                color: kPrimaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(Icons.star),
      ),
      if (unseenStatusCount > 0)
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:  redAccent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$unseenStatusCount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ],
  ),
  label: 'Status',
),

                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    padding: _currentIndex == 4
                        ? EdgeInsets.all(6)
                        : EdgeInsets.all(0),
                    decoration: _currentIndex == 4
                        ? BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Icon(Icons.person),
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
