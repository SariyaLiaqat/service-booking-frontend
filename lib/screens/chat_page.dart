



// //////////////////////////////

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../helpers/backend.dart';
// import 'package:http/http.dart' as http;

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
//   late IO.Socket socket;
//   bool otherOnline = false;
//   bool otherTyping = false;
//   String otherName = 'Unknown';
//   String? otherAvatar;
//   int? _conversationId;

//   @override
//   void initState() {
//     super.initState();
//     _conversationId = widget.conversationId > 0 ? widget.conversationId : null;
//     initSocket();
//     fetchConversationDetails();
//     if (_conversationId != null) fetchMessages();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     socket.dispose();
//     super.dispose();
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
//         Timer(Duration(seconds: 2), () {
//           setState(() {
//             int idx = messages.indexWhere((m) => m['id'] == data['id']);
//             if (idx != -1) messages[idx]['isNew'] = false;
//           });
//         });
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

//   Widget buildMessageBubble(dynamic message) {
//     final isMe = message['sender_id'] == widget.currentUserId;
//     final messageText = message['message'] ?? '';
//     final createdAt = message['created_at'] != null
//         ? DateTime.tryParse(message['created_at'])?.toLocal()
//         : null;
//     final senderName = isMe ? 'You' : otherName;
//     final senderAvatar = isMe ? null : otherAvatar;
//     final isNew = message['isNew'] ?? false;

//     return GestureDetector(
//       onLongPress: () => handleLongPress(message),
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         margin: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//           children: [
//             if (!isMe)
//               Padding(
//                 padding: const EdgeInsets.only(right: 8.0),
//                 child: CircleAvatar(
//                   radius: 16,
//                   backgroundImage: senderAvatar != null ? NetworkImage(senderAvatar) : null,
//                   child: senderAvatar == null ? Icon(Icons.person, size: 18) : null,
//                 ),
//               ),
//             Flexible(
//               child: Column(
//                 crossAxisAlignment:
//                     isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                 children: [
//                   if (!isMe)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 2.0),
//                       child: Text(senderName,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                               color: Color(0xFF0A66C2),)),
//                     ),
//                  Container(
//   padding: const EdgeInsets.all(10),
//   margin: EdgeInsets.only(left: isMe ? 50 : 0, right: isMe ? 0 : 50),
//   decoration: BoxDecoration(
//     color: isNew
//         ? Color(0xFF5C74B1).withOpacity(0.2) // soft blue highlight
//         : isMe
//             ? Color(0xFF2A3A69) // my msg dark blue
//             : Colors.white, // others white
//     borderRadius: BorderRadius.circular(12),
//   ),
//   child: Column(
//     crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//     children: [
//       Text(
//         messageText,
//         style: TextStyle(
//           color: isMe ? Colors.white : Color(0xFF2A3A69), // contrast
//           fontSize: 16,
//         ),
//         softWrap: true,
//       ),
//       if (createdAt != null)
//         Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Text(
//             "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
//             style: TextStyle(
//               color: isMe ? Colors.white70 : Color(0xFF5C74B1),
//               fontSize: 10,
//             ),
//           ),
//         ),
//     ],
//   ),
// ),

//                 ],
//               ),
//             ),
//             if (isMe) SizedBox(width: 8),
//           ],
//         ),
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
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text('Typing...'),
//                 ),
//               ],
//             ),
//           )
//         : SizedBox.shrink();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFD9E1F0),
//       appBar: AppBar(
//   backgroundColor:  Color(0xFF0A66C2), // Dark blue
//   elevation: 1,
//   titleSpacing: 0,
//   title: Row(
//     children: [
//       CircleAvatar(
//         radius: 20,
//         backgroundImage: otherAvatar != null ? NetworkImage(otherAvatar!) : null,
//         child: otherAvatar == null ? Icon(Icons.person, color: Colors.white) : null,
//         backgroundColor: Color(0xFF5C74B1), // soft blue if no image
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
//                 color: Colors.white, // white text on dark bar
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//             Text(
//               otherOnline ? 'Online' : 'Offline',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: otherOnline ? Colors.green : Colors.grey[300],
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
//       color: Colors.white,
//       boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
//     ),
//     child: Row(
//       children: [
//         Expanded(
//           child: TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               hintText: 'Type a message...',
//               hintStyle: TextStyle(color: Color(0xFF5C74B1)),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide.none,
//               ),
//               fillColor: Color(0xFFD9E1F0), // soft light blue
//               filled: true,
//               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//             ),
//             style: TextStyle(color: Color(0xFF2A3A69)),
//             onChanged: (_) {
//               socket.emit('typing', {
//                 'userId': widget.currentUserId,
//                 'isTyping': _controller.text.trim().isNotEmpty,
//               });
//               setState(() {});
//             },
//           ),
//         ),
//         IconButton(
//           icon: Icon(
//             Icons.send,
//             color: _controller.text.trim().isEmpty
//                 ? Colors.grey
//                 :  Color(0xFF0A66C2), // send button dark blue
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









