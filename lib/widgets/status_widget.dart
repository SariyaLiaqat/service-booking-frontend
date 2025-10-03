// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// // ------------------- MODEL -------------------
// class Status {
//   final int id;
//   final int providerId;
//   final String type; // 'image' or 'video'
//   final String url;
//   final DateTime createdAt;
//   final DateTime? expiresAt;
//   final int userId;
//   final String? caption; // NEW
//   final bool isPublic; // NEW

//   Status({
//     required this.id,
//     required this.providerId,
//     required this.type,
//     required this.url,
//     required this.createdAt,
//     this.expiresAt,
//     required this.userId,
//     this.caption,
//     this.isPublic = true,
//   });

//   factory Status.fromJson(Map<String, dynamic> json) {
//   return Status(
//     id: json['id'] ?? 0,
//     userId: json['provider_user_id'] ?? 0, // <-- fix here
//     providerId: json['provider_id'] ?? 0,
//     type: json['status_type'] ?? 'image',
//     url: json['media_url'] ?? '',
//     createdAt: DateTime.parse(json['created_at']),
//     expiresAt: json['expires_at'] != null
//         ? DateTime.parse(json['expires_at'])
//         : null,
//     caption: json['caption'],
//     isPublic: json['is_public'] ?? true,
//   );
// }

// }

// // ------------------- CONTROLLER -------------------
// class StatusController extends ChangeNotifier {
//   List<Status> statuses = [];
//   late IO.Socket socket;
//   final int currentUserId;
//   List<Status> publicStatuses = [];
//   StatusController({required this.currentUserId}) {
//     initSocket();
//     fetchStatuses();
//   }

//   void initSocket() {
//     socket = IO.io(Backend.baseUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     socket.connect();

//     socket.onConnect((_) {
//       print("Status socket connected");
//       socket.emit('user_online', currentUserId);
//     });

//     socket.on('status_updated', (data) {
//       final status = Status.fromJson(data);
//       statuses.removeWhere((s) => s.id == status.id);
//       statuses.insert(0, status);
//       notifyListeners();
//     });

//     socket.on('status_removed', (data) {
//       final providerId = data['provider_id'];
//       statuses.removeWhere((s) => s.userId == providerId);
//       notifyListeners();
//     });
//   }


// // ---------------- Upload with caption & public/private ----------------
// Future<void> uploadStatusWithMeta(
//     String filePath, String type, String? caption, bool isPublic) async {
//   try {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse("${Backend.baseUrl}/statuses/upload"),
//     );
//     request.fields['provider_id'] = currentUserId.toString();
//     request.fields['status_type'] = type;
//     if (caption != null) request.fields['caption'] = caption;
//     request.fields['is_public'] = isPublic ? 'true' : 'false';
//     request.files.add(await http.MultipartFile.fromPath('media', filePath));

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       print("✅ Status uploaded successfully with meta");
//       // Optionally: refetch statuses
//       await fetchStatuses();
//       await fetchPublicStatuses();
//     } else {
//       print("❌ Error uploading status: ${response.body}");
//     }
//   } catch (e) {
//     print("❌ Exception uploading status: $e");
//   }
// }

//   // Fetch statuses from backend
//   Future<void> fetchStatuses() async {
//     try {
//       final userId = currentUserId;
//       final url = Uri.parse(
//         "${Backend.baseUrl}/statuses/fetch?user_id=$userId",
//       );
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         statuses =
//             (data['statuses'] as List<dynamic>?)
//                 ?.map((s) => Status.fromJson(s))
//                 .toList() ??
//             [];
//         notifyListeners();
//       } else {
//         print("Failed to fetch statuses: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching statuses: $e");
//     }
//   }

//   // public status..

//   Future<void> fetchPublicStatuses() async {
//     try {
//       final url = Uri.parse("${Backend.baseUrl}/statuses/fetch-public");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         publicStatuses =
//             (data['statuses'] as List<dynamic>?)
//                 ?.map((s) => Status.fromJson(s))
//                 .toList() ??
//             [];
//         notifyListeners();
//       } else {
//         print("Failed to fetch public statuses: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching public statuses: $e");
//     }
//   }

//   // Upload status
//   Future<void> uploadStatus(String filePath, String type) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse("${Backend.baseUrl}/statuses/upload"),
//       );
//       request.fields['provider_id'] = currentUserId.toString();
//       request.fields['status_type'] = type;
//       request.files.add(await http.MultipartFile.fromPath('media', filePath));

//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         print("✅ Status uploaded successfully");
//       } else {
//         print("❌ Error uploading status: ${response.body}");
//       }
//     } catch (e) {
//       print("❌ Exception uploading status: $e");
//     }
//   }
// }

