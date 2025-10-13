// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';

// class StatusCommentsWidget extends StatefulWidget {
//   final int statusId;
//   final int currentUserId;

//   const StatusCommentsWidget({
//     Key? key,
//     required this.statusId,
//     required this.currentUserId,
//   }) : super(key: key);

//   @override
//   _StatusCommentsWidgetState createState() => _StatusCommentsWidgetState();
// }

// class _StatusCommentsWidgetState extends State<StatusCommentsWidget> {
//   List<dynamic> comments = [];
//   final TextEditingController _controller = TextEditingController();
//   bool isLoading = false;

//   int? replyingToCommentId;
//   String replyingToUserName = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchComments();
//   }

//   Future<void> fetchComments() async {
//     setState(() => isLoading = true);
//     try {
//       final response = await http.get(
//         Uri.parse("${Backend.baseUrl}/api/status-comments/${widget.statusId}"),
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           comments = data['comments'] ?? [];
//         });
//       }
//     } catch (e) {
//       print("Error fetching comments: $e");
//     }
//     setState(() => isLoading = false);
//   }

//   Future<void> postComment(String text) async {
//     if (text.trim().isEmpty) return;

//     String cleanText = text.trim();

// // Include mention when replying
// if (replyingToUserName.isNotEmpty && !cleanText.startsWith("@$replyingToUserName")) {
//   cleanText = "@$replyingToUserName $cleanText";
// }

//     try {
//       final response = await http.post(
//         Uri.parse("${Backend.baseUrl}/api/status-comments"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "status_id": widget.statusId,
//           "user_id": widget.currentUserId,
//           "comment_text": cleanText,
//           "reply_to_comment_id": replyingToCommentId,
//         }),
//       );

//      if (response.statusCode == 201) {
//   // Keep the mention after sending, just fetch latest comments
// await fetchComments();
// _controller.value = TextEditingValue(
//   text: "@$replyingToUserName ", // Keep mention
//   selection: TextSelection.fromPosition(
//     TextPosition(offset: "@$replyingToUserName ".length),
//   ),
// );

// }

//       else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to post comment")),
//         );
//       }
//     } catch (e) {
//       print("Error posting comment: $e");
//     }
//   }

