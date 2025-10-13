// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';

// // ------------------- MODEL -------------------
// class Status {
//   final int id;
//   final int providerId;
//   final String type; // 'image' or 'video'
//   final String url;
//   final DateTime createdAt;
//   final DateTime? expiresAt;
//   final int userId;
//   final String? caption;
//   final bool isPublic;
//   bool isViewed;
//   final String? uploaderName;
//   final int? uploaderUserId; // ✅ NEW FIELD
//   final String? uploaderAvatarUrl;
// bool isLikedByCurrentUser; // ✅ Add this
// int likeCount;             // ✅ Add this

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
//     this.isViewed = false,
//     this.uploaderName,
//     this.uploaderUserId, // ✅ add in constructor
//     this.uploaderAvatarUrl,
//     this.isLikedByCurrentUser = false,
//   this.likeCount = 0,
//   });

//   factory Status.fromJson(Map<String, dynamic> json) {
//   return Status(
//     id: json['id'] ?? 0,
//     userId: json['provider_user_id'] ?? 0,
//     providerId: json['provider_id'] ?? 0,
//     type: json['status_type'] ?? 'image',
//     url: Backend.buildMediaUrl(json['media_url'] ?? ''),

//     createdAt: json['created_at'] != null
//         ? DateTime.parse(json['created_at'])
//         : DateTime.now(), // fallback to now if null
//     expiresAt: json['expires_at'] != null
//         ? DateTime.parse(json['expires_at'])
//         : null,
//     caption: json['caption'] ?? '', // fallback to empty string
//     isPublic: json['is_public'] ?? true,
//     uploaderName: json['uploaderName'] ?? 'Unknown',
//    uploaderUserId: json['uploaderUserId'] ?? 0, // ✅ Fix yahi hai
// uploaderAvatarUrl: json['uploaderAvatarUrl'] ?? '',
// isViewed: json['isViewed'] ?? false,
// // ✅ NEW FIELDS
// isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
// likeCount: json['likeCount'] ?? 0,
//   );
// }
// }

// // ------------------- CONTROLLER -------------------
// class StatusController extends ChangeNotifier {
//   List<Status> statuses = [];
//   List<Status> publicStatuses = [];
//   late IO.Socket socket;
//   final int currentUserId;

//   // upload progress notifier
//   ValueNotifier<double> uploadProgress = ValueNotifier(0.0);

//   StatusController({required this.currentUserId}) {
//     initSocket();
//     fetchStatuses();
//     fetchPublicStatuses();
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

//     // FIX: remove by status id instead of provider
//     socket.on('status_removed', (data) {
//       final statusId = data['status_id'];
//       statuses.removeWhere((s) => s.id == statusId);
//       publicStatuses.removeWhere((s) => s.id == statusId);
//       notifyListeners();
//     });
//   }

//   // Mark status as viewed
//   void markStatusAsViewed(int statusId) {
//     final index = publicStatuses.indexWhere((s) => s.id == statusId);
//     if (index != -1) {
//       publicStatuses[index].isViewed = true;
//       notifyListeners();
//     }
//   }

//   // ---------------- Upload with caption & public/private ----------------
//  // ---------------- Upload with caption & public/private ----------------
// Future<void> uploadStatusWithMeta(
//   String filePath, String type, String? caption, bool isPublic) async {

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

//     // Convert to bytes directly (collecting while tracking progress)
//     List<int> bytes = [];
//     int received = 0;
//     final total = streamedResponse.contentLength ?? 0;

//     await for (final chunk in streamedResponse.stream) {
//       bytes.addAll(chunk);
//       received += chunk.length;

//       // Handle missing contentLength (total = 0)
//       if (total > 0) {
//         uploadProgress.value = received / total;
//       } else {
//         // indeterminate progress fallback (halfway)
//         uploadProgress.value = 0.5;
//       }
//     }

//     final responseBody = utf8.decode(bytes);

//     // Ensure progress 100% on finish
//     uploadProgress.value = 1.0;

//     if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
//       print("✅ Status uploaded successfully with meta: $responseBody");
//       await fetchStatuses();
//       await fetchPublicStatuses();
//     } else {
//       print("❌ Error uploading status: $responseBody");
//     }

//   } catch (e) {
//     print("❌ Exception uploading status: $e");
//   }
// }

// //----------------------Fetch Status---------------------------------//
//   // Fetch user statuses
//   Future<void> fetchStatuses() async {
//     try {
//       final userId = currentUserId;
//       final url = Uri.parse("${Backend.baseUrl}/statuses/fetch?user_id=$userId");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         statuses =
//             (data['statuses'] as List<dynamic>?)
//                     ?.map((s) => Status.fromJson(s))
//                     .toList() ??
//                 [];
//         notifyListeners();
//       } else {
//         print("Failed to fetch statuses: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching statuses: $e");
//     }
//   }

