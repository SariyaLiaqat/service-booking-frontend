// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import '../helpers/backend.dart';
// import '../helpers/my_colors.dart';
// import '../helpers/socket_manager.dart';

// class ChatPage extends StatefulWidget {
//   final int conversationId;
//   final int currentUserId;
//   final int otherUserId;

//   const ChatPage({
//     Key? key,
//     required this.conversationId,
//     required this.currentUserId,
//     required this.otherUserId,
//   }) : super(key: key);

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
//   List<dynamic> messages = [];
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   bool otherOnline = false;
//   bool otherTyping = false;
//   String otherName = 'Unknown';
//   String? otherAvatar;
//   int? _conversationId;

//   StreamSubscription? _messageSub;
//   StreamSubscription? _typingSub;
//   StreamSubscription? _statusSub;
//   StreamSubscription? _deleteSub;
//   StreamSubscription? _editSub;

//  @override
// void initState() {
//   super.initState();
//   _conversationId = widget.conversationId > 0 ? widget.conversationId : null;

//   // 1️⃣ Socket initialize
//   SocketManager().initSocket().then((_) {
//     // 2️⃣ Ab stream subscriptions
//     _messageSub = SocketManager.onNewMessage.listen((data) {
//       if (mounted)
//         setState(() {
//           final exists = messages.any((m) => m['id'] == data['id']);
//           if (!exists) messages.add(data..['isNew'] = true);
//           scrollToBottom();
//         });
//     });

//     _typingSub = SocketManager.onTyping.listen((data) {
//       if (mounted && data['userId'] == widget.otherUserId) {
//         setState(() => otherTyping = data['isTyping'] ?? false);
//       }
//     });

//     _statusSub = SocketManager.onUserStatus.listen((data) {
//       if (mounted && data['userId'] == widget.otherUserId) {
//         setState(() => otherOnline = data['isOnline'] ?? false);
//       }
//     });

//     _deleteSub = SocketManager.onMessageDeleted.listen((data) {
//       if (mounted)
//         setState(() => messages.removeWhere((m) => m['id'] == data['messageId']));
//     });

//     _editSub = SocketManager.onMessageEdited.listen((data) {
//       if (mounted) {
//         int idx = messages.indexWhere((m) => m['id'] == data['messageId']);
//         if (idx != -1) messages[idx]['message'] = data['newMessage'];
//       }
//     });
//   });

//   // 3️⃣ Baaki fetch & mark messages
//   fetchConversationDetails();
//   if (_conversationId != null) fetchMessages();
//   markMessagesSeen();
// }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     _messageSub?.cancel();
//     _typingSub?.cancel();
//     _statusSub?.cancel();
//     _deleteSub?.cancel();
//     _editSub?.cancel();
//     super.dispose();
//   }

//   Future<void> markMessagesSeen() async {
//     if (_conversationId == null) return;
//     try {
//       await http.post(
//         Uri.parse("${Backend.baseUrl}/messages/mark-seen"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "conversationId": _conversationId,
//           "userId": widget.currentUserId,
//         }),
//       );
//       setState(() {});
//     } catch (e) {
//       print("Error marking messages as seen: $e");
//     }
//   }

//   Future<void> fetchConversationDetails() async {
//     if (_conversationId == null) return;
//     try {
//       final url = Uri.parse(
//         "${Backend.baseUrl}/conversations/$_conversationId",
//       );
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final participants = data['participants'] as List<dynamic>? ?? [];
//         final otherUser = participants.firstWhere(
//           (p) => p['id'] != widget.currentUserId,
//           orElse: () => null,
//         );
//         if (otherUser != null) {
//           setState(() {
//             otherName = otherUser['name'] ?? 'Unknown';
//             otherAvatar =
//                 (otherUser['profile_image'] != null &&
//                     otherUser['profile_image'].toString().isNotEmpty)
//                 ? "${Backend.baseUrl}/${otherUser['profile_image']}"
//                 : null;
//             otherOnline = otherUser['is_active'] ?? false;
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching conversation details: $e");
//     }
//   }

//   Future<void> fetchMessages() async {
//     if (_conversationId == null) return;
//     try {
//       final url = Uri.parse(
//         "${Backend.baseUrl}/messages?conversation_id=$_conversationId",
//       );
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           messages = (data['messages'] as List<dynamic>? ?? [])
//               .where(
//                 (m) =>
//                     m != null && m['sender_id'] != null && m['message'] != null,
//               )
//               .toList();
//         });
//         scrollToBottom();
//       }
//     } catch (e) {
//       print("Error fetching messages: $e");
//     }
//   }

//   void scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent + 50,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Future<void> sendMessage(String text) async {
//     if (text.trim().isEmpty) return;
//     int? conversationId = _conversationId;

//     // Make sure socket is connected
//     if (SocketManager().socket == null || !SocketManager().socket!.connected) {
//       await SocketManager().initSocket();
//     }

//     try {
//       if (conversationId == null) {
//         // Create conversation if not exists
//         final convResponse = await http.post(
//           Uri.parse("${Backend.baseUrl}/conversations"),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             "user_id": widget.currentUserId,
//             "provider_id": widget.otherUserId,
//           }),
//         );
//         if (convResponse.statusCode == 200 || convResponse.statusCode == 201) {
//           final convData = jsonDecode(convResponse.body);
//           conversationId = convData['id'] ?? convData['conversation_id'];
//           setState(() => _conversationId = conversationId);
//         } else
//           return;
//       }