//   Widget buildCommentItem(Map<String, dynamic> comment, {int indent = 0}) {
//     return Padding(
//       padding: EdgeInsets.only(left: indent.toDouble(), top: 4, bottom: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Card(
//             color: Colors.grey[100],
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: ListTile(
//               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               title: Text(comment['user_name'] ?? 'Unknown',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               subtitle:RichText(
//   text: TextSpan(
//     children: [
//       if (comment['reply_to_user_name'] != null)
//         TextSpan(
//           text: "@${comment['reply_to_user_name']} ",
//           style: TextStyle(
//             color: Colors.blueAccent, // highlight the mention
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       TextSpan(
//         text: comment['comment_text'] ?? '',
//         style: TextStyle(color: Colors.black),
//       ),
//     ],
//   ),
// ),

//               trailing: Icon(Icons.reply, size: 20, color: Colors.blueAccent),
//              onTap: () {
//   setState(() {
//     replyingToCommentId = comment['id'];
//     replyingToUserName = comment['user_name'] ?? '';

//     // ✅ Better mention handling with cursor at end
//     _controller.value = TextEditingValue(
//       text: "@$replyingToUserName ",
//       selection: TextSelection.fromPosition(
//         TextPosition(offset: "@$replyingToUserName ".length),
//       ),
//     );
//   });
// },

//             ),
//           ),

//           // Nested replies
//           if (comment['replies'] != null && comment['replies'].isNotEmpty)
//             ...List.generate(comment['replies'].length, (i) {
//               final reply = comment['replies'][i];
//               return buildCommentItem(reply, indent: indent + 20);
//             }),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 400,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
//       ),
//       child: Column(
//         children: [
//           Text("Comments",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           SizedBox(height: 8),

//           // Replying Header
//           if (replyingToCommentId != null)
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//               margin: EdgeInsets.only(bottom: 6),
//               decoration: BoxDecoration(
//                   color: Colors.blueAccent.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12)),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text("Replying to $replyingToUserName",
//                         style: TextStyle(color: Colors.blueAccent)),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         replyingToCommentId = null;
//                         replyingToUserName = '';
//                         _controller.clear();
//                       });
//                     },
//                     child: Icon(Icons.close, size: 16, color: Colors.blueAccent),
//                   )
//                 ],
//               ),
//             ),

//           // Comments List
//           Expanded(
//             child: isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : comments.isEmpty
//                     ? Center(child: Text("No comments yet"))
//                     : ListView.builder(
//                         itemCount: comments.length,
//                         itemBuilder: (context, index) {
//                           final comment = comments[index];
//                           return buildCommentItem(comment);
//                         },
//                       ),
//           ),

//           // TextField + Send Button
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _controller,
//                   decoration: InputDecoration(
//                     hintText: "Add a comment...",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(25),
//                       borderSide: BorderSide.none,
//                     ),
//                     fillColor: Colors.grey[200],
//                     filled: true,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 16),
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.send, color: Colors.blueAccent),
//                 onPressed: () => postComment(_controller.text),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
///////////////////////////
///
///

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import '../screens/chat_page.dart';
import '../helpers/my_colors.dart';

class StatusCommentsWidget extends StatefulWidget {
  final int statusId;
  final int currentUserId;

  const StatusCommentsWidget({
    Key? key,
    required this.statusId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _StatusCommentsWidgetState createState() => _StatusCommentsWidgetState();
}

class _StatusCommentsWidgetState extends State<StatusCommentsWidget> {
  List<dynamic> comments = [];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
final ScrollController _scrollController = ScrollController();

  int? replyingToCommentId;
  String replyingToUserName = '';
bool isSending = false;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  //----------------msg user
  Future<void> messageUser(int userId, String? userName) async {
    try {
      final response = await http.post(
        Uri.parse("${Backend.baseUrl}/conversations"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.currentUserId, // login user
          "provider_id": userId, // comment karne wale
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final conversationId = data['conversation_id'] ?? data['id'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: conversationId,
              currentUserId: widget.currentUserId,
              otherUserId: userId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to start chat ❌")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error starting chat: $e")));
    }
  }

  Future<void> fetchComments() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${Backend.baseUrl}/api/status-comments/${widget.statusId}"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
         comments = (data['comments'] ?? []).reversed.toList();
        });
      }
    } catch (e) {
      print("Error fetching comments: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> postComment(String text) async {
    if (text.trim().isEmpty) return;
if (isSending || text.trim().isEmpty) return; // 👈 double click prevent

  setState(() => isSending = true);
    String cleanText = text.trim();

    // Include mention when replying
    if (replyingToUserName.isNotEmpty &&
        !cleanText.startsWith("@$replyingToUserName")) {
      cleanText = "@$replyingToUserName $cleanText";
    }

    try {
      final response = await http.post(
        Uri.parse("${Backend.baseUrl}/api/status-comments"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "status_id": widget.statusId,
          "user_id": widget.currentUserId,
          "comment_text": cleanText,
          "reply_to_comment_id": replyingToCommentId,
        }),
      );

      if (response.statusCode == 201) {
        // Keep the mention after sending, just fetch latest comments
        await fetchComments();
        _scrollController.animateTo(
  _scrollController.position.maxScrollExtent,
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeOut,
);

        _controller.value = TextEditingValue(
          text: "@$replyingToUserName ", // Keep mention
          selection: TextSelection.fromPosition(
            TextPosition(offset: "@$replyingToUserName ".length),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to post comment")));
      }
    } catch (e) {
      print("Error posting comment: $e");
    }finally {
    setState(() => isSending = false); // 👈 unlock send button again
  }
  }

  Widget buildCommentItem(Map<String, dynamic> comment, {int indent = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: indent.toDouble(), top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: MyColors.inputBorder,
            elevation: 2,
            shadowColor: MyColors.secondary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: MyColors.secondary.withOpacity(0.3),
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              title: Text(
                comment['user_name'] ?? 'Unknown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MyColors.textPrimary,
                ),
              ),
              subtitle: RichText(
                text: TextSpan(
                  children: [
                    if (comment['reply_to_user_name'] != null)
                      TextSpan(
                        text: "@${comment['reply_to_user_name']} ",
                        style: TextStyle(
                          color: MyColors.secondary, // highlight the mention
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    TextSpan(
                      text: comment['comment_text'] ?? '',
                      style: TextStyle(color: MyColors.textSecondary),
                    ),
                  ],
                ),
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reply icon (jaise pehle)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        replyingToCommentId = comment['id'];
                        replyingToUserName = comment['user_name'] ?? '';

                        _controller.value = TextEditingValue(
                          text: "@$replyingToUserName ",
                          selection: TextSelection.fromPosition(
                            TextPosition(
                              offset: "@$replyingToUserName ".length,
                            ),
                          ),
                        );
                      });
                    },
                    child: Icon(
                      Icons.reply,
                      size: 20,
                      color: Colors.blueAccent,
                    ),
                  ),

                  SizedBox(width: 12),

                  // ✅ Message icon
                  GestureDetector(
                    onTap: () =>
                        messageUser(comment['user_id'], comment['user_name']),
                    child: Icon(Icons.message, size: 20, color: Colors.green),
                  ),
                ],
              ),

              onTap: () {
                setState(() {
                  replyingToCommentId = comment['id'];
                  replyingToUserName = comment['user_name'] ?? '';

                  // ✅ Better mention handling with cursor at end
                  _controller.value = TextEditingValue(
                    text: "@$replyingToUserName ",
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: "@$replyingToUserName ".length),
                    ),
                  );
                });
              },
            ),
          ),

          // Nested replies
          if (comment['replies'] != null && comment['replies'].isNotEmpty)
            ...List.generate(comment['replies'].length, (i) {
              final reply = comment['replies'][i];
              return buildCommentItem(reply, indent: indent + 20);
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                context,
              ).viewInsets.bottom, // 👈 adjust for keyboard
            ),
            
            child: Container(
              constraints: BoxConstraints(maxHeight: constraints.maxHeight),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MyColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Title
                  Text(
                    "Comments",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 🔹 Reply Header
                  if (replyingToCommentId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: MyColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: MyColors.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Replying to $replyingToUserName",
                              style: TextStyle(
                                color: MyColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                replyingToCommentId = null;
                                replyingToUserName = '';
                                _controller.clear();
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: MyColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 🔹 Comments List
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: MyColors.secondary,
                            ),
                          )
                        : comments.isEmpty
                        ? Center(
                            child: Text(
                              "No comments yet",
                              style: TextStyle(color: MyColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                          controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return buildCommentItem(comment);
                            },
                          ),
                  ),

                  // 🔹 Input Field + Send Button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(color: MyColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: TextStyle(color: MyColors.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: MyColors.inputFill,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
  icon: isSending
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Icon(Icons.send, color: MyColors.secondary),
  onPressed: isSending ? null : () => postComment(_controller.text),
),

                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