//////////////////////////////

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../helpers/backend.dart';
import 'package:http/http.dart' as http;

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
  late IO.Socket socket;
  bool otherOnline = false;
  bool otherTyping = false;
  String otherName = 'Unknown';
  String? otherAvatar;
  int? _conversationId;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId > 0 ? widget.conversationId : null;
    initSocket();
    fetchConversationDetails();
    if (_conversationId != null) fetchMessages();
     markMessagesSeen(); 
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    socket.dispose();
    super.dispose();
  }

  void initSocket() {
    socket = IO.io(
      Backend.baseUrl,
      <String, dynamic>{'transports': ['websocket'], 'autoConnect': true},
    );
    socket.connect();

    socket.onConnect((_) {
      if (_conversationId != null) {
        socket.emit('join_conversation', [_conversationId, widget.currentUserId]);
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
      if (data['sender_id'] != widget.currentUserId) {
        // Timer(Duration(seconds: 2), () {
        //   setState(() {
        //     int idx = messages.indexWhere((m) => m['id'] == data['id']);
        //     if (idx != -1) messages[idx]['isNew'] = false;
        //   });
        // });
      }
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
      if (_conversationId != null && data['conversation_id'] == _conversationId) {
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

   setState(() {
  for (var m in messages) {
    if (m['sender_id'] != widget.currentUserId) {
      // Messages from other user seen by me
      m['isNew'] = false;   // stop highlighting red
    } else {
      // My sent messages seen by other user → green
      m['hasBeenSeen'] = true;
    }
  }
});

// Emit socket event so sender sees green in real-time
socket.emit('message_seen', {
  "conversationId": _conversationId,
  "userId": widget.currentUserId,
  "messageIds": messages
      .where((m) => m['sender_id'] == widget.currentUserId)
      .map((m) => m['id'])
      .toList(),
});

  } catch (e) {
    print("Error marking messages as seen: $e");
  }
}





  Future<void> fetchConversationDetails() async {
    if (_conversationId == null) return;
    try {
      final url = Uri.parse("${Backend.baseUrl}/conversations/$_conversationId");
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
            otherAvatar = (otherUser['profile_image'] != null &&
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
      final url = Uri.parse("${Backend.baseUrl}/messages?conversation_id=$_conversationId");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messages = (data['messages'] as List<dynamic>? ?? [])
              .where((m) => m != null && m['sender_id'] != null && m['message'] != null)
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
          socket.emit('join_conversation', [conversationId, widget.currentUserId]);
        } else return;
      }

      final tempId = DateTime.now().millisecondsSinceEpoch;

     setState(() {
  messages.add({
    "id": tempId,
    "conversation_id": conversationId,
    "sender_id": widget.currentUserId,
    "message": text.trim(),
    "created_at": DateTime.now().toIso8601String(),
    "isNew": true,         // for receiver highlighting
    "hasBeenSeen": false,  // ✅ important for red → green logic
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
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Message copied')));
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
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
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
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
                child: Text('Save')),
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
  final senderName = isMe ? 'You' : otherName;
  final senderAvatar = isMe ? null : otherAvatar;
  final isNew = message['isNew'] ?? false;
  final hasBeenSeen = message['hasBeenSeen'] ?? false; // ✅ server ya socket me set hona chahiye

  // -------------------- Bubble color logic --------------------
  Color bubbleColor;

if (isMe) {
  // My sent messages
  if (!hasBeenSeen) {
    bubbleColor = Colors.red.withOpacity(0.2); // not yet seen by receiver
  } else {
    bubbleColor = Colors.green.withOpacity(0.2); // seen by receiver
  }
} else {
  // Messages I received
  if (isNew) {
    bubbleColor = Colors.red.withOpacity(0.2); // unread
  } else {
    bubbleColor = Colors.white; // read
  }
}



  final textColor = isMe ? Colors.white : Color(0xFF2A3A69);


  return GestureDetector(
    onLongPress: () => handleLongPress(message),
    child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: senderAvatar != null ? NetworkImage(senderAvatar) : null,
                child: senderAvatar == null ? Icon(Icons.person, size: 18) : null,
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: isMe ? 50 : 0, right: isMe ? 0 : 50),
                  decoration: BoxDecoration(
                    color: bubbleColor, // ✅ updated
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        messageText,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                        softWrap: true,
                      ),
                      if (createdAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              color: isMe ? Colors.white70 : Color(0xFF5C74B1),
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) SizedBox(width: 8),
        ],
      ),
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Typing...'),
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD9E1F0),
      appBar: AppBar(
  backgroundColor:  Color(0xFF0A66C2), // Dark blue
  elevation: 1,
  titleSpacing: 0,
  title: Row(
    children: [
      CircleAvatar(
        radius: 20,
        backgroundImage: otherAvatar != null ? NetworkImage(otherAvatar!) : null,
        child: otherAvatar == null ? Icon(Icons.person, color: Colors.white) : null,
        backgroundColor: Color(0xFF5C74B1), // soft blue if no image
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
                color: Colors.white, // white text on dark bar
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              otherOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                color: otherOnline ? Colors.green : Colors.grey[300],
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
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              hintStyle: TextStyle(color: Color(0xFF5C74B1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              fillColor: Color(0xFFD9E1F0), // soft light blue
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            style: TextStyle(color: Color(0xFF2A3A69)),
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
                ? Colors.grey
                :  Color(0xFF0A66C2), // send button dark blue
          ),
          onPressed: _controller.text.trim().isEmpty
              ? null
              : () => sendMessage(_controller.text),
        ),
      ],
    ),
  ),
         )]
      )
         );
  }
}