//   // Fetch public statuses
//   Future<void> fetchPublicStatuses() async {
//     try {
//      final url = Uri.parse("${Backend.baseUrl}/statuses/fetch-public?user_id=$currentUserId");

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         publicStatuses =
//             (data['statuses'] as List<dynamic>?)
//                     ?.map((s) => Status.fromJson(s))
//                     .toList() ??
//                 [];
//         notifyListeners();
//         print("✅ Public statuses fetched: ${publicStatuses.length}");
//       } else {
//         print("Failed to fetch public statuses: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching public statuses: $e");
//     }
//   }
// }

// // ------------------- UI WIDGETS -------------------
// class StatusCircle extends StatelessWidget {
//   final Status status;
//   final VoidCallback onTap;

//   const StatusCircle({Key? key, required this.status, required this.onTap})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.grey[300],
//            backgroundImage: status.type == 'image'
//     ? NetworkImage(status.url.startsWith('http') ? status.url : "${Backend.baseUrl}/${status.url}")
//     : status.uploaderAvatarUrl != null
//         ? NetworkImage(status.uploaderAvatarUrl!)
//         : null,

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
//                 color: status.isViewed ? Colors.grey : Colors.green,
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

// void showStatusViewer(
//   BuildContext context,
//   Status status,
//   StatusController controller,
// ) {
//   showGeneralDialog(
//     context: context,
//     barrierDismissible: true,
//     barrierLabel: "Dismiss",
//     pageBuilder: (context, _, __) {
//       // Compute media URL safely
//       final mediaUrl = status.url.startsWith('http')
//     ? status.url
//     : "${Backend.baseUrl}/${status.url}";

//       return Scaffold(
//         backgroundColor: Colors.black,
//         body: SafeArea(
//           child: Stack(
//             children: [
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Expanded(
//                     child: status.type == 'image'
//                         ? InteractiveViewer(
//                             child: Image.network(
//                               mediaUrl,
//                               fit: BoxFit.contain,
//                               loadingBuilder: (context, child, progress) {
//                                 if (progress == null) return child;
//                                 return Center(
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Center(
//                                   child: Icon(Icons.error, color: Colors.red, size: 40),
//                                 );
//                               },
//                             ),
//                           )
//                         : VideoStatusViewer(url: mediaUrl),
//                   ),
//                   if (status.caption != null)
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         status.caption!,
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       "Uploaded: ${status.createdAt.toLocal()}",
//                       style: TextStyle(color: Colors.white70, fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned(
//                 right: 10,
//                 top: 10,
//                 child: IconButton(
//                   icon: Icon(Icons.close, color: Colors.white, size: 28),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   ).then((_) {
//     controller.markStatusAsViewed(status.id); // mark viewed
//   });
// }

// class VideoStatusViewer extends StatefulWidget {
//   final String url;
//   const VideoStatusViewer({required this.url, Key? key}) : super(key: key);

//   @override
//   _VideoStatusViewerState createState() => _VideoStatusViewerState();
// }

// class _VideoStatusViewerState extends State<VideoStatusViewer> {
//   late VideoPlayerController _videoController;
//   ChewieController? _chewieController;
//   bool _hasError = false;
//   bool _isLoading = true;
//   bool _isHls = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }

//   Future<void> _initializePlayer() async {
//     try {
//       // Full URL handling
//       final videoUrl = widget.url.startsWith('http')
//           ? widget.url
//           : "${Backend.baseUrl}/${widget.url}";

//       _isHls = videoUrl.toLowerCase().endsWith('.m3u8');

//      _videoController = _isHls
//     ? VideoPlayerController.network(videoUrl, formatHint: VideoFormat.hls)
//     : VideoPlayerController.network(videoUrl);

//       // HLS sometimes takes a bit to buffer; pre-buffer first frame
//       await _videoController.initialize();

//       // Chewie setup
//       _chewieController = ChewieController(
//         videoPlayerController: _videoController,
//         autoPlay: true,
//         looping: false,
//         allowFullScreen: true,
//         allowMuting: true,
//         showControls: true,
//         showOptions: false,
//       );

//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _hasError = false;
//       });
//     } catch (e) {
//       print("❌ Video failed to load: $e");
//       if (!mounted) return;
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _chewieController?.dispose();
//     _videoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: const [
//             CircularProgressIndicator(color: Colors.white),
//             SizedBox(height: 8),
//             Text("Loading video...", style: TextStyle(color: Colors.white)),
//           ],
//         ),
//       );
//     }

//     if (_hasError || _chewieController == null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: const [
//             Icon(Icons.error, color: Colors.red, size: 40),
//             SizedBox(height: 8),
//             Text("Failed to load video", style: TextStyle(color: Colors.white)),
//           ],
//         ),
//       );
//     }

//     return Chewie(controller: _chewieController!);
//   }
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
//         itemCount: controller.publicStatuses.length,
//         itemBuilder: (context, index) {
//           final status = controller.publicStatuses[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: StatusCircle(
//               status: status,
//               onTap: () => showStatusViewer(context, status, controller),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

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
  final int? uploaderUserId; // ✅ NEW FIELD
  final String? uploaderAvatarUrl;
  bool isLikedByCurrentUser; // ✅ Add this
  int likeCount; // ✅ Add this
  bool isLikingInProgress = false;

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
    this.uploaderUserId, // ✅ add in constructor
    this.uploaderAvatarUrl,
    this.isLikedByCurrentUser = false,
    this.likeCount = 0,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['provider_user_id'] is int
          ? json['provider_user_id']
          : int.tryParse(json['provider_user_id']?.toString() ?? '0') ?? 0,
      providerId: json['provider_id'] is int
          ? json['provider_id']
          : int.tryParse(json['provider_id']?.toString() ?? '0') ?? 0,
      type: json['status_type']?.toString() ?? 'image',
      url: Backend.buildMediaUrl(json['media_url']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      caption: json['caption']?.toString() ?? '',
      isPublic: json['is_public'] is bool
          ? json['is_public']
          : json['is_public']?.toString().toLowerCase() == 'true',
      uploaderName: json['uploaderName']?.toString() ?? 'Unknown',
      uploaderUserId: json['uploaderUserId'] is int
          ? json['uploaderUserId']
          : int.tryParse(json['uploaderUserId']?.toString() ?? '0') ?? 0,
      uploaderAvatarUrl: json['uploaderAvatarUrl']?.toString() ?? '',
      isViewed: json['isViewed'] is bool
          ? json['isViewed']
          : json['isViewed']?.toString().toLowerCase() == 'true',
      isLikedByCurrentUser: json['isLikedByCurrentUser'] is bool
          ? json['isLikedByCurrentUser']
          : json['isLikedByCurrentUser']?.toString().toLowerCase() == 'true',
      likeCount: json['likeCount'] is int
          ? json['likeCount']
          : int.tryParse(json['likeCount']?.toString() ?? '0') ?? 0,
    );
  }
}

