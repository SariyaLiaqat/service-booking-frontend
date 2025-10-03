// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import 'package:provider/provider.dart';
// import '../widgets/status_widget.dart';
// //import '../controllers/status_controller.dart';
// import '../helpers/backend.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';

// // ------------------- STATUS PAGE -------------------
// class StatusPage extends StatefulWidget {
//   final int currentUserId;
//   final bool isProvider; // only SP can add status

//   const StatusPage({
//     Key? key,
//     required this.currentUserId,
//     required this.isProvider,
//   }) : super(key: key);

//   @override
//   _StatusPageState createState() => _StatusPageState();
// }

// class _StatusPageState extends State<StatusPage> {
//   late StatusController statusController;

//   @override
//   void initState() {
//     super.initState();
//     statusController = StatusController(currentUserId: widget.currentUserId);
//     statusController.fetchPublicStatuses(); // fetch public statuses too
//   }

//   // ------------------- ADD STATUS -------------------
//   Future<void> _openAddStatusDialog() async {
//     final picker = ImagePicker();
//     XFile? pickedFile;
//     String? type;

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Add Status"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton.icon(
//                 icon: Icon(Icons.image),
//                 label: Text("Pick Image"),
//                 onPressed: () async {
//                   pickedFile = await picker.pickImage(
//                     source: ImageSource.gallery,
//                   );
//                   type = 'image';
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ElevatedButton.icon(
//                 icon: Icon(Icons.videocam),
//                 label: Text("Pick Video"),
//                 onPressed: () async {
//                   pickedFile = await picker.pickVideo(
//                     source: ImageSource.gallery,
//                   );
//                   type = 'video';
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );

//     if (pickedFile != null && type != null) {
//       // show caption & public/private option
//       TextEditingController captionController = TextEditingController();
//       bool isPublic = true;

