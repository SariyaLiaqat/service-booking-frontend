// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import '../helpers/backend.dart';
// // import 'chat_page.dart';

// // class MessagesPage extends StatefulWidget {
// //   final int currentUserId;

// //   const MessagesPage({Key? key, required this.currentUserId}) : super(key: key);

// //   @override
// //   _MessagesPageState createState() => _MessagesPageState();
// // }

// // class _MessagesPageState extends State<MessagesPage> {
// //   bool isLoading = true;
// //   List<dynamic> conversations = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchConversations();
// //   }

// //   Future<void> fetchConversations() async {
// //     setState(() => isLoading = true);
// //     try {
// //       final url = Uri.parse("${Backend.baseUrl}/conversations?user_id=${widget.currentUserId}");
// //       final response = await http.get(url);

// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         setState(() {
// //           conversations = (data['conversations'] as List<dynamic>?) ?? [];
// //         });
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Failed to load conversations [${response.statusCode}]')),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error loading conversations: $e')),
// //       );
// //     } finally {
// //       setState(() => isLoading = false);
// //     }
// //   }

// //   Widget buildConversationCard(dynamic convo) {
// //     final providerName = convo['provider_name'] ?? 'Provider';
// //     final lastMessage = convo['last_message'] ?? '';
// //     final createdAt = convo['last_message_time'] != null
// //         ? DateTime.tryParse(convo['last_message_time'])?.toLocal()
// //         : null;

// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// //       child: ListTile(
// //         leading: CircleAvatar(
// //           backgroundImage: convo['provider_image'] != null
// //               ? NetworkImage(convo['provider_image'])
// //               : null,
// //           child: convo['provider_image'] == null ? Icon(Icons.person) : null,
// //         ),
// //         title: Text(providerName),
// //         subtitle: Text(lastMessage),
// //         trailing: createdAt != null
// //             ? Text(
// //                 "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
// //                 style: TextStyle(fontSize: 12, color: Colors.grey),
// //               )
// //             : null,
// //         onTap: () {
// //           // Open chat page
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (_) => ChatPage(
// //                 conversationId: convo['id'],
// //                 currentUserId: widget.currentUserId,
// //                 receiverName: providerName,
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: isLoading
// //           ? Center(child: CircularProgressIndicator())
// //           : conversations.isEmpty
// //               ? Center(child: Text('No conversations yet'))
// //               : RefreshIndicator(
// //                   onRefresh: fetchConversations,
// //                   child: ListView.builder(
// //                     itemCount: conversations.length,
// //                     itemBuilder: (context, index) =>
// //                         buildConversationCard(conversations[index]),
// //                   ),
// //                 ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
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

//   @override
//   void initState() {
//     super.initState();
//     fetchConversations();
//   }

//   Future<void> fetchConversations() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations?user_id=${widget.currentUserId}");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           conversations = (data['conversations'] as List<dynamic>?) ?? [];
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load conversations')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<int> openOrCreateConversation(int providerId) async {
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations");
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "user_id": widget.currentUserId,
//           "provider_id": providerId,
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         return data['conversation_id'];
//       } else {
//         throw Exception('Failed to create/open conversation');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//       rethrow;
//     }
//   }

//   Widget buildConversationCard(dynamic convo) {
//     final isUser = convo['user_id'] == widget.currentUserId;
//     final otherName = isUser ? convo['provider_name'] : convo['user_name'];
//     final avatarUrl = isUser ? convo['provider_avatar'] : convo['user_avatar'];

//     final lastMessage = convo['last_message'] ?? '';
//     final createdAt = convo['last_message_time'] != null
//         ? DateTime.tryParse(convo['last_message_time'])?.toLocal()
//         : null;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
//           child: avatarUrl == null ? Icon(Icons.person) : null,
//         ),
//         title: Text(otherName ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
//         trailing: createdAt != null
//             ? Text(
//                 "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               )
//             : null,
//         onTap: () async {
//           final convoId = await openOrCreateConversation(
//               isUser ? convo['provider_id'] : convo['user_id']);
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ChatPage(
//                 conversationId: convoId,
//                 currentUserId: widget.currentUserId,
//                 receiverName: otherName ?? 'Unknown',
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Messages')),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : conversations.isEmpty
//               ? Center(child: Text('No conversations yet'))
//               : RefreshIndicator(
//                   onRefresh: fetchConversations,
//                   child: ListView.builder(
//                     itemCount: conversations.length,
//                     itemBuilder: (context, index) =>
//                         buildConversationCard(conversations[index]),
//                   ),
//                 ),
//     );
//   }
// }

/////////////////////////////////////////////


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
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

//   @override
//   void initState() {
//     super.initState();
//     fetchConversations();
//   }

//   Future<void> fetchConversations() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations?user_id=${widget.currentUserId}");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           conversations = (data['conversations'] as List<dynamic>?) ?? [];
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load conversations')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<int> openOrCreateConversation(int providerId) async {
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations");
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "user_id": widget.currentUserId,
//           "provider_id": providerId,
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         return data['conversation_id'];
//       } else {
//         throw Exception('Failed to create/open conversation');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//       rethrow;
//     }
//   }

//   Widget buildConversationCard(dynamic convo) {
//     final isUser = convo['user_id'] == widget.currentUserId;
//     final otherName = isUser ? convo['provider_name'] : convo['user_name'];
//     final avatarUrl = isUser ? convo['provider_avatar'] : convo['user_avatar'];

//     // Online / Last seen
//     final isOnline = convo['is_online'] ?? false;
//     final lastSeen = convo['last_seen'] != null
//         ? DateTime.tryParse(convo['last_seen'])?.toLocal()
//         : null;

//     final lastMessage = convo['last_message'] ?? '';
//     final createdAt = convo['last_message_time'] != null
//         ? DateTime.tryParse(convo['last_message_time'])?.toLocal()
//         : null;

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
//         title: Text(
//           otherName ?? 'Unknown',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (!isOnline && lastSeen != null)
//               Text(
//                 'Last seen: ${lastSeen.hour.toString().padLeft(2, '0')}:${lastSeen.minute.toString().padLeft(2, '0')}',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             Text(
//               lastMessage,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//         trailing: createdAt != null
//             ? Text(
//                 "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               )
//             : null,
//         onTap: () async {
//           final convoId = await openOrCreateConversation(
//               isUser ? convo['provider_id'] : convo['user_id']);
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ChatPage(
//                 conversationId: convoId,
//                 currentUserId: widget.currentUserId,
//               ),
//             ),
//           ).then((_) => fetchConversations());
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Messages')),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : conversations.isEmpty
//               ? Center(child: Text('No conversations yet'))
//               : RefreshIndicator(
//                   onRefresh: fetchConversations,
//                   child: ListView.builder(
//                     itemCount: conversations.length,
//                     itemBuilder: (context, index) =>
//                         buildConversationCard(conversations[index]),
//                   ),
//                 ),
//     );
//   }
// }





////////////////////////////////////////////


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
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

//   @override
//   void initState() {
//     super.initState();
//     fetchConversations();
//   }

//   Future<void> fetchConversations() async {
//     setState(() => isLoading = true);
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations?user_id=${widget.currentUserId}");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           conversations = ((data['conversations'] as List<dynamic>?) ?? [])
//               .where((c) => c != null) // filter nulls
//               .toList();
//         });
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

//   Future<int> openOrCreateConversation(int otherUserId) async {
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations");
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "user_id": widget.currentUserId,
//           "provider_id": otherUserId,
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         return data['conversation_id'] ?? -1;
//       } else {
//         throw Exception('Failed to create/open conversation');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//       rethrow;
//     }
//   }

//   Widget buildConversationCard(dynamic convo) {
//     final int? userId = convo['user_id'] as int?;
//     final int? providerId = convo['provider_id'] as int?;
//     final bool isUser = userId == widget.currentUserId;

//     final otherName = isUser
//         ? convo['provider_name'] as String? ?? 'Unknown'
//         : convo['user_name'] as String? ?? 'Unknown';

//     final avatarUrl = isUser
//         ? convo['provider_avatar'] as String?
//         : convo['user_avatar'] as String?;

//     final isOnline = convo['is_online'] as bool? ?? false;

//     final lastSeen = convo['last_seen'] != null
//         ? DateTime.tryParse(convo['last_seen'])?.toLocal()
//         : null;

//     final lastMessage = convo['last_message'] as String? ?? '';
//     final createdAt = convo['last_message_time'] != null
//         ? DateTime.tryParse(convo['last_message_time'])?.toLocal()
//         : null;

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
//         trailing: createdAt != null
//             ? Text(
//                 "${createdAt.hour.toString().padLeft(2,'0')}:${createdAt.minute.toString().padLeft(2,'0')}",
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               )
//             : null,
//         onTap: () async {
//           final int? otherId = isUser ? providerId : userId;
//           if (otherId == null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text("Error: Invalid conversation participant")));
//             return;
//           }
//           final convoId = await openOrCreateConversation(otherId);
//           if (convoId == -1) return;

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ChatPage(
//                 conversationId: convoId,
//                 currentUserId: widget.currentUserId,
//               ),
//             ),
//           ).then((_) => fetchConversations());
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Messages')),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : conversations.isEmpty
//               ? Center(child: Text('No conversations yet'))
//               : RefreshIndicator(
//                   onRefresh: fetchConversations,
//                   child: ListView.builder(
//                     itemCount: conversations.length,
//                     itemBuilder: (context, index) =>
//                         buildConversationCard(conversations[index]),
//                   ),
//                 ),
//     );
//   }
// }
//////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
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

//   @override
//   void initState() {
//     super.initState();
//     fetchConversations();
//   }

//   // ---------------- Fetch Conversations ----------------
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
//               .toList();
//         });
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

//   // ---------------- Delete Conversation ----------------
//   Future<void> deleteConversation(int convoId) async {
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/conversations/$convoId");
//       final response = await http.delete(url);

//       if (response.statusCode == 200) {
//         setState(() => conversations.removeWhere((c) => c['conversation_id'] == convoId));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete chat')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   // ---------------- Build Conversation Card ----------------
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
//         trailing: createdAt != null
//             ? Text(
//                 "${createdAt.hour.toString().padLeft(2,'0')}:${createdAt.minute.toString().padLeft(2,'0')}",
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               )
//             : null,
//         onTap: () {
//           if (convoId == -1 || otherUserId == -1) return;

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ChatPage(
//                 conversationId: convoId,
//                 currentUserId: widget.currentUserId,
//                 otherUserId: otherUserId,
//               ),
//             ),
//           ).then((_) => fetchConversations());
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Messages')),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : conversations.isEmpty
//               ? Center(child: Text('No conversations yet'))
//               : RefreshIndicator(
//                   onRefresh: fetchConversations,
//                   child: ListView.builder(
//                     itemCount: conversations.length,
//                     itemBuilder: (context, index) =>
//                         buildConversationCard(conversations[index]),
//                   ),
//                 ),
//     );
//   }
// }


//////
//////////////////////////////////////////////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
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
//   late IO.Socket socket;

//   @override
//   void initState() {
//     super.initState();
//     initSocket();
//     fetchConversations();
//   }

//   @override
//   void dispose() {
//     socket.dispose();
//     super.dispose();
//   }

//   // ------------------- SOCKET.IO -------------------
//   void initSocket() {
//     socket = IO.io(
//       Backend.baseUrl,
//       <String, dynamic>{
//         'transports': ['websocket'],
//         'autoConnect': true,
//       },
//     );

//     socket.connect();

//     socket.onConnect((_) {
//       print('Socket connected: ${socket.id}');
//       socket.emit('user_online', widget.currentUserId);
//     });

//     // New message notification
//     socket.on('new_message_notification', (data) {
//       final convoId = data['conversationId'];
//       final msg = data['message'];

//       setState(() {
//         final index = conversations.indexWhere((c) => c['conversation_id'] == convoId);
//         if (index != -1) {
//           conversations[index]['last_message'] = msg;
//           conversations[index]['last_message_time'] = DateTime.now().toIso8601String();
//           final currentUnread = conversations[index]['unread_count'] ?? 0;
//           conversations[index]['unread_count'] = currentUnread + 1;
//         } else {
//           // If conversation not in list, fetch all
//           fetchConversations();
//         }
//       });
//     });

//     // Reset unread count when joining conversation
//     socket.on('unread_count_reset', (data) {
//       final convoId = data['conversationId'];
//       setState(() {
//         final index = conversations.indexWhere((c) => c['conversation_id'] == convoId);
//         if (index != -1) {
//           conversations[index]['unread_count'] = 0;
//         }
//       });
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
//                 // Ensure unread_count is always a number
//                 c['unread_count'] = c['unread_count'] ?? 0;
//                 return c;
//               })
//               .toList();
//         });
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
//         setState(() => conversations.removeWhere((c) => c['conversation_id'] == convoId));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete chat')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
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
//             // Refresh conversations & reset badge
//             socket.emit('join_conversation', [convoId, widget.currentUserId]);
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Messages')),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : conversations.isEmpty
//               ? Center(child: Text('No conversations yet'))
//               : RefreshIndicator(
//                   onRefresh: fetchConversations,
//                   child: ListView.builder(
//                     itemCount: conversations.length,
//                     itemBuilder: (context, index) =>
//                         buildConversationCard(conversations[index]),
//                   ),
//                 ),
//     );
//   }
// }




//////////////////////////////////////


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

//     socket.connect();

//     socket.onConnect((_) {
//       print('Socket connected: ${socket.id}');
//       socket.emit('user_online', widget.currentUserId);
//     });

//     // New message notification
//     socket.on('new_message_notification', (data) {
//       final convoId = data['conversationId'];
//       final msg = data['message'];

//       setState(() {
//         final index = conversations.indexWhere((c) => c['conversation_id'] == convoId);
//         if (index != -1) {
//           conversations[index]['last_message'] = msg;
//           conversations[index]['last_message_time'] = DateTime.now().toIso8601String();
//           final currentUnread = conversations[index]['unread_count'] ?? 0;
//           conversations[index]['unread_count'] = currentUnread + 1;
//         } else {
//           fetchConversations();
//         }
//       });
//       _filterChats();
//     });

//     // New conversation added
//     socket.on('new_conversation', (data) {
//       setState(() {
//         conversations.insert(0, data);
//       });
//       _filterChats();
//     });

//     // Unread count reset
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
//             socket.emit('join_conversation', [convoId, widget.currentUserId]);
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
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             IconButton(
//               icon: Icon(Icons.menu, color: Colors.black),
//               onPressed: () {},
//             ),
//             Text('Chat_List', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//             Spacer(),
//             IconButton(
//               icon: Icon(Icons.message, color: Colors.teal),
//               onPressed: () {},
//             ),
//             IconButton(
//               icon: Icon(Icons.notifications, color: Colors.teal),
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 // Search bar
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search chats...',
//                       prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Chat list
//                 Expanded(
//                   child: filteredConversations.isEmpty
//                       ? Center(
//                           child: Text(
//                             _searchController.text.isEmpty
//                                 ? 'No conversations yet'
//                                 : 'No conversations found',
//                             style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
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
    socket = IO.io(
      Backend.baseUrl,
      <String, dynamic>{'transports': ['websocket'], 'autoConnect': true},
    );

    socket.connect();

    socket.onConnect((_) {
      socket.emit('user_online', widget.currentUserId);
    });

    socket.on('new_message_notification', (data) {
      final convoId = data['conversationId'];
      final msg = data['message'];

      setState(() {
        final index = conversations.indexWhere((c) => c['conversation_id'] == convoId);
        if (index != -1) {
          conversations[index]['last_message'] = msg;
          conversations[index]['last_message_time'] = DateTime.now().toIso8601String();
          final currentUnread = conversations[index]['unread_count'] ?? 0;
          conversations[index]['unread_count'] = currentUnread + 1;
        } else {
          fetchConversations();
        }
      });
      _filterChats();
    });

    socket.on('new_conversation', (data) {
      setState(() {
        conversations.insert(0, data);
      });
      _filterChats();
    });

    socket.on('unread_count_reset', (data) {
      final convoId = data['conversationId'];
      setState(() {
        final index = conversations.indexWhere((c) => c['conversation_id'] == convoId);
        if (index != -1) conversations[index]['unread_count'] = 0;
      });
      _filterChats();
    });
  }

  // ------------------- FETCH CONVERSATIONS -------------------
  Future<void> fetchConversations() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse("${Backend.baseUrl}/conversations?user_id=${widget.currentUserId}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          conversations = (data['conversations'] as List<dynamic>? ?? [])
              .where((c) => c != null)
              .map((c) {
                c['unread_count'] = c['unread_count'] ?? 0;
                return c;
              })
              .toList();
        });
        _filterChats();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load conversations')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete chat')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
            .where((c) => (c['other_user_name'] ?? '').toLowerCase().contains(query))
            .toList();
      }
    });
  }

  // ------------------- BUILD CONVERSATION CARD -------------------
  Widget buildConversationCard(dynamic convo) {
    final convoId = convo['conversation_id'] ?? -1;
    final otherUserId = convo['other_user_id'] ?? -1;
    final otherName = convo['other_user_name'] ?? 'Unknown';
    final avatarUrl = (convo['other_user_avatar'] != null && convo['other_user_avatar'].toString().isNotEmpty)
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
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
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
        title: Text(otherName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOnline && lastSeen != null)
              Text(
                'Last seen: ${lastSeen.hour.toString().padLeft(2,'0')}:${lastSeen.minute.toString().padLeft(2,'0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
                "${createdAt.hour.toString().padLeft(2,'0')}:${createdAt.minute.toString().padLeft(2,'0')}",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        onTap: () {
          if (convoId == -1 || otherUserId == -1) return;

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
            socket.emit('join_conversation', [convoId, widget.currentUserId]);
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Message copied')),
                    );
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search chats...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchConversations,
                          child: ListView.builder(
                            itemCount: filteredConversations.length,
                            itemBuilder: (context, index) =>
                                buildConversationCard(filteredConversations[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
