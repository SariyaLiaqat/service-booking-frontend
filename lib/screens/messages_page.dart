// ////////////////////

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../helpers/backend.dart';
// import 'chat_page.dart';

// class MessagesPage extends StatefulWidget {
//   final int currentUserId;

//   const MessagesPage({Key? key, required this.currentUserId}) : super(key: key);

//   @override
//   _MessagesPageState createState() => _MessagesPageState();
// }

// class _MessagesPageState extends State<MessagesPage> {
//   bool isLoading = true;
//   List<dynamic> conversations = [];
//   List<dynamic> filteredConversations = [];
//   late IO.Socket socket;
//   TextEditingController _searchController = TextEditingController();

//   // Track currently open chat
//   int? _currentOpenConversationId;

//   @override
//   void initState() {
//     super.initState();
//     filteredConversations = conversations;
//     _searchController.addListener(_filterChats);

//     initSocket();
//     fetchConversations();
//   }

//   @override
//   void dispose() {
//     socket.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ------------------- SOCKET.IO -------------------
//   void initSocket() {
//     socket = IO.io(
//       Backend.baseUrl,
//       <String, dynamic>{'transports': ['websocket'], 'autoConnect': true},
//     );
// socket.on('update_conversation_list', (data) {
//   final convoId = data['conversation_id'];
//   final index = conversations.indexWhere((c) => c['conversation_id'] == convoId);
//   if (index != -1) {
//     setState(() {
//       conversations[index]['last_message'] = data['last_message'] ?? conversations[index]['last_message'];
//       conversations[index]['last_message_time'] = data['last_message_time'] ?? conversations[index]['last_message_time'];
//       conversations[index]['unread_count'] = data['unread_count'] ?? conversations[index]['unread_count'];
//     });
//     _filterChats(); // important for filteredConversations
//   }
// });

//     socket.connect();

//     socket.onConnect((_) {
//       socket.emit('user_online', widget.currentUserId);
//     });

//     // ------------------- NEW MESSAGE -------------------
//     socket.on('new_message_notification', (data) {
//       final convoId = data['conversationId'];
//       final msg = data['message'];

//       setState(() {
//         final index = conversations.indexWhere((c) => c['conversation_id'] == convoId);
//         if (index != -1) {
//           conversations[index]['last_message'] = msg;
//           conversations[index]['last_message_time'] = DateTime.now().toIso8601String();

//           // Increment only if this chat is NOT currently open
//           if (_currentOpenConversationId != convoId) {
//             final currentUnread = conversations[index]['unread_count'] ?? 0;
//             conversations[index]['unread_count'] = currentUnread + 1;
//           }
//         } else {
//           fetchConversations();
//         }
//       });
//       _filterChats();
//     });

//     // ------------------- NEW CONVERSATION -------------------
//     socket.on('new_conversation', (data) {
//       setState(() {
//         conversations.insert(0, data);
//       });
//       _filterChats();
//     });

//     // ------------------- RESET UNREAD COUNT -------------------
//     socket.on('unread_count_reset', (data) {
//       final convoId = data['conversationId'];
//       setState(() {
//         final index = conversations.indexWhere((c) => c['conversation_id'] == convoId);
//         if (index != -1) conversations[index]['unread_count'] = 0;
//       });
//       _filterChats();
//     });
//   }

//   // ------------------- FETCH CONVERSATIONS -------------------
//   Future<void> fetchConversations() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations?user_id=${widget.currentUserId}");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           conversations = (data['conversations'] as List<dynamic>? ?? [])
//               .where((c) => c != null)
//               .map((c) {
//                 c['unread_count'] = c['unread_count'] ?? 0;
//                 return c;
//               })
//               .toList();
//         });
//         _filterChats();
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Failed to load conversations')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // ------------------- DELETE CONVERSATION -------------------
//   Future<void> deleteConversation(int convoId) async {
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations/$convoId");
//       final response = await http.delete(url);

//       if (response.statusCode == 200) {
//         setState(() {
//           conversations.removeWhere((c) => c['conversation_id'] == convoId);
//         });
//         _filterChats();
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Failed to delete chat')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   // ------------------- SEARCH FILTER -------------------
//   void _filterChats() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       if (query.isEmpty) {
//         filteredConversations = List.from(conversations);
//       } else {
//         filteredConversations = conversations
//             .where((c) => (c['other_user_name'] ?? '').toLowerCase().contains(query))
//             .toList();
//       }
//     });
//   }

