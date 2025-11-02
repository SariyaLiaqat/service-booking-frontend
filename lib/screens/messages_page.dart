// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../helpers/my_colors.dart';
// import 'notifications_page.dart';
// import 'chat_page.dart';
// import '../helpers/backend.dart';
// import 'status_screen.dart';
// //import '../helpers/colors.dart';
// import '../helpers/socket_manager.dart'; // ✅ SocketManager import

// class MessagesTab extends StatefulWidget {
//   final List<dynamic> conversations;
//   final int currentUserId;
//   final Future<void> Function() onRefresh;
//   final String role;
//   final int unseenNotificationsCount;
//   final void Function(int conversationId)? onConversationSeen;

//   MessagesTab({
//     Key? key,
//     required this.conversations,
//     required this.currentUserId,
//     required this.onRefresh,
//     required this.role,
//     this.onConversationSeen,
//     required this.unseenNotificationsCount,
//   }) : super(key: key);

//   @override
//   _MessagesTabState createState() => _MessagesTabState();
// }

// class _MessagesTabState extends State<MessagesTab> {
//   List<dynamic> filteredConversations = [];
//   final TextEditingController _searchController = TextEditingController();
//   bool _isChatsSelected = true;
//   int _localUnseenNotificationsCount = 0;
//   late final socket = SocketManager().socket;
//  // ✅ Use singleton socket
// @override
// void initState() {
//   super.initState();
//   filteredConversations = widget.conversations;
//   _searchController.addListener(_filterChats);
//   _localUnseenNotificationsCount = widget.unseenNotificationsCount;

//   // ✅ Safety check before using socket
//   if (socket != null) {
//     // 🔹 Listen for messages seen
//     socket!.on('messages_seen', (data) {
//       final seenConversationId = data['conversationId'];
//       setState(() {
//         for (var conv in filteredConversations) {
//           if (conv['conversation_id'] == seenConversationId) {
//             conv['has_been_seen'] = true;
//           }
//         }
//       });
//     });

//     // 🔹 Listen for new messages
//     socket!.on('new_message', (data) {
//       final convId = data['conversationId'];
//       final message = data['message'];
//       final createdAt = data['created_at'];
//       final otherUserId = data['other_user_id'];
//       final otherUserName = data['other_user_name'];
//       final otherUserAvatar = data['other_user_avatar'];

//       setState(() {
//         final index = filteredConversations
//             .indexWhere((conv) => conv['conversation_id'] == convId);

//         if (index != -1) {
//           filteredConversations[index]['last_message'] = message;
//           filteredConversations[index]['last_message_time'] = createdAt;
//           filteredConversations[index]['unread_count'] =
//               (filteredConversations[index]['unread_count'] ?? 0) + 1;
//         } else {
//           filteredConversations.insert(0, {
//             'conversation_id': convId,
//             'other_user_id': otherUserId,
//             'other_user_name': otherUserName,
//             'other_user_avatar': otherUserAvatar,
//             'last_message': message,
//             'last_message_time': createdAt,
//             'unread_count': 1,
//             'has_been_seen': false,
//           });
//         }

//         filteredConversations.sort((a, b) {
//           final aTime = a['last_message_time'] != null
//               ? DateTime.parse(a['last_message_time'])
//               : DateTime(2000);
//           final bTime = b['last_message_time'] != null
//               ? DateTime.parse(b['last_message_time'])
//               : DateTime(2000);
//           return bTime.compareTo(aTime);
//         });
//       });
//     });
//   } else {
//     debugPrint("⚠️ Socket is null, skipping listeners for now");
//   }
// }

// @override
// void dispose() {
//   _searchController.dispose();
//   // ✅ Only remove listeners if socket is connected
//   if (socket != null) {
//     socket!.off('messages_seen');
//     socket!.off('new_message');
//   }
//   super.dispose();
// }

//   @override
//   void didUpdateWidget(covariant MessagesTab oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (oldWidget.unseenNotificationsCount !=
//         widget.unseenNotificationsCount) {
//       setState(() {
//         _localUnseenNotificationsCount = widget.unseenNotificationsCount;
//       });
//     }

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
//             .where((c) =>
//                 (c['other_user_name'] ?? '').toLowerCase().contains(query))
//             .toList();
//       }