//       final tempId = DateTime.now().millisecondsSinceEpoch;

//       setState(() {
//         messages.add({
//           "id": tempId,
//           "conversation_id": conversationId,
//           "sender_id": widget.currentUserId,
//           "message": text.trim(),
//           "created_at": DateTime.now().toIso8601String(),
//           "isNew": true,
//         });
//       });

//       _controller.clear();
//       scrollToBottom();

//       SocketManager().sendMessage(
//         conversationId!,
//         widget.currentUserId,
//         widget.otherUserId,
//         text.trim(),
//         tempId,
//       );
//     } catch (e) {
//       print("Error sending message: $e");
//     }
//   }

//   void handleLongPress(dynamic message) {
//     final createdAt = message['created_at'] != null
//         ? DateTime.tryParse(message['created_at'])?.toLocal()
//         : null;

//     bool canDeleteForEveryone = false;

//     if (createdAt != null && message['sender_id'] == widget.currentUserId) {
//       final diffHours = DateTime.now().difference(createdAt).inHours;
//       if (diffHours < 2) canDeleteForEveryone = true;
//     }

//     showModalBottomSheet(
//       context: context,
//       builder: (_) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               if (message['sender_id'] == widget.currentUserId)
//                 ListTile(
//                   leading: Icon(Icons.edit),
//                   title: Text('Edit'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     editMessageDialog(message);
//                   },
//                 ),
//               if (canDeleteForEveryone)
//                 ListTile(
//                   leading: Icon(Icons.delete_forever),
//                   title: Text('Delete for Everyone'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     deleteMessage(message, deleteForEveryone: true);
//                   },
//                 ),
//               ListTile(
//                 leading: Icon(Icons.delete),
//                 title: Text('Delete for Me'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   deleteMessage(message, deleteForEveryone: false);
//                 },
//               ),
//               if (message['deleted_for_everyone'] != true)
//                 ListTile(
//                   leading: Icon(Icons.copy),
//                   title: Text('Copy'),
//                   onTap: () {
//                     Clipboard.setData(ClipboardData(text: message['message']));
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text('Message copied')));
//                   },
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> deleteMessage(
//     dynamic message, {
//     required bool deleteForEveryone,
//   }) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Delete Message"),
//         content: Text(
//           deleteForEveryone
//               ? "Are you sure you want to delete this message for everyone?"
//               : "Are you sure you want to delete this message for yourself?",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text("Delete", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     try {
//       final response = await http.delete(
//         Uri.parse("${Backend.baseUrl}/messages/${message['id']}"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "userId": widget.currentUserId,
//           "deleteForEveryone": deleteForEveryone,
//         }),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           if (deleteForEveryone) {
//             messages.removeWhere((m) => m['id'] == message['id']);
//           } else {
//             int idx = messages.indexWhere((m) => m['id'] == message['id']);
//             if (idx != -1) messages[idx]['deletedForMe'] = true;
//           }
//         });

//         if (_conversationId != null) {
//           SocketManager().emit('delete_message', {
//             'conversationId': _conversationId,
//             'messageId': message['id'],
//             'deleteForEveryone': deleteForEveryone,
//           });
//         }
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Failed to delete message")));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error deleting message")));
//     }
//   }

//   void editMessageDialog(dynamic message) {
//     final editController = TextEditingController(text: message['message']);

//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: Text('Edit Message'),
//           content: TextField(controller: editController, maxLines: 5),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 final newText = editController.text.trim();
//                 if (newText.isEmpty) return;

//                 Navigator.pop(context);

//                 try {
//                   final response = await http.put(
//                     Uri.parse("${Backend.baseUrl}/messages/${message['id']}"),
//                     headers: {"Content-Type": "application/json"},
//                     body: jsonEncode({
//                       "userId": widget.currentUserId,
//                       "newMessage": newText,
//                     }),
//                   );

//                   if (response.statusCode == 200) {
//                     setState(() {
//                       int idx = messages.indexWhere(
//                         (m) => m['id'] == message['id'],
//                       );
//                       if (idx != -1) messages[idx]['message'] = newText;
//                     });