//       await showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text("Add Caption & Visibility"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: captionController,
//                   decoration: InputDecoration(labelText: "Caption (optional)"),
//                 ),
//                 Row(
//                   children: [
//                     Text("Public"),
//                     Switch(
//                       value: isPublic,
//                       onChanged: (val) => setState(() => isPublic = val),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 child: Text("Cancel"),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//               ElevatedButton(
//                 child: Text("Upload"),
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   await statusController.uploadStatusWithMeta(
//                     pickedFile!.path,
//                     type!,
//                     captionController.text,
//                     isPublic,
//                   );
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: statusController,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color(0xFF0A66C2),
//           title: Text("Statuses"),
//           centerTitle: true,
//         ),
//         body: Consumer<StatusController>(
//           builder: (context, controller, _) {
//             return Column(
//               children: [
//                 SizedBox(height: 8),
//                 // ------------------- SP Add Status -------------------
//                 if (widget.isProvider)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Row(
//                       children: [
//                         GestureDetector(
//                           onTap: _openAddStatusDialog,
//                           child: CircleAvatar(
//                             radius: 30,
//                             backgroundColor: Colors.blueAccent,
//                             child: Icon(
//                               Icons.add,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           "Add Status",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                 const SizedBox(height: 12),
//                 // ------------------- HORIZONTAL STATUS LIST -------------------
//                 StatusList(controller: controller),
//                 const SizedBox(height: 12),
//                 Divider(),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     "Public Statuses",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 // ------------------- PUBLIC STATUSES -------------------
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: controller.publicStatuses.length,
//                     itemBuilder: (context, index) {
//                       final status = controller.publicStatuses[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         child: ListTile(
//                           leading: StatusCircle(
//                             status: status,
//                             onTap: () => showFullScreenStatus(
//                               context,
//                               index,
//                               controller.publicStatuses,
//                             ),
//                           ),
//                           title: Text(status.caption ?? "No caption"),
//                           subtitle: Text(
//                             "Uploaded: ${status.createdAt.toLocal()}",
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ------------------- FULL SCREEN STATUS VIEWER -------------------
//   void showFullScreenStatus(
//     BuildContext context,
//     int startIndex,
//     List<Status> list,
//   ) {
//     PageController pageController = PageController(initialPage: startIndex);

//     showDialog(
//       context: context,
//       builder: (_) {
//         return Dialog(
//           backgroundColor: Colors.black,
//           insetPadding: EdgeInsets.all(0),
//           child: StatefulBuilder(
//             builder: (context, setState) {
//               return PageView.builder(
//                 controller: pageController,
//                 itemCount: list.length,
//                 itemBuilder: (context, index) {
//                   final status = list[index];

//                   if (status.type == 'image') {
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Expanded(
//                           child: InteractiveViewer(
//                             child: Image.network(
//                               "${Backend.baseUrl}/${status.url}",
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               Text(
//                                 status.caption ?? "",
//                                 style: TextStyle(color: Colors.white70),
//                               ),
//                               Text(
//                                 "Uploaded: ${status.createdAt.toLocal()}",
//                                 style: TextStyle(color: Colors.white38),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   } else {
//                     // Video case
//                     final videoController = VideoPlayerController.network(
//                       "${Backend.baseUrl}/${status.url}",
//                     );
//                     final chewieController = ChewieController(
//                       videoPlayerController: videoController,
//                       autoPlay: true,
//                       looping: false,
//                     );

//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Expanded(child: Chewie(controller: chewieController)),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               Text(
//                                 status.caption ?? "",
//                                 style: TextStyle(color: Colors.white70),
//                               ),
//                               Text(
//                                 "Uploaded: ${status.createdAt.toLocal()}",
//                                 style: TextStyle(color: Colors.white38),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/status_widget.dart';
import '../helpers/backend.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';

// ------------------- STATUS PAGE -------------------
class StatusPage extends StatefulWidget {
  final int currentUserId;
  final bool isProvider; // only SP can add status

  const StatusPage({
    Key? key,
    required this.currentUserId,
    required this.isProvider,
  }) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  late StatusController statusController;

  @override
  void initState() {
    super.initState();
    statusController = StatusController(currentUserId: widget.currentUserId);
    statusController.fetchPublicStatuses(); // fetch public statuses too
  }
// ------------------- ADD STATUS -------------------
Future<void> _openAddStatusDialog() async {
  final picker = ImagePicker();
  XFile? pickedFile;
  String? type;

  // Pick file dialog
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Add Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text("Pick Image"),
              onPressed: () async {
                pickedFile = await picker.pickImage(source: ImageSource.gallery);
                type = 'image';
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.videocam),
              label: Text("Pick Video"),
              onPressed: () async {
                pickedFile = await picker.pickVideo(source: ImageSource.gallery);
                type = 'video';
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );

  // If file selected
  if (pickedFile != null && type != null) {
    TextEditingController captionController = TextEditingController();
    bool isPublic = true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: Text("Add Caption & Visibility"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: captionController,
                    decoration: InputDecoration(
                      labelText: "Caption (optional)",
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Public"),
                      Switch(
                        value: isPublic,
                        onChanged: (val) {
                          setStateSB(() => isPublic = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text("Upload"),
                  onPressed: () async {
                    if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // close caption dialog

                    // Show uploading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return WillPopScope(
                          onWillPop: () async => false, // disable back
                          child: Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.all(0),
                            child: Center(
                              child: ValueListenableBuilder<double>(
                                valueListenable: statusController.uploadProgress,
                                builder: (context, progress, _) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        value: progress > 0 && progress < 1 ? progress : null,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        progress > 0 && progress < 1
                                            ? "Uploading... ${(progress * 100).toStringAsFixed(0)}%"
                                            : "Finalizing...",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );

                    // Call upload
                    await statusController.uploadStatusWithMeta(
                      pickedFile!.path,
                      type!,
                      captionController.text,
                      isPublic,
                    );

                    // Reset progress
                    statusController.uploadProgress.value = 0.0;

                    // Close uploading safely
                    if (Navigator.of(context, rootNavigator: true).canPop()) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: statusController,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A66C2),
          title: Text("Statuses"),
          centerTitle: true,
        ),
        body: Consumer<StatusController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                SizedBox(height: 8),
                // ------------------- SP Add Status -------------------
                if (widget.isProvider)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _openAddStatusDialog,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Add Status",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                // ------------------- HORIZONTAL STATUS LIST -------------------
                StatusList(controller: controller),

                const SizedBox(height: 12),
                Divider(),

                // ------------------- PUBLIC STATUS HEADER -------------------
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Public Statuses",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // ------------------- PUBLIC STATUSES -------------------
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.publicStatuses.length,
                    itemBuilder: (context, index) {
                      final status = controller.publicStatuses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: StatusCircle(
                            status: status,
                            onTap: () => showFullScreenStatus(
                              context,
                              index,
                              controller.publicStatuses,
                              controller,
                            ),
                          ),
                          title: Text(status.uploaderName ?? "Unknown"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (status.caption != null) Text(status.caption!),
                              Text("Uploaded: ${status.createdAt.toLocal()}"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.contact_page, color: Colors.blue),
                            onPressed: () {
                              // TODO: open provider profile
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Open provider profile here"),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------- FULL SCREEN STATUS VIEWER -------------------
  void showFullScreenStatus(
    BuildContext context,
    int startIndex,
    List<Status> list,
    StatusController controller,
  ) {
    PageController pageController = PageController(initialPage: startIndex);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(0),
          child: StatefulBuilder(
            builder: (context, setStateSB) {
              return PageView.builder(
                controller: pageController,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final status = list[index];

                  // ✅ Fix for double slashes in URL
                  String mediaUrl = Backend.buildMediaUrl(status.url);

                  Widget media;
                  if (status.type == 'image') {
                    media = InteractiveViewer(
                      child: Image.network(mediaUrl, fit: BoxFit.contain),
                    );
                  } else {
                    media = VideoStatusViewer(url: mediaUrl);
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: media),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              status.caption ?? "",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Uploaded: ${status.createdAt.toLocal()}",
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    ).then((_) {
      // Mark as viewed
      controller.markStatusAsViewed(list[startIndex].id);
    });
  }
}