//       filteredConversations.sort((a, b) {
//         final aTime = a['last_message_time'] != null
//             ? DateTime.parse(a['last_message_time'])
//             : DateTime(2000);
//         final bTime = b['last_message_time'] != null
//             ? DateTime.parse(b['last_message_time'])
//             : DateTime(2000);
//         return bTime.compareTo(aTime);
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.background,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: AppBar(
//           backgroundColor: MyColors.surface,
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
//               Stack(
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.notifications_none,
//                         color: Colors.white, size: 28),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => NotificationsPage(
//                             userId: widget.currentUserId,
//                             role: widget.role,
//                           ),
//                         ),
//                       ).then((_) {
//                         setState(() {
//                           _localUnseenNotificationsCount = 0;
//                         });
//                       });
//                     },
//                   ),
//                   if (_localUnseenNotificationsCount > 0)
//                     Positioned(
//                       right: 6,
//                       top: 6,
//                       child: Container(
//                         width: 14,
//                         height: 14,
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2),
//                         ),
//                         child: Center(
//                           child: Text(
//                             '$_localUnseenNotificationsCount',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: TextField(
//               controller: _searchController,
//               style: const TextStyle(
//                 color: MyColors.textPrimary,
//                 fontWeight: FontWeight.w500,
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Search chats...',
//                 hintStyle: const TextStyle(color: MyColors.textSecondary),
//                 prefixIcon:
//                     const Icon(Icons.search, color: MyColors.textSecondary),
//                 filled: true,
//                 fillColor: MyColors.inputFill,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: const BorderSide(
//                       color: MyColors.inputFocusedBorder, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               transitionBuilder: (child, animation) {
//                 return SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(1, 0),
//                     end: Offset.zero,
//                   ).animate(animation),
//                   child: child,
//                 );
//               },
//               child: _isChatsSelected
//                   ? RefreshIndicator(
//                       key: const ValueKey('chats'),
//                       onRefresh: widget.onRefresh,
//                       color: MyColors.primary,
//                       child: filteredConversations.isEmpty
//                           ? ListView(
//                               children: [
//                                 Center(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(20),
//                                     child: Text(
//                                       widget.conversations.isEmpty
//                                           ? 'No conversations yet'
//                                           : 'No results found',
//                                       style: TextStyle(
//                                           fontSize: 16,
//                                           color: MyColors.textSecondary),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             )
//                           : ListView.builder(
//                               itemCount: filteredConversations.length,
//                               itemBuilder: (context, index) {
//                                 final conv = filteredConversations[index];
//                                 final convoId = conv['conversation_id'];
//                                 if (convoId == null) return SizedBox();
//                                 final otherName =
//                                     conv['other_user_name'] ?? 'Unknown';
//                                 final otherAvatar = conv['other_user_avatar'];
//                                 final lastMessage = conv['last_message'] ?? '';
//                                 final unreadCount = conv['unread_count'] ?? 0;
//                                 final hasBeenSeen =
//                                     conv['has_been_seen'] ?? false;

//                                 Color messageColor;
//                                 if (unreadCount > 0) {
//                                   messageColor = Colors.red;
//                                 } else if (hasBeenSeen) {
//                                   messageColor = Colors.green;
//                                 } else {
//                                   messageColor = MyColors.textSecondary;
//                                 }

//                                 return GestureDetector(
//                                   onTap: () async {
//                                     final otherUserId = conv['other_user_id'] ??
//                                         conv['provider_id'] ??
//                                         -1;
//                                     if (otherUserId == -1) return;

//                                     await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => ChatPage(
//                                           conversationId: convoId,
//                                           currentUserId: widget.currentUserId,
//                                           otherUserId: otherUserId,
//                                         ),
//                                       ),
//                                     );

//                                     setState(() {
//                                       conv['unread_count'] = 0;
//                                     });

//                                     // 🔹 Emit socket event
//                                     try {
//                                       socket?.emit('mark_messages_seen', {
//                                         'conversationId': convoId,
//                                         'userId': widget.currentUserId,
//                                       });
//                                     } catch (e) {
//                                       debugPrint("Socket error: $e");
//                                     }

//                                     // 🔹 Backend call
//                                     try {
//                                       await http.post(
//                                         Uri.parse(
//                                             "${Backend.baseUrl}/conversations/$convoId/seen"),
//                                         body: jsonEncode(
//                                             {'user_id': widget.currentUserId}),
//                                         headers: {
//                                           "Content-Type": "application/json"
//                                         },
//                                       );
//                                     } catch (e) {
//                                       debugPrint(
//                                           "Error marking conversation seen: $e");
//                                     }