//                     if (_conversationId != null) {
//                       SocketManager().emit('edit_message', {
//                         'conversationId': _conversationId,
//                         'messageId': message['id'],
//                         'newText': newText,
//                       });
//                     }
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Failed to edit message")),
//                     );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Error editing message")),
//                   );
//                 }
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget buildMessageBubble(dynamic message) {
//     final isMe = message['sender_id'] == widget.currentUserId;
//     final messageText = message['message'] ?? '';
//     final createdAt = message['created_at'] != null
//         ? DateTime.tryParse(message['created_at'])?.toLocal()
//         : null;

//     final Color myMessageColor = MyColors.primary;
//     final Color otherMessageColor = MyColors.surface;
//     final Color myTextColor = MyColors.textPrimary;
//     final Color otherTextColor = MyColors.textPrimary;
//     final Color timeTextColor = MyColors.textSecondary;

//     final Color bubbleColor = isMe ? myMessageColor : otherMessageColor;
//     final Color textColor = isMe ? myTextColor : otherTextColor;
//     final isDeleted =
//         message['deleted_for_everyone'] == true ||
//         (message['deleted_for'] != null &&
//             (message['deleted_for'] as List).contains(widget.currentUserId));
//     final messageTextToShow = isDeleted
//         ? 'This message was deleted'
//         : (message['message'] ?? '');
//     final textColorToShow = isDeleted ? Colors.grey : textColor;

//     final BorderRadius borderRadius = BorderRadius.only(
//       topLeft: Radius.circular(isMe ? 18.0 : 4.0),
//       topRight: Radius.circular(isMe ? 4.0 : 18.0),
//       bottomLeft: const Radius.circular(18.0),
//       bottomRight: const Radius.circular(18.0),
//     );

//     return Padding(
//       padding: EdgeInsets.only(
//         top: 2,
//         bottom: 2,
//         left: isMe ? 50 : 8,
//         right: isMe ? 8 : 50,
//       ),
//       child: Row(
//         mainAxisAlignment: isMe
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Flexible(
//             child: GestureDetector(
//               onLongPress: () => handleLongPress(message),
//               child: Column(
//                 crossAxisAlignment: isMe
//                     ? CrossAxisAlignment.end
//                     : CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: bubbleColor,
//                       borderRadius: borderRadius,
//                     ),
//                     child: Text(
//                       messageTextToShow,
//                       style: TextStyle(
//                         color: textColorToShow,
//                         fontSize: 16,
//                         fontStyle: isDeleted
//                             ? FontStyle.italic
//                             : FontStyle.normal,
//                       ),
//                       softWrap: true,
//                     ),
//                   ),
//                   if (createdAt != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
//                       child: Text(
//                         "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
//                         style: TextStyle(color: timeTextColor, fontSize: 10),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget typingIndicator() {
//     return otherTyping
//         ? Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Row(
//               children: [
//                 CircleAvatar(radius: 12, child: Icon(Icons.person, size: 12)),
//                 SizedBox(width: 6),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: MyColors.surface,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     'Typing...',
//                     style: TextStyle(color: MyColors.textSecondary),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         : SizedBox.shrink();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.background,
//       appBar: AppBar(
//         backgroundColor: MyColors.surface,
//         elevation: 1,
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundImage: otherAvatar != null
//                   ? NetworkImage(otherAvatar!)
//                   : null,
//               child: otherAvatar == null
//                   ? Icon(Icons.person, color: Colors.white)
//                   : null,
//               backgroundColor: MyColors.primary,
//             ),
//             SizedBox(width: 10),
//             Flexible(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     otherName,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: MyColors.textPrimary,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     otherOnline ? 'Active' : 'Offline',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: otherOnline
//                           ? MyColors.primary
//                           : MyColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: messages.length + 1,
//               itemBuilder: (context, index) {
//                 if (index == messages.length) return typingIndicator();
//                 return buildMessageBubble(messages[index]);
//               },
//             ),
//           ),
//           SafeArea(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//               decoration: BoxDecoration(
//                 color: MyColors.surface,
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       minLines: 1,
//                       maxLines: 5,
//                       keyboardType: TextInputType.multiline,
//                       textInputAction: TextInputAction.newline,
//                       decoration: InputDecoration(
//                         hintText: 'Type a message...',
//                         hintStyle: TextStyle(color: MyColors.textSecondary),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide.none,
//                         ),
//                         fillColor: MyColors.inputFill,
//                         filled: true,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       style: TextStyle(color: MyColors.textPrimary),
//                       onChanged: (_) {
//                         SocketManager().setTyping(
//                           widget.currentUserId,
//                           _controller.text.trim().isNotEmpty,
//                         );
//                         setState(() {});
//                       },
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.send,
//                       color: _controller.text.trim().isEmpty
//                           ? MyColors.textSecondary
//                           : MyColors.primary,
//                     ),
//                     onPressed: _controller.text.trim().isEmpty
//                         ? null
//                         : () => sendMessage(_controller.text),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import '../helpers/backend.dart';
// import '../helpers/my_colors.dart';
// import '../helpers/socket_manager.dart';

// class ChatPage extends StatefulWidget {
//   final int conversationId;
//   final int currentUserId;
//   final int otherUserId;

//   const ChatPage({
//     Key? key,
//     required this.conversationId,
//     required this.currentUserId,
//     required this.otherUserId,
//   }) : super(key: key);

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
//   List<dynamic> messages = [];
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   bool otherOnline = false;
//   bool otherTyping = false;
//   String otherName = 'Unknown';
//   String? otherAvatar;
//   int? _conversationId;

//   StreamSubscription? _messageSub;
//   StreamSubscription? _typingSub;
//   StreamSubscription? _statusSub;
//   StreamSubscription? _deleteSub;////
//   StreamSubscription? _editSub;

// @override
//   void initState() {
//     super.initState();
//     _conversationId = widget.conversationId > 0 ? widget.conversationId : null;
//     initChat();
//   }

//   Future<void> initChat() async {
//     // 1️⃣ Agar conversation ID null hai, create ya fetch karo
//     if (_conversationId == null) {
//       _conversationId = await createOrFetchConversation();
//       if (_conversationId == null) return; // still null, stop
//       setState(() {});
//     }

//     // 2️⃣ Initialize socket
//     await SocketManager().initSocket();
//     SocketManager().joinConversation(_conversationId!, widget.currentUserId);
// // --------------- Debug: check if messages come ---------------
//     SocketManager.onNewMessage.listen((data) {
//       print("New message received: $data"); // ✅ yahan check hoga
//     });
//     // ----------------------------------------------------------------
//     // 3️⃣ Listen to streams
//   _messageSub = SocketManager.onNewMessage.listen((data) {
//   print("New message received: $data");

//   // Use the correct conversation ID
//   final convId = _conversationId ?? widget.conversationId;
//   if (!mounted) return;

//   // Only add messages for this conversation
//   if (data['conversation_id'] == convId) {
//     setState(() {
//       // Avoid duplicates
//       if (!messages.any((m) => m['id'] == data['id'])) {
//         messages.add(data..['isNew'] = true);
//       }
//     });

//     // Scroll to bottom after a frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent + 50,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
// });

//     _typingSub = SocketManager.onTyping.listen((data) {
//       if (mounted && data['userId'] == widget.otherUserId) {
//         setState(() => otherTyping = data['isTyping'] ?? false);
//       }
//     });

//     _statusSub = SocketManager.onUserStatus.listen((data) {
//       if (mounted && data['userId'] == widget.otherUserId) {
//         setState(() => otherOnline = data['isOnline'] ?? false);
//       }
//     });

//     _deleteSub = SocketManager.onMessageDeleted.listen((data) {
//       if (mounted) {
//         setState(() => messages.removeWhere((m) => m['id'] == data['messageId']));
//       }
//     });

//     _editSub = SocketManager.onMessageEdited.listen((data) {
//       if (mounted) {
//         int idx = messages.indexWhere((m) => m['id'] == data['messageId']);
//         if (idx != -1) messages[idx]['message'] = data['newMessage'];
//       }
//     });

//     // 4️⃣ Fetch messages & conversation details
//     await fetchConversationDetails();
//     await fetchMessages();
//     await markMessagesSeen();
//   }

//   // ✅ Conversation create/fetch logic
//   Future<int?> createOrFetchConversation() async {
//     try {
//       final resp = await http.post(
//         Uri.parse("${Backend.baseUrl}/conversations"),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "user_id": widget.currentUserId,
//           "provider_id": widget.otherUserId,
//         }),
//       );
//       if (resp.statusCode == 200 || resp.statusCode == 201) {
//         final data = jsonDecode(resp.body);
//         return data['id'] ?? data['conversation_id'];
//       }
//     } catch (e) {
//       print("Error creating/fetching conversation: $e");
//     }
//     return null;
//   }

//   @override
//   void dispose() {
//     if (_conversationId != null) {
//       SocketManager().leaveConversation(_conversationId!, widget.currentUserId);
//     }
//     _controller.dispose();
//     _scrollController.dispose();
//     _messageSub?.cancel();
//     _typingSub?.cancel();
//     _statusSub?.cancel();
//     _deleteSub?.cancel();
//     _editSub?.cancel();
//     super.dispose();
//   }

//   Future<void> markMessagesSeen() async {
//     if (_conversationId == null) return;
//     try {
//       await http.post(
//         Uri.parse("${Backend.baseUrl}/messages/mark-seen"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "conversationId": _conversationId,
//           "userId": widget.currentUserId,
//         }),
//       );
//     } catch (e) {
//       print("Error marking messages as seen: $e");
//     }
//   }

//   Future<void> fetchConversationDetails() async {
//     if (_conversationId == null) return;
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations/$_conversationId");
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final participants = data['participants'] as List<dynamic>? ?? [];
//         final otherUser = participants.firstWhere(
//           (p) => p['id'] != widget.currentUserId,
//           orElse: () => null,
//         );
//         if (otherUser != null) {
//           setState(() {
//             otherName = otherUser['name'] ?? 'Unknown';
//             otherAvatar =
//                 (otherUser['profile_image'] != null && otherUser['profile_image'].toString().isNotEmpty)
//                     ? "${Backend.baseUrl}/${otherUser['profile_image']}"
//                     : null;
//             otherOnline = otherUser['is_active'] ?? false;
//           });
//         }
//       }
//     } catch (e) {
//       print("Error fetching conversation details: $e");
//     }
//   }

//   Future<void> fetchMessages() async {
//     if (_conversationId == null) return;
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/messages?conversation_id=$_conversationId");
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           messages = (data['messages'] as List<dynamic>? ?? [])
//               .where((m) => m != null && m['sender_id'] != null && m['message'] != null)
//               .toList();
//         });
//         scrollToBottom();
//       }
//     } catch (e) {
//       print("Error fetching messages: $e");
//     }
//   }

//   void scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent + 50,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//  Future<void> sendMessage(String text) async {
//   if (text.trim().isEmpty) return;
//   int? conversationId = _conversationId;

//   if (SocketManager().socket == null || !SocketManager().socket!.connected) {
//     await SocketManager().initSocket();
//     if (conversationId != null) {
//       SocketManager().joinConversation(conversationId, widget.currentUserId);
//     }
//   }

//   try {
//     if (conversationId == null) {
//       // Create conversation if not exists
//       final convResponse = await http.post(
//         Uri.parse("${Backend.baseUrl}/conversations"),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "user_id": widget.currentUserId,
//           "provider_id": widget.otherUserId,
//         }),
//       );
//       if (convResponse.statusCode == 200 || convResponse.statusCode == 201) {
//         final convData = jsonDecode(convResponse.body);
//         conversationId = convData['id'] ?? convData['conversation_id'];
//         setState(() => _conversationId = conversationId);
//         // Join newly created conversation
//         SocketManager().joinConversation(conversationId!, widget.currentUserId);
//       } else
//         return;
//     }

//     final tempId = DateTime.now().millisecondsSinceEpoch;
//     setState(() {
//       messages.add({
//         "id": tempId,
//         "conversation_id": conversationId,
//         "sender_id": widget.currentUserId,
//         "message": text.trim(),
//         "created_at": DateTime.now().toIso8601String(),
//         "isNew": true,
//       });
//     });

//     _controller.clear();
//     scrollToBottom();

//     SocketManager().sendMessage(
//       conversationId!,
//       widget.currentUserId,
//       widget.otherUserId,
//       text.trim(),
//       tempId,
//     );
//   } catch (e) {
//     print("Error sending message: $e");
//   }
// }
//   void handleLongPress(dynamic message) {
//     final createdAt = message['created_at'] != null
//         ? DateTime.tryParse(message['created_at'])?.toLocal()
//         : null;

//     bool canDeleteForEveryone = false;

//     if (createdAt != null && message['sender_id'] == widget.currentUserId) {
//       final diffHours = DateTime.now().difference(createdAt).inHours;
//       if (diffHours < 2) canDeleteForEveryone = true;
//     }

//     showModalBottomSheet(
//       context: context,
//       builder: (_) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               if (message['sender_id'] == widget.currentUserId)
//                 ListTile(
//                   leading: Icon(Icons.edit),
//                   title: Text('Edit'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     editMessageDialog(message);
//                   },
//                 ),
//               if (canDeleteForEveryone)
//                 ListTile(
//                   leading: Icon(Icons.delete_forever),
//                   title: Text('Delete for Everyone'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     deleteMessage(message, deleteForEveryone: true);
//                   },
//                 ),
//               ListTile(
//                 leading: Icon(Icons.delete),
//                 title: Text('Delete for Me'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   deleteMessage(message, deleteForEveryone: false);
//                 },
//               ),
//               if (message['deleted_for_everyone'] != true)
//                 ListTile(
//                   leading: Icon(Icons.copy),
//                   title: Text('Copy'),
//                   onTap: () {
//                     Clipboard.setData(ClipboardData(text: message['message']));
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text('Message copied')));
//                   },
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> deleteMessage(
//     dynamic message, {
//     required bool deleteForEveryone,
//   }) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Delete Message"),
//         content: Text(
//           deleteForEveryone
//               ? "Are you sure you want to delete this message for everyone?"
//               : "Are you sure you want to delete this message for yourself?",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text("Delete", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     try {
//       final response = await http.delete(
//         Uri.parse("${Backend.baseUrl}/messages/${message['id']}"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "userId": widget.currentUserId,
//           "deleteForEveryone": deleteForEveryone,
//         }),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           if (deleteForEveryone) {
//             messages.removeWhere((m) => m['id'] == message['id']);
//           } else {
//             int idx = messages.indexWhere((m) => m['id'] == message['id']);
//             if (idx != -1) messages[idx]['deletedForMe'] = true;
//           }
//         });

//         if (_conversationId != null) {
//           SocketManager().emit('delete_message', {
//             'conversationId': _conversationId,
//             'messageId': message['id'],
//             'deleteForEveryone': deleteForEveryone,
//           });
//         }
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Failed to delete message")));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error deleting message")));
//     }
//   }