//   // ------------------- BUILD CONVERSATION CARD -------------------
//   Widget buildConversationCard(dynamic convo) {
//     final convoId = convo['conversation_id'] ?? -1;
//     final otherUserId = convo['other_user_id'] ?? -1;
//     final otherName = convo['other_user_name'] ?? 'Unknown';
//     final avatarUrl = (convo['other_user_avatar'] != null && convo['other_user_avatar'].toString().isNotEmpty)
//         ? "${Backend.baseUrl}/uploads/${convo['other_user_avatar']}"
//         : null;
//     final isOnline = convo['is_online'] as bool? ?? false;
//     final lastSeen = convo['last_seen'] != null
//         ? DateTime.tryParse(convo['last_seen'])?.toLocal()
//         : null;
//     final lastMessage = convo['last_message'] ?? '';
//     final createdAt = convo['last_message_time'] != null
//         ? DateTime.tryParse(convo['last_message_time'])?.toLocal()
//         : null;
//     final unreadCount = convo['unread_count'] ?? 0;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         leading: Stack(
//           children: [
//             CircleAvatar(
//               radius: 25,
//               backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
//               child: avatarUrl == null ? Icon(Icons.person, size: 30) : null,
//             ),
//             if (isOnline)
//               Positioned(
//                 bottom: 0,
//                 right: 0,
//                 child: Container(
//                   width: 12,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         title: Text(otherName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (!isOnline && lastSeen != null)
//               Text(
//                 'Last seen: ${lastSeen.hour.toString().padLeft(2,'0')}:${lastSeen.minute.toString().padLeft(2,'0')}',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             Text(
//               lastMessage,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (unreadCount > 0)
//               Container(
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Text(
//                   '$unreadCount',
//                   style: TextStyle(color: Colors.white, fontSize: 12),
//                 ),
//               ),
//             if (createdAt != null) SizedBox(height: 4),
//             if (createdAt != null)
//               Text(
//                 "${createdAt.hour.toString().padLeft(2,'0')}:${createdAt.minute.toString().padLeft(2,'0')}",
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//           ],
//         ),
//         onTap: () {
//           if (convoId == -1 || otherUserId == -1) return;

//           // Set currently open chat
//           _currentOpenConversationId = convoId;

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ChatPage(
//                 conversationId: convoId,
//                 currentUserId: widget.currentUserId,
//                 otherUserId: otherUserId,
//               ),
//             ),
//           ).then((_) {
//             // Clear current open chat
//             _currentOpenConversationId = null;

//             // Join conversation
//             socket.emit('join_conversation', [convoId, widget.currentUserId]);

//             // Mark as read
//            // Mark messages as seen (correct backend event)
// socket.emit('mark_messages_seen', {'conversationId': convoId, 'userId': widget.currentUserId});

//             // Locally reset unread count
//             final index = conversations.indexWhere((c) => c['conversation_id'] == convoId);
//             if (index != -1) {
//               setState(() {
//                 conversations[index]['unread_count'] = 0;
//               });
//               _filterChats();
//             }
//           });
//         },
//         onLongPress: () {
//           showModalBottomSheet(
//             context: context,
//             builder: (_) => Wrap(
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.delete),
//                   title: Text('Delete Chat'),
//                   onTap: () {
//                     deleteConversation(convoId);
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.copy),
//                   title: Text('Copy Last Message'),
//                   onTap: () {
//                     Clipboard.setData(ClipboardData(text: lastMessage));
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Message copied')),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ------------------- BUILD -------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: Icon(Icons.menu, color: Colors.black),
//           onPressed: () {},
//         ),
//         title: Text(
//           'Chat_List',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.message, color: Colors.teal),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: Icon(Icons.notifications, color: Colors.teal),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 // ------------------- SEARCH BAR -------------------
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                   child: SizedBox(
//                     height: 50,
//                     child: TextField(
//                       controller: _searchController,
//                       decoration: InputDecoration(
//                         hintText: 'Search chats...',
//                         prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // ------------------- CHAT LIST -------------------
//                 Expanded(
//                   child: filteredConversations.isEmpty
//                       ? Center(
//                           child: Text(
//                             _searchController.text.isEmpty
//                                 ? 'No conversations yet'
//                                 : 'No conversations found',
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.w500),
//                           ),
//                         )
//                       : RefreshIndicator(
//                           onRefresh: fetchConversations,
//                           child: ListView.builder(
//                             itemCount: filteredConversations.length,
//                             itemBuilder: (context, index) =>
//                                 buildConversationCard(filteredConversations[index]),
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

////////////////////

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../helpers/backend.dart';
import 'chat_page.dart';

class MessagesPage extends StatefulWidget {
  final int currentUserId;

  const MessagesPage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool isLoading = true;
  List<dynamic> conversations = [];
  List<dynamic> filteredConversations = [];
  late IO.Socket socket;
  TextEditingController _searchController = TextEditingController();

  // Track currently open chat
  int? _currentOpenConversationId;

  @override
  void initState() {
    super.initState();
    filteredConversations = conversations;
    _searchController.addListener(_filterChats);

    initSocket();
    fetchConversations();
  }