//                                     widget.onConversationSeen?.call(convoId);
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 10),
//                                     color: Colors.transparent,
//                                     child: Row(
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.all(2.5),
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             gradient: LinearGradient(
//                                               colors: [
//                                                 Colors.blueAccent
//                                                     .withOpacity(0.9),
//                                                 Colors.purpleAccent
//                                                     .withOpacity(0.9),
//                                               ],
//                                               begin: Alignment.topLeft,
//                                               end: Alignment.bottomRight,
//                                             ),
//                                           ),
//                                           child: ClipOval(
//                                             child: Container(
//                                               color: _getColorFromName(otherName),
//                                               child: (otherAvatar != null &&
//                                                       otherAvatar
//                                                           .toString()
//                                                           .isNotEmpty)
//                                                   ? Image.network(
//                                                       "${Backend.baseUrl}/$otherAvatar",
//                                                       fit: BoxFit.cover,
//                                                       width: 56,
//                                                       height: 56,
//                                                       errorBuilder: (context,
//                                                               error,
//                                                               stackTrace) =>
//                                                           _buildInitialAvatar(
//                                                               otherName),
//                                                     )
//                                                   : _buildInitialAvatar(otherName),
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 otherName,
//                                                 style: TextStyle(
//                                                   color: MyColors.textPrimary,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 16,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 4),
//                                               Text(
//                                                 lastMessage,
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: TextStyle(
//                                                   color: messageColor,
//                                                   fontSize: 14,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text(
//                                           formatChatTime(
//                                               context, conv['last_message_time']),
//                                           style: TextStyle(
//                                             color: MyColors.textSecondary,
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                         if (unreadCount > 0) ...[
//                                           SizedBox(width: 8),
//                                           Container(
//                                             padding: EdgeInsets.all(6),
//                                             decoration: BoxDecoration(
//                                               color: MyColors.error,
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: Text(
//                                               '$unreadCount',
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 12),
//                                             ),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     )
//                   : StatusPage(
//                       key: const ValueKey('status'),
//                       currentUserId: widget.currentUserId,
//                       isProvider: widget.role == "provider",
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getColorFromName(String name) {
//     final colors = [
//       Colors.deepPurple,
//       Colors.teal,
//       Colors.indigo,
//       Colors.orange,
//       Colors.pinkAccent,
//       Colors.cyan,
//       Colors.blueGrey,
//       Colors.deepOrangeAccent,
//       Colors.green,
//       Colors.redAccent,
//     ];
//     if (name.isEmpty) return Colors.grey;
//     int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
//     return colors[hash % colors.length];
//   }

//   Widget _buildInitialAvatar(String name) {
//     final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
//     final letterColor = _getColorFromName(name);
//     return Container(
//       width: 56,
//       height: 56,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: MyColors.surface,
//         shape: BoxShape.circle,
//       ),
//       child: Text(
//         initial,
//         style: TextStyle(
//           color: letterColor,
//           fontWeight: FontWeight.bold,
//           fontSize: 22,
//         ),
//       ),
//     );
//   }
// }

// // ✅ formatChatTime function stays the same
// String formatChatTime(BuildContext context, String? dateTimeStr) {
//   if (dateTimeStr == null) return '';
//   final dateTime = DateTime.parse(dateTimeStr).toLocal();
//   final now = DateTime.now();
//   final today = DateTime(now.year, now.month, now.day);
//   final yesterday = today.subtract(Duration(days: 1));
//   final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
//   if (msgDate == today) return TimeOfDay.fromDateTime(dateTime).format(context);
//   if (msgDate == yesterday) return 'Yesterday';
//   return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
// }
///////////////////////////////////
///
///
///
//////////////////////////////////////////////////////////////////////////
///

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// import 'notifications_page.dart';
// import 'chat_page.dart';
// import '../helpers/backend.dart';
// import 'status_screen.dart';
// import '../helpers/coolors.dart';
// import '../helpers/socket_manager.dart'; // ✅ SocketManager import

// class MessagesTab extends StatefulWidget {
//   final List<dynamic> conversations;
//   final int currentUserId;
//   final Future<void> Function() onRefresh;
//   final String role;
//   final int unseenNotificationsCount;
//   final void Function(int conversationId)? onConversationSeen;

//   MessagesTab({
//     Key? key,
//     required this.conversations,
//     required this.currentUserId,
//     required this.onRefresh,
//     required this.role,
//     this.onConversationSeen,
//     required this.unseenNotificationsCount,
//   }) : super(key: key);

//   @override
//   _MessagesTabState createState() => _MessagesTabState();
// }

// class _MessagesTabState extends State<MessagesTab> {
//   List<dynamic> filteredConversations = [];
//   final TextEditingController _searchController = TextEditingController();
//   bool _isChatsSelected = true;
//   int _localUnseenNotificationsCount = 0;
//   late final socket = SocketManager().socket;
//   int _selectedTabIndex = 0; // 0 = All, 1 = Favourites
//   bool _isLoading = false;

//   // ✅ Use singleton socket
//   @override
//   void initState() {
//     super.initState();
//     filteredConversations = widget.conversations;
//     _searchController.addListener(_filterChats);
//     _localUnseenNotificationsCount = widget.unseenNotificationsCount;

//     // ✅ Safety check before using socket
//     if (socket != null) {
//       // 🔹 Listen for messages seen
//       socket!.on('messages_seen', (data) {
//         final seenConversationId = data['conversationId'];
//         setState(() {
//           for (var conv in filteredConversations) {
//             if (conv['conversation_id'] == seenConversationId) {
//               conv['has_been_seen'] = true;
//             }
//           }
//         });
//       });

//       // 🔹 Listen for new messages
//       socket!.on('new_message', (data) {
//         final convId = data['conversationId'];
//         final message = data['message'];
//         final createdAt = data['created_at'];
//         final otherUserId = data['other_user_id'];
//         final otherUserName = data['other_user_name'];
//         final otherUserAvatar = data['other_user_avatar'];

//         setState(() {
//           final index = filteredConversations.indexWhere(
//             (conv) => conv['conversation_id'] == convId,
//           );

//           if (index != -1) {
//             filteredConversations[index]['last_message'] = message;
//             filteredConversations[index]['last_message_time'] = createdAt;
//             filteredConversations[index]['unread_count'] =
//                 (filteredConversations[index]['unread_count'] ?? 0) + 1;
//           } else {
//             filteredConversations.insert(0, {
//               'conversation_id': convId,
//               'other_user_id': otherUserId,
//               'other_user_name': otherUserName,
//               'other_user_avatar': otherUserAvatar,
//               'last_message': message,
//               'last_message_time': createdAt,
//               'unread_count': 1,
//               'has_been_seen': false,
//             });
//           }

//           filteredConversations.sort((a, b) {
//             final aTime = a['last_message_time'] != null
//                 ? DateTime.parse(a['last_message_time'])
//                 : DateTime(2000);
//             final bTime = b['last_message_time'] != null
//                 ? DateTime.parse(b['last_message_time'])
//                 : DateTime(2000);
//             return bTime.compareTo(aTime);
//           });
//         });
//       });
//     } else {
//       debugPrint("⚠️ Socket is null, skipping listeners for now");
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     // ✅ Only remove listeners if socket is connected
//     if (socket != null) {
//       socket!.off('messages_seen');
//       socket!.off('new_message');
//     }
//     super.dispose();
//   }

//   @override
//   void didUpdateWidget(covariant MessagesTab oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (oldWidget.unseenNotificationsCount != widget.unseenNotificationsCount) {
//       setState(() {
//         _localUnseenNotificationsCount = widget.unseenNotificationsCount;
//       });
//     }

//     setState(() {
//       filteredConversations = List.from(widget.conversations);
//       _filterChats();
//     });
//   }

//   Future<void> _refreshChats() async {
//     await widget.onRefresh(); // fetch from backend
//     setState(() {
//       filteredConversations = List.from(widget.conversations);
//       _filterChats();
//     });
//   }

//   Future<void> _fetchFavouriteChats() async {
//     setState(() => _isLoading = true);
//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/conversations/favourites?user_id=${widget.currentUserId}',
//       );
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final favourites = data['favourites'] ?? [];
//         setState(() {
//           filteredConversations = List.from(favourites);
//         });
//       } else {
//         debugPrint("❌ Failed to fetch favourites: ${response.body}");
//       }
//     } catch (e) {
//       debugPrint("❌ Error fetching favourites: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
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

//       filteredConversations.sort((a, b) {
//         final aTime = a['last_message_time'] != null
//             ? DateTime.parse(a['last_message_time'])
//             : DateTime(2000);
//         final bTime = b['last_message_time'] != null
//             ? DateTime.parse(b['last_message_time'])
//             : DateTime(2000);
//         return bTime.compareTo(aTime);
//       });
//     });
//   }

//   Widget _buildTabButton(String label, int index) {
//     final isSelected = _selectedTabIndex == index;
//     return GestureDetector(
//       onTap: () {
//         setState(() => _selectedTabIndex = index);
//         if (index == 1) {
//           _fetchFavouriteChats();
//         } else {
//           _refreshChats();
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? kPrimaryColor.withOpacity(0.1)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? kPrimaryColor : kTextSecondary,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: kBackgroundColor, // AppBar ka color
//         elevation: 0, // bilkul flat
//         titleSpacing: 16,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             GestureDetector(
//               onTap: () => setState(() => _isChatsSelected = true),
//               child: Text(
//                 "My Chats",
//                 style: TextStyle(
//                   color: _isChatsSelected ? kPrimaryColor : kPrimaryColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 22,
//                 ),
//               ),
//             ),
//             Row(
//               children: [
//                 Stack(
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         Icons.notifications_none,
//                         color: heaidng,
//                         size: 28,
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => NotificationsPage(
//                               userId: widget.currentUserId,
//                               role: widget.role,
//                             ),
//                           ),
//                         ).then((_) {
//                           setState(() {
//                             _localUnseenNotificationsCount = 0;
//                           });
//                         });
//                       },
//                     ),
//                     if (_localUnseenNotificationsCount > 0)
//                       Positioned(
//                         right: 6,
//                         top: 6,
//                         child: Container(
//                           width: 14,
//                           height: 14,
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: kTextPrimary, width: 2),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '$_localUnseenNotificationsCount',
//                               style: TextStyle(
//                                 color: kTextPrimary,
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.more_vert, color: kTextPrimary, size: 28),
//                   onPressed: () async {
//                     final selected = await showMenu(
//                       context: context,
//                       position: RelativeRect.fromLTRB(
//                         1000,
//                         80,
//                         0,
//                         0,
//                       ), // adjust menu position
//                       items: [
//                         PopupMenuItem<String>(
//                           value: 'delete_all',
//                           child: Text('Delete All'),
//                         ),
//                       ],
//                     );

//                     if (selected == 'delete_all') {
//                       final confirm = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: Text('Confirm Delete'),
//                           content: Text(
//                             'Are you sure you want to delete all chats?',
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, false),
//                               child: Text('Cancel'),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.pop(context, true),
//                               child: Text(
//                                 'Delete',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );

//                       if (confirm == true) {
//                         try {
//                           final response = await http.delete(
//                             Uri.parse('${Backend.baseUrl}/messages/all'),
//                             headers: {'Content-Type': 'application/json'},
//                             body: jsonEncode({'userId': widget.currentUserId}),
//                           );

//                           debugPrint('Response Code: ${response.statusCode}');
//                           debugPrint('Response Body: ${response.body}');

//                           if (response.statusCode == 200) {
//                             setState(() {
//                               filteredConversations.clear();
//                               widget.conversations.clear();
//                             });

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('All chats deleted successfully'),
//                               ),
//                             );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Failed to delete chats')),
//                             );
//                           }
//                         } catch (e) {
//                           debugPrint('❌ Error deleting all chats: $e');
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error deleting chats')),
//                           );
//                         }
//                       }
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),

//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: TextField(
//               controller: _searchController,
//               style: const TextStyle(
//                 color: kTextPrimary,
//                 fontWeight: FontWeight.w500,
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Search chats...',
//                 hintStyle: const TextStyle(color: kTextSecondary),
//                 prefixIcon: const Icon(Icons.search, color: kTextSecondary),
//                 filled: true,
//                 fillColor: const Color.fromARGB(255, 224, 222, 222),
//                 contentPadding: const EdgeInsets.symmetric(
//                   vertical: 0,
//                   horizontal: 16,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: const BorderSide(color: kCardColor, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           // 🔹 WhatsApp-style Tabs
//           Padding(
//             padding: const EdgeInsets.only(left: 12, bottom: 6),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 _buildTabButton('All', 0),
//                 const SizedBox(width: 16), // thoda sa neat gap bas
//                 _buildTabButton('Favourites', 1),
//               ],
//             ),
//           ),

//           Expanded(
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               transitionBuilder: (child, animation) {
//                 return SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(1, 0),
//                     end: Offset.zero,
//                   ).animate(animation),
//                   child: child,
//                 );
//               },
//               child: _isChatsSelected
//                   ? RefreshIndicator(
//                       key: const ValueKey('chats'),
//                       onRefresh: _refreshChats,

//                       color: kPrimaryColor,
//                       child: _isLoading
//                           ? Center(
//                               child: CircularProgressIndicator(
//                                 color: kPrimaryColor,
//                               ),
//                             )
//                           : filteredConversations.isEmpty
//                           ? ListView(
//                               children: [
//                                 Center(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(20),
//                                     child: Text(
//                                       widget.conversations.isEmpty
//                                           ? 'No conversations yet'
//                                           : 'No results found',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: kTextSecondary,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : ListView.builder(
//                               itemCount: filteredConversations.length,
//                               itemBuilder: (context, index) {
//                                 final conv = filteredConversations[index];
//                                 final convoId = conv['conversation_id'];
//                                 if (convoId == null) return SizedBox();
//                                 final otherName =
//                                     conv['other_user_name'] ?? 'Unknown';
//                                 final otherAvatar = conv['other_user_avatar'];
//                                 final lastMessage = conv['last_message'] ?? '';
//                                 final unreadCount = conv['unread_count'] ?? 0;
//                                 final hasBeenSeen =
//                                     conv['has_been_seen'] ?? false;

//                                 Color messageColor;
//                                 if (unreadCount > 0) {
//                                   messageColor = Colors.red;
//                                 } else if (hasBeenSeen) {
//                                   messageColor = Colors.green;
//                                 } else {
//                                   messageColor = kTextSecondary;
//                                 }

//                                 return Dismissible(
//                                   key: ValueKey(
//                                     'conv_${conv['conversation_id']}_${index}',
//                                   ),

//                                   direction: DismissDirection
//                                       .endToStart, // Right to left swipe
//                                   background: Container(
//                                     color: Colors.red,
//                                     alignment: Alignment.centerRight,
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 20,
//                                     ),
//                                     child: Icon(
//                                       Icons.delete,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   confirmDismiss: (direction) async {
//                                     return await showDialog(
//                                       context: context,
//                                       builder: (_) => AlertDialog(
//                                         title: Text('Confirm Delete'),
//                                         content: Text(
//                                           'Delete this conversation?',
//                                         ),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.pop(context, false),
//                                             child: Text('Cancel'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.pop(context, true),
//                                             child: Text(
//                                               'Delete',
//                                               style: TextStyle(
//                                                 color: Colors.red,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                   onDismissed: (direction) async {
//                                     final convoId = conv['conversation_id'];

//                                     // Remove from UI immediately to prevent tree conflict
//                                     setState(() {
//                                       filteredConversations.removeWhere(
//                                         (c) => c['conversation_id'] == convoId,
//                                       );
//                                     });

//                                     try {
//                                       print(
//                                         '🟡 Deleting conversation: $convoId for user: ${widget.currentUserId}',
//                                       );

//                                       final url = Uri.parse(
//                                         '${Backend.baseUrl}/messages/conversation/$convoId?userId=${widget.currentUserId}',
//                                       );
//                                       print('🌐 DELETE URL: $url');

//                                       final response = await http.delete(url);

//                                       print(
//                                         '🔵 Response status: ${response.statusCode}',
//                                       );
//                                       print(
//                                         '🟢 Response body: ${response.body}',
//                                       );

//                                       if (response.statusCode == 200) {
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           SnackBar(
//                                             content: Text(
//                                               'Conversation deleted successfully',
//                                             ),
//                                           ),
//                                         );
//                                       } else {
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           SnackBar(
//                                             content: Text(
//                                               'Failed to delete conversation',
//                                             ),
//                                           ),
//                                         );
//                                       }
//                                     } catch (e, s) {
//                                       print('🔴 Exception: $e');
//                                       print('🔴 StackTrace: $s');
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             'Error deleting conversation',
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                   },

//                                   child: GestureDetector(
//                                     onTap: () async {
//                                       final otherUserId =
//                                           conv['other_user_id'] ??
//                                           conv['provider_id'] ??
//                                           -1;
//                                       if (otherUserId == -1) return;

//                                       await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => ChatPage(
//                                             conversationId: convoId,
//                                             currentUserId: widget.currentUserId,
//                                             otherUserId: otherUserId,
//                                           ),
//                                         ),
//                                       );

//                                       setState(() {
//                                         conv['unread_count'] = 0;
//                                       });

//                                       // 🔹 Emit socket event
//                                       try {
//                                         socket?.emit('mark_messages_seen', {
//                                           'conversationId': convoId,
//                                           'userId': widget.currentUserId,
//                                         });
//                                       } catch (e) {
//                                         debugPrint("Socket error: $e");
//                                       }

//                                       // 🔹 Backend call
//                                       try {
//                                         await http.post(
//                                           Uri.parse(
//                                             "${Backend.baseUrl}/conversations/$convoId/seen",
//                                           ),
//                                           body: jsonEncode({
//                                             'user_id': widget.currentUserId,
//                                           }),
//                                           headers: {
//                                             "Content-Type": "application/json",
//                                           },
//                                         );
//                                       } catch (e) {
//                                         debugPrint(
//                                           "Error marking conversation seen: $e",
//                                         );
//                                       }

//                                       widget.onConversationSeen?.call(convoId);
//                                     },
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 10,
//                                       ),
//                                       color: Colors.transparent,
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             padding: const EdgeInsets.all(2.5),
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               gradient: LinearGradient(
//                                                 colors: [
//                                                   kPrimaryColor.withOpacity(
//                                                     0.9,
//                                                   ),
//                                                   kPrimaryColor.withOpacity(
//                                                     0.9,
//                                                   ),
//                                                 ],
//                                                 begin: Alignment.topLeft,
//                                                 end: Alignment.bottomRight,
//                                               ),
//                                             ),
//                                             child: ClipOval(
//                                               child: Container(
//                                                 color: _getColorFromName(
//                                                   otherName,
//                                                 ),
//                                                 child:
//                                                     (otherAvatar != null &&
//                                                         otherAvatar
//                                                             .toString()
//                                                             .isNotEmpty)
//                                                     ? Image.network(
//                                                         "${Backend.baseUrl}/$otherAvatar",
//                                                         fit: BoxFit.cover,
//                                                         width: 56,
//                                                         height: 56,
//                                                         errorBuilder:
//                                                             (
//                                                               context,
//                                                               error,
//                                                               stackTrace,
//                                                             ) =>
//                                                                 _buildInitialAvatar(
//                                                                   otherName,
//                                                                 ),
//                                                       )
//                                                     : _buildInitialAvatar(
//                                                         otherName,
//                                                       ),
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: 12),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   otherName,
//                                                   style: TextStyle(
//                                                     color: kTextPrimary,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 16,
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: 4),
//                                                 Text(
//                                                   lastMessage,
//                                                   maxLines: 1,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: TextStyle(
//                                                     color: messageColor,
//                                                     fontSize: 14,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           SizedBox(width: 8),
//                                           Text(
//                                             formatChatTime(
//                                               context,
//                                               conv['last_message_time'],
//                                             ),
//                                             style: TextStyle(
//                                               color: kTextSecondary,
//                                               fontSize: 12,
//                                             ),
//                                           ),

//                                           // ⭐ Favourite toggle icon
//                                           IconButton(
//                                             icon: Icon(
//                                               conv['is_favourite'] == true
//                                                   ? Icons.star
//                                                   : Icons.star_border,
//                                               color:
//                                                   conv['is_favourite'] == true
//                                                   ? Colors.amber
//                                                   : kTextSecondary,
//                                             ),
//                                             onPressed: () async {
//                                               final newValue =
//                                                   !(conv['is_favourite'] ==
//                                                       true);

//                                               // 👇 Optimistic UI update (turant change dikhayega)
//                                               setState(() {
//                                                 conv['is_favourite'] = newValue;
//                                                 if (_selectedTabIndex == 1 &&
//                                                     !newValue) {
//                                                   filteredConversations
//                                                       .removeAt(index);
//                                                 }
//                                               });

//                                               try {
//                                                 final url = Uri.parse(
//                                                   '${Backend.baseUrl}/conversations/${conv['conversation_id']}/favourite',
//                                                 );

//                                                 final response = await http.put(
//                                                   url,
//                                                   headers: {
//                                                     'Content-Type':
//                                                         'application/json',
//                                                   },
//                                                   body: jsonEncode({
//                                                     'is_favourite': newValue,
//                                                   }),
//                                                 );

//                                                 if (response.statusCode !=
//                                                     200) {
//                                                   debugPrint(
//                                                     "❌ Failed to update favourite: ${response.body}",
//                                                   );
//                                                   // 👇 Backend fail hua, rollback karo
//                                                   setState(() {
//                                                     conv['is_favourite'] =
//                                                         !newValue;
//                                                     if (_selectedTabIndex ==
//                                                             1 &&
//                                                         newValue) {
//                                                       filteredConversations
//                                                           .insert(index, conv);
//                                                     }
//                                                   });
//                                                 }
//                                               } catch (e) {
//                                                 debugPrint(
//                                                   '❌ Error updating favourite: $e',
//                                                 );
//                                                 // 👇 Error me rollback bhi zaruri
//                                                 setState(() {
//                                                   conv['is_favourite'] =
//                                                       !newValue;
//                                                   if (_selectedTabIndex == 1 &&
//                                                       newValue) {
//                                                     filteredConversations
//                                                         .insert(index, conv);
//                                                   }
//                                                 });
//                                               }
//                                             },
//                                           ),

//                                           if (unreadCount > 0) ...[
//                                             SizedBox(width: 8),
//                                             Container(
//                                               padding: EdgeInsets.all(6),
//                                               decoration: BoxDecoration(
//                                                 color: redAccent,
//                                                 shape: BoxShape.circle,
//                                               ),
//                                               child: Text(
//                                                 '$unreadCount',
//                                                 style: TextStyle(
//                                                   color: redAccent,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     )
//                   : StatusPage(
//                       key: const ValueKey('status'),
//                       currentUserId: widget.currentUserId,
//                       isProvider: widget.role == "provider",
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getColorFromName(String name) {
//     final colors = [
//       Colors.deepPurple,
//       Colors.teal,
//       Colors.indigo,
//       Colors.orange,
//       Colors.pinkAccent,
//       Colors.cyan,
//       Colors.blueGrey,
//       Colors.deepOrangeAccent,
//       Colors.green,
//       Colors.redAccent,
//     ];
//     if (name.isEmpty) return Colors.grey;
//     int hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
//     return colors[hash % colors.length];
//   }

//   Widget _buildInitialAvatar(String name) {
//     final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
//     final letterColor = _getColorFromName(name);
//     return Container(
//       width: 56,
//       height: 56,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: kBackgroundColor,
//         shape: BoxShape.circle,
//       ),
//       child: Text(
//         initial,
//         style: TextStyle(
//           color: letterColor,
//           fontWeight: FontWeight.bold,
//           fontSize: 22,
//         ),
//       ),
//     );
//   }
// }

// // ✅ formatChatTime function stays the same
// String formatChatTime(BuildContext context, String? dateTimeStr) {
//   if (dateTimeStr == null) return '';
//   final dateTime = DateTime.parse(dateTimeStr).toLocal();
//   final now = DateTime.now();
//   final today = DateTime(now.year, now.month, now.day);
//   final yesterday = today.subtract(Duration(days: 1));
//   final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
//   if (msgDate == today) return TimeOfDay.fromDateTime(dateTime).format(context);
//   if (msgDate == yesterday) return 'Yesterday';
//   return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'notifications_page.dart';
import 'chat_page.dart';
import '../helpers/backend.dart';
import 'status_screen.dart';
import '../helpers/coolors.dart';
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
  late final socket = SocketManager().socket;
  int _selectedTabIndex = 0; // 0 = All, 1 = Favourites
  bool _isLoading = false;

  // ✅ Use singleton socket
  @override
  void initState() {
    super.initState();
    filteredConversations = widget.conversations;
    _searchController.addListener(_filterChats);
    _localUnseenNotificationsCount = widget.unseenNotificationsCount;

    // ✅ Safety check before using socket
    if (socket != null) {
      // 🔹 Listen for messages seen
      socket!.on('messages_seen', (data) {
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
      socket!.on('new_message', (data) {
        final convId = data['conversationId'];
        final message = data['message'];
        final createdAt = data['created_at'];
        final otherUserId = data['other_user_id'];
        final otherUserName = data['other_user_name'];
        final otherUserAvatar = data['other_user_avatar'];

        setState(() {
          final index = filteredConversations.indexWhere(
            (conv) => conv['conversation_id'] == convId,
          );

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
    } else {
      debugPrint("⚠️ Socket is null, skipping listeners for now");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    // ✅ Only remove listeners if socket is connected
    if (socket != null) {
      socket!.off('messages_seen');
      socket!.off('new_message');
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessagesTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.unseenNotificationsCount != widget.unseenNotificationsCount) {
      setState(() {
        _localUnseenNotificationsCount = widget.unseenNotificationsCount;
      });
    }

    setState(() {
      filteredConversations = List.from(widget.conversations);
      _filterChats();
    });
  }

  Future<void> _refreshChats() async {
    await widget.onRefresh(); // fetch from backend
    setState(() {
      filteredConversations = List.from(widget.conversations);
      _filterChats();
    });
  }

  Future<void> _fetchFavouriteChats() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
        '${Backend.baseUrl}/conversations/favourites?user_id=${widget.currentUserId}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final favourites = data['favourites'] ?? [];
        setState(() {
          filteredConversations = List.from(favourites);
        });
      } else {
        debugPrint("❌ Failed to fetch favourites: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching favourites: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredConversations = List.from(widget.conversations);
      } else {
        filteredConversations = widget.conversations
            .where(
              (c) => (c['other_user_name'] ?? '').toLowerCase().contains(query),
            )
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

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTabIndex = index);
        if (index == 1) {
          _fetchFavouriteChats();
        } else {
          _refreshChats();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? kPrimaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? kPrimaryColor : kTextSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor, // AppBar ka color
        elevation: 0, // bilkul flat
        titleSpacing: 16,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => setState(() => _isChatsSelected = true),
              child: Text(
                "My Chats",
                style: TextStyle(
                  color: _isChatsSelected ? kPrimaryColor : kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            Row(
              children: [
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: heaidng,
                        size: 28,
                      ),
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
                            border: Border.all(color: kTextPrimary, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '$_localUnseenNotificationsCount',
                              style: TextStyle(
                                color: kTextPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: kTextPrimary, size: 28),
                  onPressed: () async {
                    final selected = await showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        1000,
                        80,
                        0,
                        0,
                      ), // adjust menu position
                      items: [
                        PopupMenuItem<String>(
                          value: 'delete_all',
                          child: Text('Delete All'),
                        ),
                      ],
                    );

                    if (selected == 'delete_all') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text(
                            'Are you sure you want to delete all chats?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          final response = await http.delete(
                            Uri.parse('${Backend.baseUrl}/messages/all'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({'userId': widget.currentUserId}),
                          );

                          debugPrint('Response Code: ${response.statusCode}');
                          debugPrint('Response Body: ${response.body}');

                          if (response.statusCode == 200) {
                            setState(() {
                              filteredConversations.clear();
                              widget.conversations.clear();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('All chats deleted successfully'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete chats')),
                            );
                          }
                        } catch (e) {
                          debugPrint('❌ Error deleting all chats: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting chats')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: const TextStyle(color: kTextSecondary),
                prefixIcon: const Icon(Icons.search, color: kTextSecondary),
                filled: true,
                fillColor: const Color.fromARGB(255, 224, 222, 222),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: kCardColor, width: 2),
                ),
              ),
            ),
          ),
          // 🔹 WhatsApp-style Tabs
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTabButton('All', 0),
                const SizedBox(width: 16), // thoda sa neat gap bas
                _buildTabButton('Favourites', 1),
              ],
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
                      onRefresh: _refreshChats,

                      color: kPrimaryColor,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                              ),
                            )
                          : filteredConversations.isEmpty
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
                                        color: kTextSecondary,
                                      ),
                                    ),
                                  ),
                                ),
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
                                  messageColor = kTextSecondary;
                                }

                                return Dismissible(
                                  key: ValueKey(
                                    'conv_${conv['conversation_id']}_${index}',
                                  ),

                                  direction: DismissDirection
                                      .endToStart, // Right to left swipe
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text('Confirm Delete'),
                                        content: Text(
                                          'Delete this conversation?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onDismissed: (direction) async {
                                    final convoId = conv['conversation_id'];

                                    // Remove from UI immediately to prevent tree conflict
                                    setState(() {
                                      filteredConversations.removeWhere(
                                        (c) => c['conversation_id'] == convoId,
                                      );
                                    });

                                    try {
                                      print(
                                        '🟡 Deleting conversation: $convoId for user: ${widget.currentUserId}',
                                      );

                                      final url = Uri.parse(
                                        '${Backend.baseUrl}/messages/conversation/$convoId?userId=${widget.currentUserId}',
                                      );
                                      print('🌐 DELETE URL: $url');

                                      final response = await http.delete(url);

                                      print(
                                        '🔵 Response status: ${response.statusCode}',
                                      );
                                      print(
                                        '🟢 Response body: ${response.body}',
                                      );

                                      if (response.statusCode == 200) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Conversation deleted successfully',
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to delete conversation',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e, s) {
                                      print('🔴 Exception: $e');
                                      print('🔴 StackTrace: $s');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error deleting conversation',
                                          ),
                                        ),
                                      );
                                    }
                                  },

                                  child: GestureDetector(
                                    onTap: () async {
                                      final otherUserId =
                                          conv['other_user_id'] ??
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
                                        socket?.emit('mark_messages_seen', {
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
                                            "${Backend.baseUrl}/conversations/$convoId/seen",
                                          ),
                                          body: jsonEncode({
                                            'user_id': widget.currentUserId,
                                          }),
                                          headers: {
                                            "Content-Type": "application/json",
                                          },
                                        );
                                      } catch (e) {
                                        debugPrint(
                                          "Error marking conversation seen: $e",
                                        );
                                      }

                                      widget.onConversationSeen?.call(convoId);
                                    },

                                    // 🟢 New long-press handler for favourites
                                    onLongPress: () async {
                                      final isFav =
                                          conv['is_favourite'] == true;
                                      final action = isFav
                                          ? 'Remove from favourites'
                                          : 'Add to favourites';

                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: kCardColor,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) {
                                          return SafeArea(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: Icon(
                                                    isFav
                                                        ? Icons.star_border
                                                        : Icons.star,
                                                    color: kPrimaryColor,
                                                  ),
                                                  title: Text(
                                                    action,
                                                    style: const TextStyle(
                                                      color: kTextPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    Navigator.pop(context);

                                                    final newValue = !isFav;
                                                    setState(() {
                                                      conv['is_favourite'] =
                                                          newValue;
                                                      if (_selectedTabIndex ==
                                                              1 &&
                                                          !newValue) {
                                                        filteredConversations
                                                            .remove(conv);
                                                      }
                                                    });

                                                    try {
                                                      final url = Uri.parse(
                                                        '${Backend.baseUrl}/conversations/${conv['conversation_id']}/favourite',
                                                      );
                                                      final response =
                                                          await http.put(
                                                            url,
                                                            headers: {
                                                              'Content-Type':
                                                                  'application/json',
                                                            },
                                                            body: jsonEncode({
                                                              'is_favourite':
                                                                  newValue,
                                                            }),
                                                          );

                                                      if (response.statusCode !=
                                                          200) {
                                                        setState(() {
                                                          conv['is_favourite'] =
                                                              !newValue;
                                                        });
                                                      }
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            newValue
                                                                ? 'Added to favourites ⭐'
                                                                : 'Removed from favourites',
                                                          ),
                                                          duration: Duration(
                                                            seconds: 2,
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      debugPrint(
                                                        '❌ Error updating favourite: $e',
                                                      );
                                                    }
                                                  },
                                                ),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      color: Colors.transparent,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2.5),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  kPrimaryColor.withOpacity(
                                                    0.9,
                                                  ),
                                                  kPrimaryColor.withOpacity(
                                                    0.9,
                                                  ),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: Container(
                                                color: _getColorFromName(
                                                  otherName,
                                                ),
                                                child:
                                                    (otherAvatar != null &&
                                                        otherAvatar
                                                            .toString()
                                                            .isNotEmpty)
                                                    ? Image.network(
                                                        "${Backend.baseUrl}/$otherAvatar",
                                                        fit: BoxFit.cover,
                                                        width: 56,
                                                        height: 56,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) =>
                                                                _buildInitialAvatar(
                                                                  otherName,
                                                                ),
                                                      )
                                                    : _buildInitialAvatar(
                                                        otherName,
                                                      ),
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
                                                    color: kTextPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  lastMessage,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                              context,
                                              conv['last_message_time'],
                                            ),
                                            style: TextStyle(
                                              color: kTextSecondary,
                                              fontSize: 12,
                                            ),
                                          ),

                                          if (unreadCount > 0) ...[
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: redAccent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '$unreadCount',
                                                style: TextStyle(
                                                  color: redAccent,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
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
        color: kBackgroundColor,
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