// // ------------------- UI WIDGETS -------------------
// class StatusCircle extends StatelessWidget {
//   final Status status;
//   final VoidCallback onTap;

//   const StatusCircle({Key? key, required this.status, required this.onTap})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Stack(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.grey[300],
//             backgroundImage: status.type == 'image'
//                 ? NetworkImage("${Backend.baseUrl}/${status.url}")
//                 : null,
//             child: status.type == 'video'
//                 ? Icon(Icons.videocam, color: Colors.white, size: 24)
//                 : null,
//           ),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: Container(
//               width: 12,
//               height: 12,
//               decoration: BoxDecoration(
//                 color: Colors.green,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ------------------- STATUS VIEWER -------------------
// void showStatusViewer(BuildContext context, Status status) {
//   showDialog(
//     context: context,
//     builder: (_) {
//       return Dialog(
//         backgroundColor: Colors.black,
//         insetPadding: EdgeInsets.all(0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Expanded(
//               child: status.type == 'image'
//                   ? InteractiveViewer(
//                       child: Image.network("${Backend.baseUrl}/${status.url}"),
//                     )
//                   : Center(
//                       child: Icon(
//                         Icons.videocam,
//                         color: Colors.white,
//                         size: 50,
//                       ),
//                     ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "Uploaded: ${status.createdAt.toLocal()}",
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// // ------------------- STATUS LIST WIDGET -------------------
// class StatusList extends StatelessWidget {
//   final StatusController controller;

//   const StatusList({Key? key, required this.controller}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 80,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: controller.statuses.length,
//         itemBuilder: (context, index) {
//           final status = controller.statuses[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: StatusCircle(
//               status: status,
//               onTap: () => showStatusViewer(context, status),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /////////////////
//   ///
// }














import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

// ------------------- MODEL -------------------
class Status {
  final int id;
  final int providerId;
  final String type; // 'image' or 'video'
  final String url;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int userId;
  final String? caption;
  final bool isPublic;
  bool isViewed;
  final String? uploaderName;
  final String? uploaderAvatarUrl;

  Status({
    required this.id,
    required this.providerId,
    required this.type,
    required this.url,
    required this.createdAt,
    this.expiresAt,
    required this.userId,
    this.caption,
    this.isPublic = true,
    this.isViewed = false,
    this.uploaderName,
    this.uploaderAvatarUrl,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'] ?? 0,
      userId: json['provider_user_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      type: json['status_type'] ?? 'image',
      url: json['media_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      caption: json['caption'],
      isPublic: json['is_public'] ?? true,
      isViewed: json['is_viewed'] ?? false,
      uploaderName: json['uploader_name'],
      uploaderAvatarUrl: json['uploader_avatar'],
    );
  }
}

// ------------------- CONTROLLER -------------------
class StatusController extends ChangeNotifier {
  List<Status> statuses = [];
  List<Status> publicStatuses = [];
  late IO.Socket socket;
  final int currentUserId;

  // upload progress notifier
  ValueNotifier<double> uploadProgress = ValueNotifier(0.0);

  StatusController({required this.currentUserId}) {
    initSocket();
    fetchStatuses();
    fetchPublicStatuses();
  }

  void initSocket() {
    socket = IO.io(Backend.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.onConnect((_) {
      print("Status socket connected");
      socket.emit('user_online', currentUserId);
    });

    socket.on('status_updated', (data) {
      final status = Status.fromJson(data);
      statuses.removeWhere((s) => s.id == status.id);
      statuses.insert(0, status);
      notifyListeners();
    });

    // FIX: remove by status id instead of provider
    socket.on('status_removed', (data) {
      final statusId = data['status_id'];
      statuses.removeWhere((s) => s.id == statusId);
      publicStatuses.removeWhere((s) => s.id == statusId);
      notifyListeners();
    });
  }

  // Mark status as viewed
  void markStatusAsViewed(int statusId) {
    final index = publicStatuses.indexWhere((s) => s.id == statusId);
    if (index != -1) {
      publicStatuses[index].isViewed = true;
      notifyListeners();
    }
  }

  // ---------------- Upload with caption & public/private ----------------
  Future<void> uploadStatusWithMeta(
    String filePath, String type, String? caption, bool isPublic) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${Backend.baseUrl}/statuses/upload"),
    );
    request.fields['provider_id'] = currentUserId.toString();
    request.fields['status_type'] = type;
    if (caption != null) request.fields['caption'] = caption;
    request.fields['is_public'] = isPublic ? 'true' : 'false';
    request.files.add(await http.MultipartFile.fromPath('media', filePath));

    final streamedResponse = await request.send();

    // Convert to bytes directly (collecting while tracking progress)
    List<int> bytes = [];
    int received = 0;
    final total = streamedResponse.contentLength ?? 0;

    await for (final chunk in streamedResponse.stream) {
      bytes.addAll(chunk);
      received += chunk.length;

      if (total > 0) {
        uploadProgress.value = received / total; // update progress
      }
    }

    final responseBody = utf8.decode(bytes);

    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      print("✅ Status uploaded successfully with meta: $responseBody");
      await fetchStatuses();
      await fetchPublicStatuses();
    } else {
      print("❌ Error uploading status: $responseBody");
    }
  } catch (e) {
    print("❌ Exception uploading status: $e");
  }
}




  // Fetch user statuses
  Future<void> fetchStatuses() async {
    try {
      final userId = currentUserId;
      final url = Uri.parse("${Backend.baseUrl}/statuses/fetch?user_id=$userId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        statuses =
            (data['statuses'] as List<dynamic>?)
                    ?.map((s) => Status.fromJson(s))
                    .toList() ??
                [];
        notifyListeners();
      } else {
        print("Failed to fetch statuses: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching statuses: $e");
    }
  }

  // Fetch public statuses
  Future<void> fetchPublicStatuses() async {
    try {
     final url = Uri.parse("${Backend.baseUrl}/statuses/fetch-public?user_id=$currentUserId");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        publicStatuses =
            (data['statuses'] as List<dynamic>?)
                    ?.map((s) => Status.fromJson(s))
                    .toList() ??
                [];
        notifyListeners();
      } else {
        print("Failed to fetch public statuses: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching public statuses: $e");
    }
  }
}