  @override
  void dispose() {
    socket.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ------------------- SOCKET.IO -------------------
  void initSocket() {
    socket = IO.io(Backend.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.on('update_conversation_list', (data) {
      final convoId = data['conversation_id'];
      final index = conversations.indexWhere(
        (c) => c['conversation_id'] == convoId,
      );
      if (index != -1) {
        setState(() {
          conversations[index]['last_message'] =
              data['last_message'] ?? conversations[index]['last_message'];
          conversations[index]['last_message_time'] =
              data['last_message_time'] ??
              conversations[index]['last_message_time'];
          conversations[index]['unread_count'] =
              data['unread_count'] ?? conversations[index]['unread_count'];
        });
        _filterChats(); // important for filteredConversations
      }
    });

    socket.connect();

    socket.onConnect((_) {
      socket.emit('user_online', widget.currentUserId);
    });

    // ------------------- NEW MESSAGE -------------------
    socket.on('new_message_notification', (data) {
      final convoId = data['conversationId'];
      final msg = data['message'];

      setState(() {
        final index = conversations.indexWhere(
          (c) => c['conversation_id'] == convoId,
        );
        if (index != -1) {
          conversations[index]['last_message'] = msg;
          conversations[index]['last_message_time'] = DateTime.now()
              .toIso8601String();

          // Increment only if this chat is NOT currently open
          if (_currentOpenConversationId != convoId) {
            final currentUnread = conversations[index]['unread_count'] ?? 0;
            conversations[index]['unread_count'] = currentUnread + 1;
          }
        } else {
          fetchConversations();
        }
      });
      _filterChats();
    });

    // ------------------- NEW CONVERSATION -------------------
    socket.on('new_conversation', (data) {
      setState(() {
        conversations.insert(0, data);
      });
      _filterChats();
    });

    // ------------------- RESET UNREAD COUNT -------------------
    socket.on('unread_count_reset', (data) {
      final convoId = data['conversationId'];
      setState(() {
        final index = conversations.indexWhere(
          (c) => c['conversation_id'] == convoId,
        );
        if (index != -1) conversations[index]['unread_count'] = 0;
      });
      _filterChats();
    });
  }

  // ------------------- FETCH CONVERSATIONS -------------------
  Future<void> fetchConversations() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
        "${Backend.baseUrl}/conversations?user_id=${widget.currentUserId}&reset_seen=true",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          conversations = (data['conversations'] as List<dynamic>? ?? [])
              .where((c) => c != null)
              .map((c) {
                c['unread_count'] = (c['unread_count'] ?? 0);
                return c;
              })
              .toList();
        });
        _filterChats();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load conversations')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ------------------- DELETE CONVERSATION -------------------
  Future<void> deleteConversation(int convoId) async {
    try {
      final url = Uri.parse("${Backend.baseUrl}/conversations/$convoId");
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          conversations.removeWhere((c) => c['conversation_id'] == convoId);
        });
        _filterChats();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete chat')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ------------------- SEARCH FILTER -------------------
  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredConversations = List.from(conversations);
      } else {
        filteredConversations = conversations
            .where(
              (c) => (c['other_user_name'] ?? '').toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  // ------------------- BUILD CONVERSATION CARD -------------------
  Widget buildConversationCard(dynamic convo) {
    final convoId = convo['conversation_id'] ?? -1;
    final otherUserId = convo['other_user_id'] ?? -1;
    final otherName = convo['other_user_name'] ?? 'Unknown';
    final avatarUrl =
        (convo['other_user_avatar'] != null &&
            convo['other_user_avatar'].toString().isNotEmpty)
        ? "${Backend.baseUrl}/uploads/${convo['other_user_avatar']}"
        : null;
    final isOnline = convo['is_online'] as bool? ?? false;
    final lastSeen = convo['last_seen'] != null
        ? DateTime.tryParse(convo['last_seen'])?.toLocal()
        : null;
    final lastMessage = convo['last_message'] ?? '';
    final createdAt = convo['last_message_time'] != null
        ? DateTime.tryParse(convo['last_message_time'])?.toLocal()
        : null;
    final unreadCount = convo['unread_count'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null ? Icon(Icons.person, size: 30) : null,
            ),
            if (isOnline)
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
        title: Text(
          otherName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOnline && lastSeen != null)
              Text(
                'Last seen: ${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unreadCount > 0)
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
            if (createdAt != null) SizedBox(height: 4),
            if (createdAt != null)
              Text(
                "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        onTap: () {
          if (convoId == -1 || otherUserId == -1) return;

          // Set currently open chat
          _currentOpenConversationId = convoId;

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
            // Clear current open chat
            _currentOpenConversationId = null;

            // Join conversation
            socket.emit('join_conversation', [convoId, widget.currentUserId]);

            // Mark as read
            // Mark messages as seen (correct backend event)
            socket.emit('mark_messages_seen', {
              'conversationId': convoId,
              'userId': widget.currentUserId,
            });

            // Locally reset unread count
            final index = conversations.indexWhere(
              (c) => c['conversation_id'] == convoId,
            );
            if (index != -1) {
              setState(() {
                conversations[index]['unread_count'] = 0;
              });
              _filterChats();
            }
          });
        },
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete Chat'),
                  onTap: () {
                    deleteConversation(convoId);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy Last Message'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: lastMessage));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Message copied')));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------- BUILD -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          'Chat_List',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.message, color: Colors.teal),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.teal),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ------------------- SEARCH BAR -------------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search chats...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                // ------------------- CHAT LIST -------------------
                Expanded(
                  child: filteredConversations.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'No conversations yet'
                                : 'No conversations found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchConversations,
                          child: ListView.builder(
                            itemCount: filteredConversations.length,
                            itemBuilder: (context, index) =>
                                buildConversationCard(
                                  filteredConversations[index],
                                ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
