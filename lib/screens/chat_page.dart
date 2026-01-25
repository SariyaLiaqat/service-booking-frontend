// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import '../helpers/backend.dart';
// import '../helpers/coolors.dart';
// import '../widgets/chat_file_helper_picker.dart';
// import '../helpers/socket_manager.dart';
// import 'dart:io';
// import '../widgets/attachment_bubble.dart';

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
//   File? _selectedAttachment;
//   String? _attachmentType; // image | video | doc

//   StreamSubscription? _messageSub;
//   StreamSubscription? _typingSub;
//   StreamSubscription? _statusSub;
//   StreamSubscription? _deleteSub; ////
//   StreamSubscription? _editSub;

//   @override
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
//     // --------------- Debug: check if messages come ---------------
//     SocketManager.onNewMessage.listen((data) {
//       print("New message received: $data"); // ✅ yahan check hoga
//     });
//     // ----------------------------------------------------------------
//     // 3️⃣ Listen to streams
//     _messageSub = SocketManager.onNewMessage.listen((data) {
//       print("New message received: $data");

//       final convId = _conversationId ?? widget.conversationId;
//       if (!mounted || data['conversation_id'] != convId) return;

//       setState(() {
//         // Check if this is a temp message you already added
//         int idx = messages.indexWhere(
//           (m) =>
//               m['id'] == data['id'] ||
//               (m['tempId'] != null && m['tempId'] == data['tempId']),
//         );

//         if (idx != -1) {
//           // Replace temp message with real server message
//           messages[idx] = data..['isNew'] = true;
//         } else {
//           messages.add(data..['isNew'] = true);
//         }
//       });