// ------------------- CONTROLLER -------------------
class StatusController extends ChangeNotifier {
  List<Status> statuses = [];
  List<Status> publicStatuses = [];
  late IO.Socket socket;
  final int currentUserId;
  bool isLoading = true;
  // upload progress notifier
  ValueNotifier<double> uploadProgress = ValueNotifier(0.0);

  StatusController({required this.currentUserId}) {
    initSocket();
    fetchStatuses();
    fetchPublicStatuses();
  }
int get unviewedPublicCount {
    return publicStatuses.where((s) => !s.isViewed).length;
  }
  
  Future<void> toggleLike(Status status) async {
    if (status.isLikingInProgress) return; // ⛔ Prevent spam tap
    status.isLikingInProgress = true;

    // 🔹 Optimistic UI update
    final oldLiked = status.isLikedByCurrentUser;
    final oldCount = status.likeCount;

    status.isLikedByCurrentUser = !oldLiked;
    status.likeCount += status.isLikedByCurrentUser ? 1 : -1;

    // ✅ Update in both lists
    _updateStatusInLists(status);

    try {
      final response = await http.post(
        Uri.parse("${Backend.baseUrl}/api/status-likes"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status_id': status.id, 'user_id': currentUserId}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // ❌ Revert on server failure
        status.isLikedByCurrentUser = oldLiked;
        status.likeCount = oldCount;
        _updateStatusInLists(status);
        print("Failed to like status: ${response.body}");
      } else {
        print("✅ Like updated successfully");
      }
    } catch (e) {
      // ❌ Revert on network error
      status.isLikedByCurrentUser = oldLiked;
      status.likeCount = oldCount;
      _updateStatusInLists(status);
      print("Error liking status: $e");
    } finally {
      status.isLikingInProgress = false;
    }
  }

  // 🔹 Helper method to update status in all lists
  void _updateStatusInLists(Status updated) {
    int index = statuses.indexWhere((s) => s.id == updated.id);
    if (index != -1) statuses[index] = updated;

    int pubIndex = publicStatuses.indexWhere((s) => s.id == updated.id);
    if (pubIndex != -1) publicStatuses[pubIndex] = updated;

    notifyListeners();
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
  void markStatusAsViewed(int statusId) async {
  final index = publicStatuses.indexWhere((s) => s.id == statusId);
  if (index != -1) {
    publicStatuses[index].isViewed = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("${Backend.baseUrl}/statuses/mark-viewed"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status_id': statusId, 'user_id': currentUserId}),
      );
      if (response.statusCode != 200) {
        print("Failed to mark status viewed: ${response.body}");
        // Optional: revert locally if needed
      }
    } catch (e) {
      print("Error marking status viewed: $e");
      // Optional: revert locally if needed
    }
  }
}


  // ---------------- Upload with caption & public/private ----------------
  // ---------------- Upload with caption & public/private ----------------
  Future<void> uploadStatusWithMeta(
    String filePath,
    String type,
    String? caption,
    bool isPublic,
  ) async {
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

        // Handle missing contentLength (total = 0)
        if (total > 0) {
          uploadProgress.value = received / total;
        } else {
          // indeterminate progress fallback (halfway)
          uploadProgress.value = 0.5;
        }
      }

      final responseBody = utf8.decode(bytes);

      // Ensure progress 100% on finish
      uploadProgress.value = 1.0;

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

  //----------------------Fetch Status---------------------------------//
  // Fetch user statuses
  Future<void> fetchStatuses() async {
    try {
      final userId = currentUserId;
      final url = Uri.parse(
        "${Backend.baseUrl}/statuses/fetch?user_id=$userId",
      );
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
  // Fetch public statuses
  Future<void> fetchPublicStatuses() async {
    try {
      final url = Uri.parse(
        "${Backend.baseUrl}/statuses/fetch-public?user_id=$currentUserId",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse statuses directly, assuming backend sends likeCount & isLikedByCurrentUser
        publicStatuses =
            (data['statuses'] as List<dynamic>?)
                ?.map((s) => Status.fromJson(s))
                .toList() ??
            [];

        notifyListeners();
        print("✅ Public statuses fetched: ${publicStatuses.length}");
      } else {
        print("Failed to fetch public statuses: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching public statuses: $e");
    } finally {
      isLoading = false; // ✅ Update loading state
      notifyListeners(); // ✅ Trigger UI rebuild
    }
  }
}

// ------------------- UI WIDGETS -------------------
class StatusCircle extends StatelessWidget {
  final Status status;
  final VoidCallback onTap;
final StatusController controller;
  const StatusCircle({Key? key, required this.status, required this.onTap,required this.controller,})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
  if (!status.isViewed) {
    final controller = Provider.of<StatusController>(context, listen: false);
    controller.markStatusAsViewed(status.id);

    onTap(); 
  }
},

      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: status.type == 'image'
                ? NetworkImage(
                    status.url.startsWith('http')
                        ? status.url
                        : "${Backend.baseUrl}/${status.url}",
                  )
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
                color: (status.uploaderUserId != controller.currentUserId && !status.isViewed)
    ? Colors.green
    : Colors.grey,


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
  StatusController controller, {
  VoidCallback? onViewed,
}) {
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
                            child: CachedNetworkImage(
                              imageUrl: mediaUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.redAccent,
                                      size: 40,
                                    ),
                                  ),
                            ),
                          )
                        : VideoStatusViewer(url: mediaUrl),
                  ),
                  if (status.caption != null &&
                      status.caption!.trim().isNotEmpty)
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
    if (onViewed != null) onViewed(); // 🔹 call callback
  });
}

