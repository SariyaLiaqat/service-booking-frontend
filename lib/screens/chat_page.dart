// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../helpers/backend.dart';
// import 'package:http/http.dart' as http;
// import '../helpers/my_colors.dart';
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

// class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin , WidgetsBindingObserver{
//   List<dynamic> messages = [];
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   late IO.Socket socket;
//   bool otherOnline = false;
//   bool otherTyping = false;
//   String otherName = 'Unknown';
//   String? otherAvatar;
//   int? _conversationId;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _conversationId = widget.conversationId > 0 ? widget.conversationId : null;
//     initSocket();
//     fetchConversationDetails();
//     if (_conversationId != null) fetchMessages();
//      markMessagesSeen();
//   }

//   @override
//   void dispose() {
//     socket.disconnect();
//     _controller.dispose();
//     _scrollController.dispose();
//     socket.dispose();
//     super.dispose();
//   }
// //-------------

// @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
//       // App background me chali gayi
//       socket.emit('user_offline', widget.currentUserId);
//       socket.disconnect();
//     } else if (state == AppLifecycleState.resumed) {
//       // App foreground me aayi
//       socket.connect();
//       socket.emit('user_online', widget.currentUserId);
//     }
//   }

//   void initSocket() {
//     socket = IO.io(
//       Backend.baseUrl,
//       <String, dynamic>{'transports': ['websocket'], 'autoConnect': true},
//     );
//     socket.connect();

//     socket.onConnect((_) {
//       if (_conversationId != null) {
//         socket.emit('join_conversation', [_conversationId, widget.currentUserId]);
//       }
//       socket.emit('user_online', widget.currentUserId);
//     });
// socket.on('message_seen', (data) {
//   final msgId = data['messageId'];
//   setState(() {
//     int idx = messages.indexWhere((m) => m['id'] == msgId);
//     if (idx != -1) messages[idx]['hasBeenSeen'] = true;
//   });
// });

//     // New message listener
//     socket.on('new_message', (data) {
//       final tempId = data['tempId'];
//       setState(() {
//         if (tempId != null) {
//           int index = messages.indexWhere((m) => m['id'] == tempId);
//           if (index != -1) {
//             messages[index] = data;
//             return;
//           }
//         }
//         final exists = messages.any((m) => m['id'] == data['id']);
//         if (!exists) messages.add(data..['isNew'] = true);
//       });
//       scrollToBottom();
//       // Auto remove new highlight after 2 seconds
//       if (data['sender_id'] != widget.currentUserId) {

//       }
//     });

//     // Message deleted
//     socket.on('message_deleted', (data) {
//       setState(() => messages.removeWhere((m) => m['id'] == data['messageId']));
//     });

//     // Message edited
//     socket.on('message_edited', (data) {
//       setState(() {
//         int idx = messages.indexWhere((m) => m['id'] == data['messageId']);
//         if (idx != -1) messages[idx]['message'] = data['newText'];
//       });
//     });

//     // User online/offline
//     socket.on('user_status_change', (data) {
//       if (data['userId'] == widget.otherUserId) {
//         setState(() => otherOnline = data['isOnline'] ?? false);
//       }
//     });

//     // Typing indicator
//     socket.on('user_typing', (data) {
//       if (data['userId'] == widget.otherUserId) {
//         setState(() => otherTyping = data['isTyping'] ?? false);
//       }
//     });

//     // Seen/unseen count reset
//     socket.on('update_conversation_list', (data) {
//       if (_conversationId != null && data['conversation_id'] == _conversationId) {
//         setState(() {
//           // no local badge shown in chat page, handled in dashboard
//         });
//       }
//     });
//   }

// Future<void> markMessagesSeen() async {
//   if (_conversationId == null) return;

//   try {
//     await http.post(
//       Uri.parse("${Backend.baseUrl}/messages/mark-seen"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "conversationId": _conversationId,
//         "userId": widget.currentUserId,
//       }),
//     );

//    setState(() {});

//   } catch (e) {
//     print("Error marking messages as seen: $e");
//   }
// }
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
//             otherAvatar = (otherUser['profile_image'] != null &&
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

//   Future<void> sendMessage(String text) async {
//     if (text.trim().isEmpty) return;
//     int? conversationId = _conversationId;
//     try {
//       if (conversationId == null) {
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
//           socket.emit('join_conversation', [conversationId, widget.currentUserId]);
//         } else return;
//       }

//       final tempId = DateTime.now().millisecondsSinceEpoch;

//      setState(() {
//   messages.add({
//     "id": tempId,
//     "conversation_id": conversationId,
//     "sender_id": widget.currentUserId,
//     "message": text.trim(),
//     "created_at": DateTime.now().toIso8601String(),
//   });
// });