//       // Scroll to bottom
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.animateTo(
//             _scrollController.position.maxScrollExtent + 50,
//             duration: Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//           );
//         }
//       });
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
//       if (mounted) {
//         setState(
//           () => messages.removeWhere((m) => m['id'] == data['messageId']),
//         );
//       }
//     });

//     _editSub = SocketManager.onMessageEdited.listen((data) {
//       if (!mounted) return;

//       int idx = messages.indexWhere(
//         (m) =>
//             m['id'] == data['messageId'] ||
//             (m['tempId'] != null && m['tempId'] == data['tempId']),
//       );

//       if (idx != -1) {
//         setState(() {
//           // Multiple possible keys from server
//           messages[idx]['message'] =
//               data['newMessage'] ??
//               data['newText'] ??
//               data['message'] ??
//               messages[idx]['message'];
//         });
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

//   void _openAttachmentSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _attachmentTile(
//                 icon: Icons.image,
//                 label: "Image",
//                 color: Colors.blue,
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final file = await ChatFileHelper.pickMedia(isVideo: false);
//                   if (file != null) {
//                     setState(() {
//                       _selectedAttachment = file;
//                       _attachmentType = "image";
//                     });
//                   }
//                 },
//               ),
//               _attachmentTile(
//                 icon: Icons.videocam,
//                 label: "Video",
//                 color: Colors.purple,
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final file = await ChatFileHelper.pickMedia(isVideo: true);
//                   if (file != null) {
//                     setState(() {
//                       _selectedAttachment = file;
//                       _attachmentType = "video";
//                     });
//                   }
//                 },
//               ),
//               _attachmentTile(
//                 icon: Icons.picture_as_pdf,
//                 label: "PDF / DOC",
//                 color: Colors.red,
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final file = await ChatFileHelper.pickDocument();
//                   if (file != null) {
//                     setState(() {
//                       _selectedAttachment = file;
//                       _attachmentType = "doc";
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
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

//     if (SocketManager().socket == null || !SocketManager().socket!.connected) {
//       await SocketManager().initSocket();
//       if (conversationId != null) {
//         SocketManager().joinConversation(conversationId, widget.currentUserId);
//       }
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
//           // Join newly created conversation
//           SocketManager().joinConversation(
//             conversationId!,
//             widget.currentUserId,
//           );
//         } else
//           return;
//       }

//       final tempId = DateTime.now().millisecondsSinceEpoch;
//       setState(() {
//         messages.add({
//           "id": null, // real server id will come later
//           "conversation_id": conversationId,
//           "sender_id": widget.currentUserId,
//           "message": text.trim(),
//           "created_at": DateTime.now().toIso8601String(),
//           "isNew": true,
//           "tempId": tempId, // track locally
//         });
//       });

//       _controller.clear();
//       scrollToBottom();

//       SocketManager().sendMessage(
//         conversationId,
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
//             'userId': widget.currentUserId,
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
//                 // 1️⃣ Update locally immediately
//                 int idx = messages.indexWhere(
//                   (m) =>
//                       m['id'] == message['id'] ||
//                       (m['tempId'] != null && m['tempId'] == message['tempId']),
//                 );
//                 if (idx != -1) {
//                   setState(() {
//                     messages[idx]['message'] = newText;
//                   });
//                 }
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
//                         (m) =>
//                             m['id'] == message['id'] ||
//                             (m['tempId'] != null &&
//                                 m['tempId'] == message['tempId']),
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
//     // 🔥 STEP-6: Attachment message check (ADD THIS)
//   if (message['type'] != null && message['type'] != 'text') {
//     return AttachmentBubble(
//       message: {
//         ...message,
//         "currentUserId": widget.currentUserId,
//       },
//     );
//   }
//     final isMe = message['sender_id'] == widget.currentUserId;
//     // final messageText = message['message'] ?? '';
//     final createdAt = message['created_at'] != null
//         ? DateTime.tryParse(message['created_at'])?.toLocal()
//         : null;

//     final Color myMessageColor = kPrimaryColor;
//     final Color otherMessageColor = kCardColor;
//     final Color myTextColor = kCardColor;
//     final Color otherTextColor = kTextPrimary;
//     final Color timeTextColor = kTextSecondary;

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
//                     color: kBackgroundColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     'Typing...',
//                     style: TextStyle(color: kTextSecondary),
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
//       backgroundColor: kBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: navbarColor,
//         // ya light variant of kPrimaryColor
//         elevation: 1,
//         titleSpacing: 0,
//         toolbarHeight: 80, // 👈 magic fix

//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(2.5),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     kPrimaryColor,
//                     kPrimaryColor,
//                   ],
//                 ),
//               ),
//               child: ClipOval(
//                 child: Container(
//                   width: 56,
//                   height: 56,
//                   color: navbarTextColor,
//                   //  color: _getColorFromName(otherName),
//                   child: (otherAvatar != null && otherAvatar!.isNotEmpty)
//                       ? Image.network(
//                           otherAvatar!,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               _buildInitialAvatar(otherName),
//                         )
//                       : _buildInitialAvatar(otherName),
//                 ),
//               ),
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
//                       color: navbarTextColor,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     otherOnline ? 'Active' : 'Offline',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: otherOnline ? kSuccessColor : kTextHint,
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
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // 🔹 Attachment Preview (conditionally)
//                 if (_selectedAttachment != null)
//                   Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: kCardColor,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: const [
//                         BoxShadow(color: Colors.black12, blurRadius: 6),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         _buildAttachmentPreview(),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             _selectedAttachment!.path.split('/').last,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(
//                             Icons.close,
//                             color: Colors.redAccent,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _selectedAttachment = null;
//                               _attachmentType = null;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),

//                 // 🔹 Input Bar
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: kCardColor,
//                     boxShadow: const [
//                       BoxShadow(color: Colors.black12, blurRadius: 3),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       // 📎 Attachment button
//                       IconButton(
//                         icon: Icon(Icons.attach_file, color: kTextSecondary),
//                         onPressed: () => _openAttachmentSheet(context),
//                       ),

//                       // 💬 TextField
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           minLines: 1,
//                           maxLines: 5,
//                           keyboardType: TextInputType.multiline,
//                           decoration: InputDecoration(
//                             hintText: 'Type a message...',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(25),
//                               borderSide: BorderSide.none,
//                             ),
//                             fillColor: kCardColor,
//                             filled: true,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                         ),
//                       ),

//                       // 🚀 Send
//                       IconButton(
//                         icon: Icon(
//                           Icons.send,
//                           color: _controller.text.trim().isEmpty
//                               ? kTextSecondary
//                               : kPrimaryColor,
//                         ),
//                         onPressed: _controller.text.trim().isEmpty
//                             ? null
//                             : () => sendMessage(_controller.text),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttachmentPreview() {
//     if (_attachmentType == "image") {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: Image.file(
//           _selectedAttachment!,
//           width: 50,
//           height: 50,
//           fit: BoxFit.cover,
//         ),
//       );
//     }

//     IconData icon = Icons.insert_drive_file;
//     Color color = Colors.orange;

//     if (_attachmentType == "video") {
//       icon = Icons.videocam;
//       color = Colors.purple;
//     } else if (_attachmentType == "doc") {
//       icon = Icons.picture_as_pdf;
//       color = Colors.red;
//     }

//     return CircleAvatar(
//       backgroundColor: color.withOpacity(0.15),
//       child: Icon(icon, color: color),
//     );
//   }

//   Widget _attachmentTile({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: color.withOpacity(0.15),
//         child: Icon(icon, color: color),
//       ),
//       title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//       onTap: onTap,
//     );
//   }

//   // Add these helper methods inside your ChatPage widget class:

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
//     return Center(
//       child: Text(
//         initial,
//         style: TextStyle(
//           color: letterColor,
//           fontWeight: FontWeight.bold,
//           fontSize: 24,
//         ),
//       ),
//     );
//   }
// }

// ////////////////////////////////
// ///
// ///

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../helpers/backend.dart';
import '../helpers/coolors.dart';
import '../widgets/chat_file_helper_picker.dart';
import '../helpers/socket_manager.dart';
import 'dart:io';
import '../widgets/attachment_bubble.dart';
//import '../models/message.dart'; // 👈 Adjust the path to where your Message class lives

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
  File? _selectedAttachment;
  String? _attachmentType; // image | video | doc
  double _uploadProgress = 0.0;
  bool _isUploading = false;

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
    _selectedAttachment = null;
    _isUploading = false;
    super.dispose();
  }

  void _openAttachmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _attachmentTile(
                icon: Icons.image,
                label: "Image",
                color: Colors.blue,
                onTap: () async {
                  Navigator.pop(context);
                  final file = await ChatFileHelper.pickMedia(isVideo: false);
                  if (file != null) {
                    setState(() {
                      _selectedAttachment = file;
                      _attachmentType = "image";
                    });
                  }
                },
              ),
              _attachmentTile(
                icon: Icons.videocam,
                label: "Video",
                color: Colors.purple,
                onTap: () async {
                  Navigator.pop(context);
                  final file = await ChatFileHelper.pickMedia(isVideo: true);
                  if (file != null) {
                    setState(() {
                      _selectedAttachment = file;
                      _attachmentType = "video";
                    });
                  }
                },
              ),
              _attachmentTile(
                icon: Icons.picture_as_pdf,
                label: "PDF / DOC",
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);
                  final file = await ChatFileHelper.pickDocument();
                  if (file != null) {
                    setState(() {
                      _selectedAttachment = file;
                      _attachmentType = "doc";
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleUploadFailure(int tempId) {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0;
      messages.removeWhere((m) => m['tempId'] == tempId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Upload failed"),
        action: SnackBarAction(
          label: "Retry",
          onPressed: () {
            sendAttachmentMessage();
          },
        ),
      ),
    );
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
                    m != null &&
                    m['sender_id'] != null &&
                    (m['message'] != null || m['type'] != null),
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

  Future<void> sendChat() async {
    String textToSend = _controller.text.trim();

    if (_selectedAttachment != null) {
      // If there is a file, use the upload function (we pass the text too!)
      await sendAttachmentMessage(textToSend);
    } else if (textToSend.isNotEmpty) {
      // If text only
      sendMessage(textToSend);
    }
  }

  // Add [String? text] here so it can accept the message
  Future<void> sendAttachmentMessage([String? text]) async {
    if (_selectedAttachment == null || _attachmentType == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;

    // Use the passed text, or the controller text, or a default string
    final String displayMsg = (text != null && text.isNotEmpty)
        ? text
        : (_controller.text.trim().isNotEmpty
              ? _controller.text.trim()
              : "Sent an attachment");

    setState(() {
      messages.add({
        "id": null,
        "tempId": tempId,
        "conversation_id": _conversationId,
        "sender_id": widget.currentUserId,
        "type": _attachmentType,
        "message": displayMsg,
        "fileUrl": _selectedAttachment!.path,
        "file": _selectedAttachment,
        "created_at": DateTime.now().toIso8601String(),
        "isNew": true,
        "status": 'sending',
      });

      _isUploading = true;
      _uploadProgress = 0;
      _controller.clear();
    });

    try {
      final uri = Uri.parse("${Backend.baseUrl}/messages/upload");
      final request = http.MultipartRequest("POST", uri);

      request.fields.addAll({
        'conversation_id': _conversationId.toString(),
        'sender_id': widget.currentUserId.toString(),
        'senderId': widget.currentUserId.toString(),
        'receiver_id': widget.otherUserId.toString(),
        'message': displayMsg, // Sending the text to DB
        'tempId': tempId.toString(),
      });

      final file = _selectedAttachment!;
      final totalBytes = await file.length();

      final stream = http.ByteStream(
        Stream.castFrom(
          file.openRead().transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) {
                sink.add(data);
                setState(() {
                  _uploadProgress += data.length / totalBytes;
                });
              },
            ),
          ),
        ),
      );

      final multipartFile = http.MultipartFile(
        'file',
        stream,
        totalBytes,
        filename: file.path.split('/').last,
      );

      request.files.add(multipartFile);

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final savedMsg = data['savedMessage'];

        // Send both text and fileUrl to Socket
        SocketManager().sendMessage(
          _conversationId!,
          widget.currentUserId,
          widget.otherUserId,
          displayMsg,
          tempId,
          type: _attachmentType,
          fileUrl: savedMsg['file_url'],
        );

        setState(() {
          final index = messages.indexWhere((m) => m['tempId'] == tempId);
          if (index != -1) {
            messages[index]['fileUrl'] = savedMsg['file_url'];
            messages[index]['status'] = 'sent';
            messages[index]['id'] = savedMsg['id'];
          }

          _selectedAttachment = null;
          _attachmentType = null;
          _uploadProgress = 0;
          _isUploading = false;
        });
        scrollToBottom();
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      _handleUploadFailure(tempId);
    }
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
    // 1️⃣ CHECK FOR ATTACHMENT
    // We check if 'type' exists and is not 'text'
    final bool hasAttachment =
        message.containsKey('type') &&
        message['type'] != null &&
        message['type'] != 'text';

    if (hasAttachment) {
      // If it has a file, we delegate EVERYTHING to AttachmentBubble.
      // This includes the 'message' field which now contains your text/caption.
      return AttachmentBubble(
        message: {...message, "currentUserId": widget.currentUserId},
      );
    }

    // 2️⃣ TEXT-ONLY LOGIC (Standard Bubble)
    final isMe = message['sender_id'] == widget.currentUserId;
    final createdAt = message['created_at'] != null
        ? DateTime.tryParse(message['created_at'])?.toLocal()
        : null;

    final Color myMessageColor = kPrimaryColor;
    final Color otherMessageColor = kCardColor;
    final Color myTextColor = kCardColor;
    final Color otherTextColor = kTextPrimary;
    final Color timeTextColor = kTextSecondary;

    final Color bubbleColor = isMe ? myMessageColor : otherMessageColor;
    final Color textColor = isMe ? myTextColor : otherTextColor;

    // Handle Deletion Logic
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
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Typing...',
                    style: TextStyle(color: kTextSecondary),
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
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: navbarColor,
        // ya light variant of kPrimaryColor
        elevation: 1,
        titleSpacing: 0,
        toolbarHeight: 80, // 👈 magic fix

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kPrimaryColor],
                ),
              ),
              child: ClipOval(
                child: Container(
                  width: 56,
                  height: 56,
                  color: navbarTextColor,
                  //  color: _getColorFromName(otherName),
                  child: (otherAvatar != null && otherAvatar!.isNotEmpty)
                      ? Image.network(
                          otherAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildInitialAvatar(otherName),
                        )
                      : _buildInitialAvatar(otherName),
                ),
              ),
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
                      color: navbarTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    otherOnline ? 'Active' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: otherOnline ? kSuccessColor : kTextHint,
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

                // 1. Safely handle the data
                final dynamic rawData = messages[index];

                // 2. Map the data to variables (Works for both local Map and Model)
                // We use '??' to check both the Model properties and Map keys
                final String? type = rawData is Map
                    ? rawData['type']
                    : (rawData.type);
                final String text = rawData is Map
                    ? (rawData['message'] ?? '')
                    : (rawData.text);
                final dynamic fileUrl = rawData is Map
                    ? (rawData['fileUrl'] ?? rawData['file_url'])
                    : (rawData.fileUrl);
                final int? senderId = rawData is Map
                    ? rawData['sender_id']
                    : (rawData.senderId);
                final dynamic msgId = rawData is Map
                    ? rawData['id']
                    : (rawData.id);

                final bool isAttachment = type != null && type != 'text';

                if (isAttachment) {
                  return AttachmentBubble(
                    message: {
                      'id': msgId,
                      'sender_id': senderId,
                      'currentUserId': widget.currentUserId,
                      'type': type,
                      'message': text,
                      'fileUrl': fileUrl,
                      // Keep local file reference if it exists in the Map
                      'file': rawData is Map ? rawData['file'] : null,
                      'status': (msgId == 0 || msgId == null)
                          ? 'sending'
                          : 'sent',
                      'created_at': rawData is Map
                          ? rawData['created_at']
                          : rawData.createdAt?.toIso8601String(),
                    },
                  );
                }

                // 3. For standard text messages
                // If rawData is already a Map, pass it. If not, wrap the values in a Map.
                return buildMessageBubble(
                  rawData is Map
                      ? rawData
                      : {
                          'id': msgId,
                          'sender_id': senderId,
                          'message': text,
                          'created_at': rawData.createdAt?.toIso8601String(),
                        },
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Attachment Preview (conditionally)
                if (_selectedAttachment != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildAttachmentPreview(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedAttachment!.path.split('/').last,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            if (_isUploading)
                              return; // prevent cancel mid-upload

                            setState(() {
                              _selectedAttachment = null;
                              _attachmentType = null;
                              _uploadProgress = 0;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                // 🔹 Input Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 3),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 📎 Attachment button
                      IconButton(
                        icon: Icon(Icons.attach_file, color: kTextSecondary),
                        onPressed: () => _openAttachmentSheet(context),
                      ),

                      // 💬 TextField
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: kCardColor,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),

                      // 🚀 Send
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: _controller.text.trim().isEmpty
                              ? kTextSecondary
                              : kPrimaryColor,
                        ),
                        onPressed:
                            (_controller.text.trim().isEmpty &&
                                _selectedAttachment == null)
                            ? null
                            : () => sendChat(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    if (_attachmentType == "image") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 120, maxHeight: 120),
          child: Image.file(
            _selectedAttachment!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    IconData icon = Icons.insert_drive_file;
    Color color = Colors.orange;

    if (_attachmentType == "video") {
      icon = Icons.videocam;
      color = Colors.purple;
    } else if (_attachmentType == "doc") {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.15),
      child: Icon(icon, color: color),
    );
  }

  Widget _attachmentTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  // Add these helper methods inside your ChatPage widget class:

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
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: letterColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}



















// “Main aik service-based app bana rahi hoon, Fiverr jaisi.
// International payments ke liye Stripe chahiye hota hai, jo Pakistan mein direct available nahi.
// Is liye mujhe bahir ka Stripe account chahiye hoga.
// Account aapke naam pe hoga, lekin app aur business mera hoga.
// Main aapko full transparency aur security ke sath handle karungi.”