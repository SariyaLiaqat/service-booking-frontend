// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class ChatBotScreen extends StatefulWidget {
//   const ChatBotScreen({Key? key}) : super(key: key);

//   @override
//   _ChatBotScreenState createState() => _ChatBotScreenState();
// }

// class _ChatBotScreenState extends State<ChatBotScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   List<Map<String, String>> messages = [];
//   bool _isLoading = false;

//   Future<void> sendMessage(String text) async {
//     if (text.isEmpty) return;

//     setState(() {
//       messages.add({"role": "user", "content": text});
//       _controller.clear();
//       _isLoading = true;
//     });

//     String reply = await getGeminiResponse(text);

//     setState(() {
//       messages.add({"role": "bot", "content": reply});
//       _isLoading = false;
//     });

//     // Scroll to bottom
//     Future.delayed(Duration(milliseconds: 100), () {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   Future<String> getGeminiResponse(String prompt) async {
//     try {
//       final response = await http.post(
//         Uri.parse(
//           'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyDeqrb_EdS7qke63vt7OetPw4G0pqvHlIY'
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "contents": [
//             {
//               "parts": [
//                 {"text": prompt}
//               ]
//             }
//           ]
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data["candidates"][0]["content"]["parts"][0]["text"];
//       } else {
//         print("ERROR: ${response.statusCode} ${response.body}");
//         return "Oops! Something went wrong.";
//       }
//     } catch (e) {
//       print("Exception: $e");
//       return "Error connecting to AI server.";
//     }
//   }

//   Widget buildMessage(Map<String, String> message) {
//     bool isUser = message['role'] == 'user';
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//         decoration: BoxDecoration(
//           color: isUser ? Colors.blueAccent : Colors.grey[200],
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 2,
//               offset: Offset(1, 2),
//             ),
//           ],
//         ),
//         child: Text(
//           message['content'] ?? "",
//           style: TextStyle(
//             color: isUser ? Colors.white : Colors.black87,
//             fontSize: 15,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("AI Chatbot"),
//         backgroundColor: Colors.blueAccent,
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 return buildMessage(messages[index]);
//               },
//             ),
//           ),
//           if (_isLoading)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: CircularProgressIndicator(color: Colors.blueAccent),
//             ),
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     textInputAction: TextInputAction.send,
//                     onSubmitted: sendMessage,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       contentPadding: EdgeInsets.symmetric(
//                         vertical: 12,
//                         horizontal: 16,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(24),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 CircleAvatar(
//                   backgroundColor: Colors.blueAccent,
//                   child: IconButton(
//                     icon: Icon(Icons.send, color: Colors.white),
//                     onPressed: () => sendMessage(_controller.text),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for copy
import 'package:http/http.dart' as http;
import '../helpers/coolors.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool _isLoading = false;

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": text});
      _controller.clear();
      _isLoading = true;
    });

    String reply = await getGeminiResponse(text);

    setState(() {
      messages.add({"role": "bot", "content": reply});
      _isLoading = false;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<String> getGeminiResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=AIzaSyDeqrb_EdS7qke63vt7OetPw4G0pqvHlIY',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        print("ERROR: ${response.statusCode} ${response.body}");
        return "Oops! Something went wrong.";
      }
    } catch (e) {
      print("Exception: $e");
      return "Error connecting to AI server.";
    }
  }

  // ⭐ PREMIUM MESSAGE BUBBLE
  Widget buildMessage(Map<String, String> message) {
    bool isUser = message['role'] == 'user';

    Color bubbleColor = isUser
        ? Color(0xFF4A90E2) // user bubble soft blue
        : Colors.white; // bot bubble

    Color textColor = isUser ? Colors.white : Colors.black87;

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message['content'] ?? ''));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Message copied")));
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: isUser ? Radius.circular(18) : Radius.circular(4),
              bottomRight: isUser ? Radius.circular(4) : Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Text(
            message['content'] ?? "",
            style: TextStyle(color: textColor, fontSize: 15, height: 1.3),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F4F7),

      appBar: AppBar(
        backgroundColor: kPrimaryColor.withOpacity(0.1),
        elevation: 1,

        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(
                "assets/images/chatbot.png",
              ), // ⭐ put your AI image here
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chatbot",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "AI Assistant",
                  style: TextStyle(color: kSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) => buildMessage(messages[index]),
            ),
          ),

          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
            ),

          // ⭐ INPUT BOX
          Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: sendMessage,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Color(0xFF4A90E2),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