//       socket.emit('send_message', {
//         "conversationId": conversationId,
//         "senderId": widget.currentUserId,
//         "receiverId": widget.otherUserId,
//         "message": text.trim(),
//         "tempId": tempId,
//       });

//       _controller.clear();
//       scrollToBottom();
//     } catch (e) {
//       print("Error sending message: $e");
//     }
//   }

//   void handleLongPress(dynamic message) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: Icon(Icons.edit),
//                 title: Text('Edit'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   editMessageDialog(message);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.delete),
//                 title: Text('Delete'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   deleteMessage(message);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.copy),
//                 title: Text('Copy'),
//                 onTap: () {
//                   Clipboard.setData(ClipboardData(text: message['message']));
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context)
//                       .showSnackBar(SnackBar(content: Text('Message copied')));
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void deleteMessage(dynamic message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Delete Message"),
//         content: Text("Are you sure you want to delete this message?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               if (_conversationId != null) {
//                 socket.emit('delete_message', {
//                   'messageId': message['id'],
//                   'conversationId': _conversationId,
//                 });
//               }
//               Navigator.pop(context);
//             },
//             child: Text("Delete", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void editMessageDialog(dynamic message) {
//     final editController = TextEditingController(text: message['message']);
//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: Text('Edit Message'),
//           content: TextField(controller: editController),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
//             TextButton(
//                 onPressed: () {
//                   if (_conversationId != null) {
//                     socket.emit('edit_message', {
//                       'messageId': message['id'],
//                       'conversationId': _conversationId,
//                       'newText': editController.text.trim(),
//                     });
//                   }
//                   Navigator.pop(context);
//                 },
//                 child: Text('Save')),
//           ],
//         );
//       },
//     );
//   }

// // ... inside _ChatPageState ...

// Widget buildMessageBubble(dynamic message) {
//   final isMe = message['sender_id'] == widget.currentUserId;
//   final messageText = message['message'] ?? '';
//   final createdAt = message['created_at'] != null
//       ? DateTime.tryParse(message['created_at'])?.toLocal()
//       : null;
//  // final hasBeenSeen = message['hasBeenSeen'] ?? false;

//   // --- Define Colors based on the Instagram Dark Theme image ---
//   final Color myMessageColor = MyColors.primary; // your elegant indigo or gold tone
// final Color otherMessageColor = MyColors.surface; // dark background for received messages
// final Color myTextColor = MyColors.textPrimary;
// final Color otherTextColor = MyColors.textPrimary;
// final Color timeTextColor = MyColors.textSecondary;

//   // --- Determine final colors ---
//   final Color bubbleColor = isMe ? myMessageColor : otherMessageColor;
//   final Color textColor = isMe ? myTextColor : otherTextColor;

//   // --- Define Border Radius for the Bubble ---
//   final BorderRadius borderRadius = BorderRadius.only(
//     // Top-left corner: Always curved, unless it's the very first message
//     topLeft: Radius.circular(isMe ? 18.0 : 4.0),
//     // Top-right corner: Always curved, unless it's the very first message
//     topRight: Radius.circular(isMe ? 4.0 : 18.0),
//     // Bottom-left corner: Always curved
//     bottomLeft: const Radius.circular(18.0),
//     // Bottom-right corner: Always curved
//     bottomRight: const Radius.circular(18.0),
//   );

//   return Padding(
//     padding: EdgeInsets.only(
//       top: 2,
//       bottom: 2,
//       left: isMe ? 50 : 8, // My message: pushed left
//       right: isMe ? 8 : 50, // Other message: pushed right
//     ),
//     child: Row(
//       // Align message to the start (other) or end (me)
//       mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.end, // Align time to the bottom of the bubble
//       children: [
//         Flexible(
//           child: Column(
//             crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//             children: [
//               // Message Bubble Container
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: bubbleColor,
//                   borderRadius: borderRadius,

//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Message Text
//                     Text(
//                       messageText,
//                       style: TextStyle(
//                         color: textColor,
//                         fontSize: 16,
//                       ),
//                       softWrap: true,
//                     ),
//                   ],
//                 ),
//               ),

//               // Time and Seen Status
//               if (createdAt != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         // Format time as H:MM
//                         "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
//                         style: TextStyle(
//                           color: timeTextColor,
//                           fontSize: 10,
//                         ),
//                       ),
//             ],
//           ),
//         ),
//       ],
//     ),
//         ),
//       ]
//     )
//   );
// }

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
//                   child: Text('Typing...', style: TextStyle(color: MyColors.textSecondary)),
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
//   backgroundColor: MyColors.surface,

//   elevation: 1,
//   titleSpacing: 0,
//   title: Row(
//     children: [
//       CircleAvatar(
//         radius: 20,
//         backgroundImage: otherAvatar != null ? NetworkImage(otherAvatar!) : null,
//         child: otherAvatar == null ? Icon(Icons.person, color: Colors.white) : null,
//         backgroundColor: MyColors.primary, // soft blue if no image
//       ),
//       SizedBox(width: 10),
//       Flexible(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               otherName,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: MyColors.textPrimary,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//             Text(
//               otherOnline ? 'Active' : 'Offline',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: otherOnline ? MyColors.primary : MyColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// ),

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

//          SafeArea(
//   child: Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//     decoration: BoxDecoration(
//       color: MyColors.surface,

//       boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
//     ),
//     child: Row(
//       children: [
//        Expanded(
//   child: TextField(
//     controller: _controller,
//     minLines: 1, // start with one line
//     maxLines: 5, // expand up to 5 lines as user types
//     keyboardType: TextInputType.multiline, // enable multiline typing
//     textInputAction: TextInputAction.newline, // Enter adds new line
//     decoration: InputDecoration(
//       hintText: 'Type a message...',
//       hintStyle: TextStyle(color: MyColors.textSecondary),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(25),
//         borderSide: BorderSide.none,
//       ),
//       fillColor: MyColors.inputFill,
//       filled: true,
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     ),
//    style: TextStyle(color: MyColors.textPrimary),
//     onChanged: (_) {
//       socket.emit('typing', {
//         'userId': widget.currentUserId,
//         'isTyping': _controller.text.trim().isNotEmpty,
//       });
//       setState(() {});
//     },
//   ),
// ),