//   void editMessageDialog(dynamic message) {
//     final editController = TextEditingController(text: message['message']);

//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: Text('Edit Message'),
//           content: TextField(controller: editController, maxLines: 5),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 final newText = editController.text.trim();
//                 if (newText.isEmpty) return;

//                 Navigator.pop(context);

//                 try {
//                   final response = await http.put(
//                     Uri.parse("${Backend.baseUrl}/messages/${message['id']}"),
//                     headers: {"Content-Type": "application/json"},
//                     body: jsonEncode({
//                       "userId": widget.currentUserId,
//                       "newMessage": newText,
//                     }),
//                   );

//                   if (response.statusCode == 200) {
//                     setState(() {
//                       int idx = messages.indexWhere(
//                         (m) => m['id'] == message['id'],
//                       );
//                       if (idx != -1) messages[idx]['message'] = newText;
//                     });

//                     if (_conversationId != null) {
//                       SocketManager().emit('edit_message', {
//                         'conversationId': _conversationId,
//                         'messageId': message['id'],
//                         'newText': newText,
//                       });
//                     }
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Failed to edit message")),
//                     );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Error editing message")),
//                   );
//                 }
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget buildMessageBubble(dynamic message) {
//     final isMe = message['sender_id'] == widget.currentUserId;
//     final messageText = message['message'] ?? '';
//     final createdAt = message['created_at'] != null
//         ? DateTime.tryParse(message['created_at'])?.toLocal()
//         : null;

//     final Color myMessageColor = MyColors.primary;
//     final Color otherMessageColor = MyColors.surface;
//     final Color myTextColor = MyColors.textPrimary;
//     final Color otherTextColor = MyColors.textPrimary;
//     final Color timeTextColor = MyColors.textSecondary;

//     final Color bubbleColor = isMe ? myMessageColor : otherMessageColor;
//     final Color textColor = isMe ? myTextColor : otherTextColor;
//     final isDeleted =
//         message['deleted_for_everyone'] == true ||
//         (message['deleted_for'] != null &&
//             (message['deleted_for'] as List).contains(widget.currentUserId));
//     final messageTextToShow = isDeleted
//         ? 'This message was deleted'
//         : (message['message'] ?? '');
//     final textColorToShow = isDeleted ? Colors.grey : textColor;

//     final BorderRadius borderRadius = BorderRadius.only(
//       topLeft: Radius.circular(isMe ? 18.0 : 4.0),
//       topRight: Radius.circular(isMe ? 4.0 : 18.0),
//       bottomLeft: const Radius.circular(18.0),
//       bottomRight: const Radius.circular(18.0),
//     );

//     return Padding(
//       padding: EdgeInsets.only(
//         top: 2,
//         bottom: 2,
//         left: isMe ? 50 : 8,
//         right: isMe ? 8 : 50,
//       ),
//       child: Row(
//         mainAxisAlignment: isMe
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Flexible(
//             child: GestureDetector(
//               onLongPress: () => handleLongPress(message),
//               child: Column(
//                 crossAxisAlignment: isMe
//                     ? CrossAxisAlignment.end
//                     : CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: bubbleColor,
//                       borderRadius: borderRadius,
//                     ),
//                     child: Text(
//                       messageTextToShow,
//                       style: TextStyle(
//                         color: textColorToShow,
//                         fontSize: 16,
//                         fontStyle: isDeleted
//                             ? FontStyle.italic
//                             : FontStyle.normal,
//                       ),
//                       softWrap: true,
//                     ),
//                   ),
//                   if (createdAt != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
//                       child: Text(
//                         "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
//                         style: TextStyle(color: timeTextColor, fontSize: 10),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget typingIndicator() {
//     return otherTyping
//         ? Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Row(
//               children: [
//                 CircleAvatar(radius: 12, child: Icon(Icons.person, size: 12)),
//                 SizedBox(width: 6),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: MyColors.surface,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     'Typing...',
//                     style: TextStyle(color: MyColors.textSecondary),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         : SizedBox.shrink();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.background,
//       appBar: AppBar(
//         backgroundColor: MyColors.surface,
//         elevation: 1,
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundImage: otherAvatar != null
//                   ? NetworkImage(otherAvatar!)
//                   : null,
//               child: otherAvatar == null
//                   ? Icon(Icons.person, color: Colors.white)
//                   : null,
//               backgroundColor: MyColors.primary,
//             ),
//             SizedBox(width: 10),
//             Flexible(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     otherName,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: MyColors.textPrimary,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     otherOnline ? 'Active' : 'Offline',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: otherOnline
//                           ? MyColors.primary
//                           : MyColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: messages.length + 1,
//               itemBuilder: (context, index) {
//                 if (index == messages.length) return typingIndicator();
//                 return buildMessageBubble(messages[index]);
//               },
//             ),
//           ),
//           SafeArea(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//               decoration: BoxDecoration(
//                 color: MyColors.surface,
//                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       minLines: 1,
//                       maxLines: 5,
//                       keyboardType: TextInputType.multiline,
//                       textInputAction: TextInputAction.newline,
//                       decoration: InputDecoration(
//                         hintText: 'Type a message...',
//                         hintStyle: TextStyle(color: MyColors.textSecondary),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide.none,
//                         ),
//                         fillColor: MyColors.inputFill,
//                         filled: true,
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       style: TextStyle(color: MyColors.textPrimary),
//                       onChanged: (_) {
//                         SocketManager().setTyping(
//                           widget.currentUserId,
//                           _controller.text.trim().isNotEmpty,
//                         );
//                         setState(() {});
//                       },
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.send,
//                       color: _controller.text.trim().isEmpty
//                           ? MyColors.textSecondary
//                           : MyColors.primary,
//                     ),
//                     onPressed: _controller.text.trim().isEmpty
//                         ? null
//                         : () => sendMessage(_controller.text),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../helpers/backend.dart';
import '../helpers/my_colors.dart';
import '../helpers/socket_manager.dart';

class ChatPage extends StatefulWidget {
  final int conversationId;
  final int currentUserId;
  final int otherUserId;

  const ChatPage({
    Key? key,
    required this.conversationId,
    required this.currentUserId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  List<dynamic> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool otherOnline = false;
  bool otherTyping = false;
  String otherName = 'Unknown';
  String? otherAvatar;
  int? _conversationId;

  StreamSubscription? _messageSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _deleteSub; ////
  StreamSubscription? _editSub;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId > 0 ? widget.conversationId : null;
    initChat();
  }

  Future<void> initChat() async {
    // 1️⃣ Agar conversation ID null hai, create ya fetch karo
    if (_conversationId == null) {
      _conversationId = await createOrFetchConversation();
      if (_conversationId == null) return; // still null, stop
      setState(() {});
    }

    // 2️⃣ Initialize socket
    await SocketManager().initSocket();
    SocketManager().joinConversation(_conversationId!, widget.currentUserId);
    // --------------- Debug: check if messages come ---------------
    SocketManager.onNewMessage.listen((data) {
      print("New message received: $data"); // ✅ yahan check hoga
    });
    // ----------------------------------------------------------------
    // 3️⃣ Listen to streams
    _messageSub = SocketManager.onNewMessage.listen((data) {
      print("New message received: $data");

      final convId = _conversationId ?? widget.conversationId;
      if (!mounted || data['conversation_id'] != convId) return;

      setState(() {
        // Check if this is a temp message you already added
        int idx = messages.indexWhere(
          (m) =>
              m['id'] == data['id'] ||
              (m['tempId'] != null && m['tempId'] == data['tempId']),
        );

        if (idx != -1) {
          // Replace temp message with real server message
          messages[idx] = data..['isNew'] = true;
        } else {
          messages.add(data..['isNew'] = true);
        }
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 50,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    _typingSub = SocketManager.onTyping.listen((data) {
  if (mounted && data['userId'] == widget.otherUserId) {
    setState(() => otherTyping = data['isTyping'] ?? false);
  }
});


    _statusSub = SocketManager.onUserStatus.listen((data) {
      if (mounted && data['userId'] == widget.otherUserId) {
        setState(() => otherOnline = data['isOnline'] ?? false);
      }
    });

    _deleteSub = SocketManager.onMessageDeleted.listen((data) {
      if (mounted) {
        setState(
          () => messages.removeWhere((m) => m['id'] == data['messageId']),
        );
      }
    });

    _editSub = SocketManager.onMessageEdited.listen((data) {
      if (!mounted) return;

      int idx = messages.indexWhere(
        (m) =>
            m['id'] == data['messageId'] ||
            (m['tempId'] != null && m['tempId'] == data['tempId']),
      );

      if (idx != -1) {
        setState(() {
          // Multiple possible keys from server
          messages[idx]['message'] =
              data['newMessage'] ??
              data['newText'] ??
              data['message'] ??
              messages[idx]['message'];
        });
      }
    });

    // 4️⃣ Fetch messages & conversation details
    await fetchConversationDetails();
    await fetchMessages();
    await markMessagesSeen();
  }

  // ✅ Conversation create/fetch logic
  Future<int?> createOrFetchConversation() async {
    try {
      final resp = await http.post(
        Uri.parse("${Backend.baseUrl}/conversations"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": widget.currentUserId,
          "provider_id": widget.otherUserId,
        }),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        return data['id'] ?? data['conversation_id'];
      }
    } catch (e) {
      print("Error creating/fetching conversation: $e");
    }
    return null;
  }

  @override
  void dispose() {
    if (_conversationId != null) {
      SocketManager().leaveConversation(_conversationId!, widget.currentUserId);
    }
    _controller.dispose();
    _scrollController.dispose();
    _messageSub?.cancel();
    _typingSub?.cancel();
    _statusSub?.cancel();
    _deleteSub?.cancel();
    _editSub?.cancel();
    super.dispose();
  }

  Future<void> markMessagesSeen() async {
    if (_conversationId == null) return;
    try {
      await http.post(
        Uri.parse("${Backend.baseUrl}/messages/mark-seen"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "conversationId": _conversationId,
          "userId": widget.currentUserId,
        }),
      );
    } catch (e) {
      print("Error marking messages as seen: $e");
    }
  }

  Future<void> fetchConversationDetails() async {
    if (_conversationId == null) return;
    try {
      final url = Uri.parse(
        "${Backend.baseUrl}/conversations/$_conversationId",
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final participants = data['participants'] as List<dynamic>? ?? [];
        final otherUser = participants.firstWhere(
          (p) => p['id'] != widget.currentUserId,
          orElse: () => null,
        );
        if (otherUser != null) {
          setState(() {
            otherName = otherUser['name'] ?? 'Unknown';
            otherAvatar =
                (otherUser['profile_image'] != null &&
                    otherUser['profile_image'].toString().isNotEmpty)
                ? "${Backend.baseUrl}/${otherUser['profile_image']}"
                : null;
            otherOnline = otherUser['is_active'] ?? false;
          });
        }
      }
    } catch (e) {
      print("Error fetching conversation details: $e");
    }
  }

  Future<void> fetchMessages() async {
    if (_conversationId == null) return;
    try {
      final url = Uri.parse(
        "${Backend.baseUrl}/messages?conversation_id=$_conversationId",
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messages = (data['messages'] as List<dynamic>? ?? [])
              .where(
                (m) =>
                    m != null && m['sender_id'] != null && m['message'] != null,
              )
              .toList();
        });
        scrollToBottom();
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 50,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    int? conversationId = _conversationId;

    if (SocketManager().socket == null || !SocketManager().socket!.connected) {
      await SocketManager().initSocket();
      if (conversationId != null) {
        SocketManager().joinConversation(conversationId, widget.currentUserId);
      }
    }

    try {
      if (conversationId == null) {
        // Create conversation if not exists
        final convResponse = await http.post(
          Uri.parse("${Backend.baseUrl}/conversations"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "user_id": widget.currentUserId,
            "provider_id": widget.otherUserId,
          }),
        );
        if (convResponse.statusCode == 200 || convResponse.statusCode == 201) {
          final convData = jsonDecode(convResponse.body);
          conversationId = convData['id'] ?? convData['conversation_id'];
          setState(() => _conversationId = conversationId);
          // Join newly created conversation
          SocketManager().joinConversation(
            conversationId!,
            widget.currentUserId,
          );
        } else
          return;
      }

      final tempId = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        messages.add({
          "id": null, // real server id will come later
          "conversation_id": conversationId,
          "sender_id": widget.currentUserId,
          "message": text.trim(),
          "created_at": DateTime.now().toIso8601String(),
          "isNew": true,
          "tempId": tempId, // track locally
        });
      });

      _controller.clear();
      scrollToBottom();

      SocketManager().sendMessage(
        conversationId,
        widget.currentUserId,
        widget.otherUserId,
        text.trim(),
        tempId,
      );
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void handleLongPress(dynamic message) {
    final createdAt = message['created_at'] != null
        ? DateTime.tryParse(message['created_at'])?.toLocal()
        : null;

    bool canDeleteForEveryone = false;

    if (createdAt != null && message['sender_id'] == widget.currentUserId) {
      final diffHours = DateTime.now().difference(createdAt).inHours;
      if (diffHours < 2) canDeleteForEveryone = true;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              if (message['sender_id'] == widget.currentUserId)
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    editMessageDialog(message);
                  },
                ),
              if (canDeleteForEveryone)
                ListTile(
                  leading: Icon(Icons.delete_forever),
                  title: Text('Delete for Everyone'),
                  onTap: () {
                    Navigator.pop(context);
                    deleteMessage(message, deleteForEveryone: true);
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete for Me'),
                onTap: () {
                  Navigator.pop(context);
                  deleteMessage(message, deleteForEveryone: false);
                },
              ),
              if (message['deleted_for_everyone'] != true)
                ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message['message']));
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
    );
  }

  Future<void> deleteMessage(
    dynamic message, {
    required bool deleteForEveryone,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Message"),
        content: Text(
          deleteForEveryone
              ? "Are you sure you want to delete this message for everyone?"
              : "Are you sure you want to delete this message for yourself?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse("${Backend.baseUrl}/messages/${message['id']}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": widget.currentUserId,
          "deleteForEveryone": deleteForEveryone,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (deleteForEveryone) {
            messages.removeWhere((m) => m['id'] == message['id']);
          } else {
            int idx = messages.indexWhere((m) => m['id'] == message['id']);
            if (idx != -1) messages[idx]['deletedForMe'] = true;
          }
        });

        if (_conversationId != null) {
          SocketManager().emit('delete_message', {
            'conversationId': _conversationId,
            'messageId': message['id'],
            'deleteForEveryone': deleteForEveryone,
            'userId': widget.currentUserId,
          });
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete message")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting message")));
    }
  }

  void editMessageDialog(dynamic message) {
    final editController = TextEditingController(text: message['message']);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(controller: editController, maxLines: 5),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newText = editController.text.trim();
                if (newText.isEmpty) return;

                Navigator.pop(context);
                // 1️⃣ Update locally immediately
                int idx = messages.indexWhere(
                  (m) =>
                      m['id'] == message['id'] ||
                      (m['tempId'] != null && m['tempId'] == message['tempId']),
                );
                if (idx != -1) {
                  setState(() {
                    messages[idx]['message'] = newText;
                  });
                }
                try {
                  final response = await http.put(
                    Uri.parse("${Backend.baseUrl}/messages/${message['id']}"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "userId": widget.currentUserId,
                      "newMessage": newText,
                    }),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      int idx = messages.indexWhere(
                        (m) =>
                            m['id'] == message['id'] ||
                            (m['tempId'] != null &&
                                m['tempId'] == message['tempId']),
                      );
                      if (idx != -1) messages[idx]['message'] = newText;
                    });

                    if (_conversationId != null) {
                      SocketManager().emit('edit_message', {
                        'conversationId': _conversationId,
                        'messageId': message['id'],
                        'newText': newText,
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to edit message")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error editing message")),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget buildMessageBubble(dynamic message) {
    final isMe = message['sender_id'] == widget.currentUserId;
    final messageText = message['message'] ?? '';
    final createdAt = message['created_at'] != null
        ? DateTime.tryParse(message['created_at'])?.toLocal()
        : null;

    final Color myMessageColor = MyColors.primary;
    final Color otherMessageColor = MyColors.surface;
    final Color myTextColor = MyColors.textPrimary;
    final Color otherTextColor = MyColors.textPrimary;
    final Color timeTextColor = MyColors.textSecondary;

    final Color bubbleColor = isMe ? myMessageColor : otherMessageColor;
    final Color textColor = isMe ? myTextColor : otherTextColor;
    final isDeleted =
        message['deleted_for_everyone'] == true ||
        (message['deleted_for'] != null &&
            (message['deleted_for'] as List).contains(widget.currentUserId));
    final messageTextToShow = isDeleted
        ? 'This message was deleted'
        : (message['message'] ?? '');
    final textColorToShow = isDeleted ? Colors.grey : textColor;

    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isMe ? 18.0 : 4.0),
      topRight: Radius.circular(isMe ? 4.0 : 18.0),
      bottomLeft: const Radius.circular(18.0),
      bottomRight: const Radius.circular(18.0),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        bottom: 2,
        left: isMe ? 50 : 8,
        right: isMe ? 8 : 50,
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: () => handleLongPress(message),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: borderRadius,
                    ),
                    child: Text(
                      messageTextToShow,
                      style: TextStyle(
                        color: textColorToShow,
                        fontSize: 16,
                        fontStyle: isDeleted
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      softWrap: true,
                    ),
                  ),
                  if (createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
                      child: Text(
                        "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(color: timeTextColor, fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget typingIndicator() {
    return otherTyping
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                CircleAvatar(radius: 12, child: Icon(Icons.person, size: 12)),
                SizedBox(width: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MyColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Typing...',
                    style: TextStyle(color: MyColors.textSecondary),
                  ),
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        backgroundColor: MyColors.surface,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: otherAvatar != null
                  ? NetworkImage(otherAvatar!)
                  : null,
              child: otherAvatar == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
              backgroundColor: MyColors.primary,
            ),
            SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    otherName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    otherOnline ? 'Active' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: otherOnline
                          ? MyColors.primary
                          : MyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == messages.length) return typingIndicator();
                return buildMessageBubble(messages[index]);
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: MyColors.surface,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: MyColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: MyColors.inputFill,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(color: MyColors.textPrimary),
                      onChanged: (_) {
                        SocketManager().setTyping(
                          widget.currentUserId,
                          _controller.text.trim().isNotEmpty,
                        );
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _controller.text.trim().isEmpty
                          ? MyColors.textSecondary
                          : MyColors.primary,
                    ),
                    onPressed: _controller.text.trim().isEmpty
                        ? null
                        : () => sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