// ------------------- UI WIDGETS -------------------
class StatusCircle extends StatelessWidget {
  final Status status;
  final VoidCallback onTap;

  const StatusCircle({Key? key, required this.status, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
           backgroundImage: status.type == 'image'
    ? NetworkImage(status.url.startsWith('http') ? status.url : "${Backend.baseUrl}/${status.url}")
    : status.uploaderAvatarUrl != null
        ? NetworkImage(status.uploaderAvatarUrl!)
        : null,


            child: status.type == 'video'
                ? Icon(Icons.videocam, color: Colors.white, size: 24)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: status.isViewed ? Colors.grey : Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





void showStatusViewer(
  BuildContext context,
  Status status,
  StatusController controller,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    pageBuilder: (context, _, __) {
      // Compute media URL safely
      final mediaUrl = status.url.startsWith('http')
          ? status.url
          : "${Backend.baseUrl}/${status.url}";

      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: status.type == 'image'
                        ? InteractiveViewer(
                            child: Image.network(
                              mediaUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(Icons.error, color: Colors.red, size: 40),
                                );
                              },
                            ),
                          )
                        : VideoStatusViewer(url: mediaUrl),
                  ),
                  if (status.caption != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        status.caption!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Uploaded: ${status.createdAt.toLocal()}",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 10,
                top: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).then((_) {
    controller.markStatusAsViewed(status.id); // mark viewed
  });
}










class VideoStatusViewer extends StatefulWidget {
  final String url;
  const VideoStatusViewer({required this.url, Key? key}) : super(key: key);

  @override
  _VideoStatusViewerState createState() => _VideoStatusViewerState();
}

class _VideoStatusViewerState extends State<VideoStatusViewer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _isLoading = true;
  bool _isHls = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Full URL handling
      final videoUrl = widget.url.startsWith('http')
          ? widget.url
          : "${Backend.baseUrl}/${widget.url}";

      _isHls = videoUrl.toLowerCase().endsWith('.m3u8');

     _videoController = _isHls
    ? VideoPlayerController.network(videoUrl, formatHint: VideoFormat.hls)
    : VideoPlayerController.network(videoUrl);


      // HLS sometimes takes a bit to buffer; pre-buffer first frame
      await _videoController.initialize();

      // Chewie setup
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showOptions: false,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print("❌ Video failed to load: $e");
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 8),
            Text("Loading video...", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_hasError || _chewieController == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error, color: Colors.red, size: 40),
            SizedBox(height: 8),
            Text("Failed to load video", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }
}








// ------------------- STATUS LIST WIDGET -------------------
class StatusList extends StatelessWidget {
  final StatusController controller;

  const StatusList({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.statuses.length,
        itemBuilder: (context, index) {
          final status = controller.statuses[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: StatusCircle(
              status: status,
              onTap: () => showStatusViewer(context, status, controller),
            ),
          );
        },
      ),
    );
  }
}