//         IconButton(
//           icon: Icon(
//             Icons.send,
//             color: _controller.text.trim().isEmpty
//     ? MyColors.textSecondary
//     : MyColors.primary,

//           ),
//           onPressed: _controller.text.trim().isEmpty
//               ? null
//               : () => sendMessage(_controller.text),
//         ),
//       ],
//     ),
//   ),
//          )]
//       )
//          );
//   }
// }





import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../helpers/backend.dart';
import 'package:http/http.dart' as http;
import '../helpers/my_colors.dart';

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

class _ChatPageState extends State<ChatPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List<dynamic> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late IO.Socket socket;
  bool otherOnline = false;
  bool otherTyping = false;
  String otherName = 'Unknown';
  String? otherAvatar;
  int? _conversationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _conversationId = widget.conversationId > 0 ? widget.conversationId : null;
    initSocket();
    fetchConversationDetails();
    if (_conversationId != null) fetchMessages();
    markMessagesSeen();

    if (_conversationId != null) {
      socket.emit('open_chat', {
        'conversationId': _conversationId,
        'userId': widget.currentUserId,
      });
    }
  }

  @override
  void dispose() {
    if (_conversationId != null) {
    socket.emit('close_chat', {
      'conversationId': _conversationId,
      'userId': widget.currentUserId,
    });
  }
    socket.disconnect();
    _controller.dispose();
    _scrollController.dispose();
    socket.dispose();
    super.dispose();
  }
  //-------------

  @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
    if (_conversationId != null) {
      socket.emit('close_chat', {
        'conversationId': _conversationId,
        'userId': widget.currentUserId,
      });
    }
    socket.disconnect();
  } else if (state == AppLifecycleState.resumed) {
    socket.connect();
    socket.emit('user_online', widget.currentUserId);
    if (_conversationId != null) {
      socket.emit('open_chat', {
        'conversationId': _conversationId,
        'userId': widget.currentUserId,
      });
    }
  }
}


  void initSocket() {
    socket = IO.io(Backend.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();

    socket.onConnect((_) {
      if (_conversationId != null) {
        socket.emit('join_conversation', [
          _conversationId,
          widget.currentUserId,
        ]);
      }
      socket.emit('user_online', widget.currentUserId);
    });
    socket.on('message_seen', (data) {
      final msgId = data['messageId'];
      setState(() {
        int idx = messages.indexWhere((m) => m['id'] == msgId);
        if (idx != -1) messages[idx]['hasBeenSeen'] = true;
      });
    });
//------------------------------------update active status
socket.on('update_active_status', (data) {
  if (data['userId'] == widget.otherUserId) {
    setState(() => otherOnline = data['isActive'] ?? false);
  }
});

    // New message listener
    socket.on('new_message', (data) {
      final tempId = data['tempId'];
      setState(() {
        if (tempId != null) {
          int index = messages.indexWhere((m) => m['id'] == tempId);
          if (index != -1) {
            messages[index] = data;
            return;
          }
        }
        final exists = messages.any((m) => m['id'] == data['id']);
        if (!exists) messages.add(data..['isNew'] = true);
      });
      scrollToBottom();
      // Auto remove new highlight after 2 seconds
      if (data['sender_id'] != widget.currentUserId) {}
    });

    // Message deleted
    socket.on('message_deleted', (data) {
      setState(() => messages.removeWhere((m) => m['id'] == data['messageId']));
    });

    // Message edited
    socket.on('message_edited', (data) {
      setState(() {
        int idx = messages.indexWhere((m) => m['id'] == data['messageId']);
        if (idx != -1) messages[idx]['message'] = data['newText'];
      });
    });

    // User online/offline
    socket.on('user_status_change', (data) {
      if (data['userId'] == widget.otherUserId) {
        setState(() => otherOnline = data['isOnline'] ?? false);
      }
    });

    // Typing indicator
    socket.on('user_typing', (data) {
      if (data['userId'] == widget.otherUserId) {
        setState(() => otherTyping = data['isTyping'] ?? false);
      }
    });

    // Seen/unseen count reset
    socket.on('update_conversation_list', (data) {
      if (_conversationId != null &&
          data['conversation_id'] == _conversationId) {
        setState(() {
          // no local badge shown in chat page, handled in dashboard
        });
      }
    });
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

      setState(() {});
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
    try {
      if (conversationId == null) {
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
          socket.emit('join_conversation', [
            conversationId,
            widget.currentUserId,
          ]);
        } else
          return;
      }

      final tempId = DateTime.now().millisecondsSinceEpoch;

      setState(() {
        messages.add({
          "id": tempId,
          "conversation_id": conversationId,
          "sender_id": widget.currentUserId,
          "message": text.trim(),
          "created_at": DateTime.now().toIso8601String(),
        });
      });

      socket.emit('send_message', {
        "conversationId": conversationId,
        "senderId": widget.currentUserId,
        "receiverId": widget.otherUserId,
        "message": text.trim(),
        "tempId": tempId,
      });

      _controller.clear();
      scrollToBottom();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void handleLongPress(dynamic message) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  editMessageDialog(message);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  deleteMessage(message);
                },
              ),
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

  void deleteMessage(dynamic message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Message"),
        content: Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (_conversationId != null) {
                socket.emit('delete_message', {
                  'messageId': message['id'],
                  'conversationId': _conversationId,
                });
              }
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void editMessageDialog(dynamic message) {
    final editController = TextEditingController(text: message['message']);
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(controller: editController),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_conversationId != null) {
                  socket.emit('edit_message', {
                    'messageId': message['id'],
                    'conversationId': _conversationId,
                    'newText': editController.text.trim(),
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ... inside _ChatPageState ...

  Widget buildMessageBubble(dynamic message) {
    final isMe = message['sender_id'] == widget.currentUserId;
    final messageText = message['message'] ?? '';
    final createdAt = message['created_at'] != null
        ? DateTime.tryParse(message['created_at'])?.toLocal()
        : null;
    // final hasBeenSeen = message['hasBeenSeen'] ?? false;

    // --- Define Colors based on the Instagram Dark Theme image ---
    final Color myMessageColor =
        MyColors.primary; // your elegant indigo or gold tone
    final Color otherMessageColor =
        MyColors.surface; // dark background for received messages
    final Color myTextColor = MyColors.textPrimary;
    final Color otherTextColor = MyColors.textPrimary;
    final Color timeTextColor = MyColors.textSecondary;

    // --- Determine final colors ---
    final Color bubbleColor = isMe ? myMessageColor : otherMessageColor;
    final Color textColor = isMe ? myTextColor : otherTextColor;

    // --- Define Border Radius for the Bubble ---
    final BorderRadius borderRadius = BorderRadius.only(
      // Top-left corner: Always curved, unless it's the very first message
      topLeft: Radius.circular(isMe ? 18.0 : 4.0),
      // Top-right corner: Always curved, unless it's the very first message
      topRight: Radius.circular(isMe ? 4.0 : 18.0),
      // Bottom-left corner: Always curved
      bottomLeft: const Radius.circular(18.0),
      // Bottom-right corner: Always curved
      bottomRight: const Radius.circular(18.0),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        bottom: 2,
        left: isMe ? 50 : 8, // My message: pushed left
        right: isMe ? 8 : 50, // Other message: pushed right
      ),
      child: Row(
        // Align message to the start (other) or end (me)
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.end, // Align time to the bottom of the bubble
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Message Bubble Container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: borderRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Message Text
                      Text(
                        messageText,
                        style: TextStyle(color: textColor, fontSize: 16),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),

                // Time and Seen Status
                if (createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // Format time as H:MM
                          "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(color: timeTextColor, fontSize: 10),
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
              backgroundColor: MyColors.primary, // soft blue if no image
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
                      minLines: 1, // start with one line
                      maxLines: 5, // expand up to 5 lines as user types
                      keyboardType:
                          TextInputType.multiline, // enable multiline typing
                      textInputAction:
                          TextInputAction.newline, // Enter adds new line
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
                        socket.emit('typing', {
                          'userId': widget.currentUserId,
                          'isTyping': _controller.text.trim().isNotEmpty,
                        });
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