class VideoStatusViewer extends StatefulWidget {
  final String url;
  const VideoStatusViewer({required this.url, Key? key}) : super(key: key);

  @override
  _VideoStatusViewerState createState() => _VideoStatusViewerState();
}

class _VideoStatusViewerState extends State<VideoStatusViewer>
    with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _isLoading = true;
  bool _isHls = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // 🔹 Ensure full URL (handle both relative & absolute)
      final videoUrl = widget.url.startsWith('http')
          ? widget.url
          : "${Backend.baseUrl}${widget.url}";

      // 🔹 Detect if HLS format
      _isHls = videoUrl.toLowerCase().endsWith('.m3u8');

      // ✅ Use networkUrl (safer for HLS)
      _videoController = _isHls
          ? VideoPlayerController.networkUrl(
              Uri.parse(videoUrl),
              formatHint: VideoFormat.hls,
            )
          : VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      print("🎥 Loading video from: $videoUrl");

      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
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
    WidgetsBinding.instance.removeObserver(this);
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_chewieController == null) return;

    if (state == AppLifecycleState.paused) {
      _chewieController!.pause(); // App background → pause video
    } else if (state == AppLifecycleState.resumed) {
      _chewieController!.play(); // App foreground → play video
    }
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

    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
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
      child: Consumer<StatusController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (ctrl.publicStatuses.isEmpty) {
            return const Center(
              child: Text(
                "No status uploaded yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: ctrl.publicStatuses.length,
            itemBuilder: (context, index) {
              final status = ctrl.publicStatuses[index];
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StatusCircle(
  status: status,
  controller: ctrl, // add this
  onTap: () => showStatusViewer(
    context,
    status,
    ctrl,
    onViewed: () => ctrl.markStatusAsViewed(status.id),
  ),
),

              );
            },
          );
        },
      ),
    );
  }
}
