// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../widgets/status_widget.dart';
// import '../helpers/backend.dart';
// import 'MyProfileScreen.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/status_comments_widget.dart';
// import '../helpers/coolors.dart';
// import 'package:flutter/services.dart';

// class StatusPage extends StatefulWidget {
//   final int currentUserId;
//   final bool isProvider;
//   final VoidCallback? onViewed;
//   const StatusPage({
//     Key? key,
//     required this.currentUserId,
//     required this.isProvider,
//     this.onViewed,
//   }) : super(key: key);

//   @override
//   _StatusPageState createState() => _StatusPageState();
// }

// class _StatusPageState extends State<StatusPage> {
//   late StatusController statusController;
//   final PageController _pageController = PageController();

//   @override
//   void initState() {
//     super.initState();
//     statusController = StatusController(currentUserId: widget.currentUserId);
//     statusController.fetchPublicStatuses();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       widget.onViewed?.call();
//     });
//   }

// Future<void> _openAddStatusDialog() async {
//   final picker = ImagePicker();
//   XFile? pickedFile;
//   String? type;

//   // 🌆 Step 1: Pick Image or Video
//   await showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (_) => Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       child: Container(
//         decoration: BoxDecoration(
//           color: kCardColor,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text("Add Status", style: TextStyle(fontSize: 20, color: kTextPrimary, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             Text("Choose what you want to share:", style: TextStyle(color: kTextSecondary)),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor, foregroundColor: kTextPrimary),
//                   icon: const Icon(Icons.image),
//                   label: const Text("Image"),
//                   onPressed: () async {
//                     pickedFile = await picker.pickImage(source: ImageSource.gallery);
//                     type = 'image';
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor, foregroundColor: kTextPrimary),
//                   icon: const Icon(Icons.videocam),
//                   label: const Text("Video"),
//                   onPressed: () async {
//                     pickedFile = await picker.pickVideo(source: ImageSource.gallery);
//                     type = 'video';
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );

//   // 🚀 Step 2: Add Caption (Corrected for Keyboard)
//   if (pickedFile != null && type != null) {
//     TextEditingController captionController = TextEditingController();
//     ValueNotifier<int> wordCount = ValueNotifier<int>(0);

//     await showGeneralDialog(
//       context: context,
//       barrierDismissible: false,
//       pageBuilder: (context, anim1, anim2) {
//         return Scaffold(
//           backgroundColor: Colors.black.withOpacity(0.5),
//           body: Center(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//               child: Dialog(
//                 backgroundColor: Colors.transparent,
//                 insetPadding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: kCardColor,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.edit_note, color: kSecondaryColor, size: 26),
//                           const SizedBox(width: 8),
//                           Text("Add Caption", style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                      // ... inside showGeneralDialog builder ...
// ValueListenableBuilder<int>(
//   valueListenable: wordCount,
//   builder: (context, value, _) => TextField(
//     controller: captionController,
//     maxLines: 4,
//     maxLength: 2000, // Character limit safety
//     style: TextStyle(color: kTextPrimary),
//     decoration: InputDecoration(
//       hintText: "Write your caption...",
//       hintStyle: TextStyle(color: kTextSecondary),
//       filled: true,
//       counterText: "", // Hides the default character counter
//       fillColor: kCardColor.withOpacity(0.9),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//       suffixIcon: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         child: Text(
//           "$value/300 words", // Your specific word limit
//           style: TextStyle(
//             color: value > 300 ? Colors.red : kSecondaryColor,
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ),
//     onChanged: (text) {
//       // Logic to count actual words
//       wordCount.value = text.trim().isEmpty
//           ? 0
//           : text.trim().split(RegExp(r'\s+')).length;
//     },
//   ),
// ),
// // ... rest of the code ...
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text("Cancel", style: TextStyle(color: kTextSecondary)),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor, foregroundColor: kTextPrimary),
//                             icon: const Icon(Icons.cloud_upload),
//                             label: const Text("Upload"),
//                             onPressed: () async {
//   // 1. Close the Caption Dialog
//   Navigator.pop(context);

//   // 2. Show the Progress Dialog
//   _showProgressDialog(context, statusController);

//   try {
//     // 3. Wait for the actual upload to finish
//     await statusController.uploadStatusWithMeta(
//       pickedFile!.path,
//       type!,
//       captionController.text,
//       true,
//     );

//     // 4. IMPORTANT: Wait for half a second so the user actually sees "100%"
//     await Future.delayed(const Duration(milliseconds: 500));
//   } catch (e) {
//     print("Upload error: $e");
//   } finally {
//     // 5. Close the Progress Dialog using rootNavigator
//     if (mounted) {
//        Navigator.of(context, rootNavigator: true).pop();
//     }

//     // 6. Reset progress ONLY AFTER the dialog is gone
//     Future.delayed(const Duration(milliseconds: 200), () {
//       statusController.uploadProgress.value = 0.0;
//     });
//   }
// },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // Separate helper for cleaner code
// // 📍 Updated helper with controller parameter
// void _showProgressDialog(BuildContext context, StatusController controller) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => WillPopScope(
//       onWillPop: () async => false,
//       child: Center(
//         child: ValueListenableBuilder<double>(
//           valueListenable: controller.uploadProgress,
//           builder: (context, progress, _) {
//             return Container(
//               padding: const EdgeInsets.all(25),
//               decoration: BoxDecoration(
//                 color: kCardColor,
//                 borderRadius: BorderRadius.circular(16)
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // 👑 Percentage inside the circle
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         value: progress.clamp(0.01, 1.0), // 0.01 keeps it visible at start
//                         color: kPrimaryColor,
//                         strokeWidth: 5,
//                       ),
//                       Text(
//                         "${(progress * 100).toInt()}%",
//                         style: TextStyle(
//                           color: kTextPrimary,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 15),
//                   Text(
//   progress >= 1.0 ? "Uploaded ✅" : "Uploading...",
//   style: TextStyle(color: kTextPrimary),
// ),

//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     ),
//   );
// }
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: statusController,
//       child: Scaffold(
//         backgroundColor: kTextPrimary,
//         body: Stack(
//           children: [
//             Consumer<StatusController>(
//               builder: (context, controller, _) {
//                 if (controller.isLoading) {
//                   return const Center(
//                     child: CircularProgressIndicator(color: kPrimaryColor),
//                   );
//                 }

//                 final hasStatuses = controller.publicStatuses.isNotEmpty;

//                 return PageView.builder(
//                   controller: _pageController,
//                   scrollDirection: Axis.vertical,
//                   itemCount: hasStatuses ? controller.publicStatuses.length : 1,
//                   onPageChanged: (index) {
//                     final status = controller.publicStatuses[index];
//                     if (!status.isViewed) {
//                       controller.markStatusAsViewed(
//                         status.id,
//                       ); // ✅ Controller ka method call karo
//                     }
//                   },

//                   itemBuilder: (context, index) {
//                     if (!hasStatuses) {
//                       // Empty state screen
//                       return Stack(
//                         children: [
//                           Center(
//                             child: Text(
//                               "No status is uploaded yet",
//                               style: TextStyle(
//                                 color: kTextSecondary,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ),
//                           if (widget.isProvider)
//                             Positioned(
//                               bottom: 30,
//                               right: 20,
//                               child: FloatingActionButton(
//                                 backgroundColor: kPrimaryColor,
//                                 onPressed: _openAddStatusDialog,
//                                 child: const Icon(
//                                   Icons.add,
//                                   color: kTextPrimary,
//                                   size: 28,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       );
//                     }

//                     final status = controller.publicStatuses[index];
//                     final mediaUrl = Backend.buildMediaUrl(status.url);

//                     return Stack(
//                       children: [
//                         Positioned.fill(
//                           child: GestureDetector(
//                             onDoubleTap: () async {
//                               if (!status.isLikingInProgress) {
//                                 await context
//                                     .read<StatusController>()
//                                     .toggleLike(status);
//                               }
//                             },
//                             child: status.type == 'image'
//                                 ? InteractiveViewer(
//                                     panEnabled: true,
//                                     minScale: 1,
//                                     maxScale: 4,
//                                     child: Image.network(
//                                       mediaUrl,
//                                       fit: BoxFit.contain,
//                                       width: double.infinity,
//                                       height: double.infinity,
//                                     ),
//                                   )
//                                 : VideoStatusViewer(url: mediaUrl),
//                           ),
//                         ),

//                         // Top progress indicator placeholder
//                         Positioned(
//                           top: 20,
//                           left: 0,
//                           right: 0,
//                           child: Center(
//                             child: Container(
//                               width: 60,
//                               height: 4,
//                               decoration: BoxDecoration(
//                                 color: Colors.white54,
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                             ),
//                           ),
//                         ),

//                         // Caption & uploader name
//                         if (status.caption != null ||
//                             status.uploaderName != null)
//                          // 📍 UPDATE THIS SECTION: Caption & uploader name
//    // 📍 UPDATE YOUR POSITIONED WIDGET HERE
// Positioned(
//   left: 20,
//   bottom: 50,
//   right: 80, // Giving it a bit more width
//   child: StatefulBuilder(
//     builder: (context, setElementState) {
//       final String captionText = status.caption ?? "";
//       final bool isLongText = captionText.length > 60;

//       return Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.black54,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (status.uploaderName != null)
//               Text(
//                 status.uploaderName!,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             if (captionText.isNotEmpty) ...[
//               const SizedBox(height: 4),
//               GestureDetector(
//                 onTap: () {
//                   if (isLongText) {
//                     setElementState(() => status.isExpanded = !status.isExpanded);
//                   }
//                 },
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       captionText,
//                       // Removed the ?? false because isExpanded is non-nullable
//                       maxLines: status.isExpanded ? 10 : 2,
//                       overflow: status.isExpanded
//                           ? TextOverflow.visible
//                           : TextOverflow.ellipsis,
//                       style: const TextStyle(color: Colors.white70, fontSize: 14),
//                     ),
//                     if (isLongText)
//                       Padding(
//                        padding: const EdgeInsets.only(top: 4),
//                         child: Text(
//                           status.isExpanded ? "Show less" : "Show more",
//                           style: TextStyle(
//                             color: kSecondaryColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       );
//     },
//   ),
// ),
//                         // Right side buttons
//                         Positioned(
//                           right: 20,
//                           bottom: 50,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               // Profile button
//                             Material(
//   color: Colors.transparent,
//   shape: const CircleBorder(),
//   child: InkWell(
//     customBorder: const CircleBorder(),
//     splashColor: Colors.white24,
//     highlightColor: Colors.white10,
//     onTap: () async {
//       if (status.uploaderUserId == null) return;

//       if (!status.isViewed) {
//         await context
//             .read<StatusController>()
//             .markStatusAsViewed(status.id);
//         widget.onViewed?.call();
//       }

//       final url = Uri.parse(
//         '${Backend.baseUrl}/provider/services/providers/${status.uploaderUserId}',
//       );

//       final res = await http.get(url);
//       if (res.statusCode != 200) return;

//       final data = jsonDecode(res.body)['provider'] ?? {};

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MyProfileScreen(
//             userData: data,
//             readOnly:
//                 widget.currentUserId != status.uploaderUserId,
//             currentUserId: widget.currentUserId,
//           ),
//         ),
//       );
//     },
//     child: Container(
//       padding: const EdgeInsets.all(2),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: status.isViewed
//               ? Colors.grey
//               : Colors.green,
//           width: 3,
//         ),
//       ),
//       child: CircleAvatar(
//         radius: 28,
//         backgroundColor: Colors.black45,
//         backgroundImage:
//             (status.uploaderAvatarUrl != null &&
//                     status.uploaderAvatarUrl!.isNotEmpty)
//                 ? NetworkImage(
//                     Backend.buildMediaUrl(
//                       status.uploaderAvatarUrl!,
//                     ),
//                   )
//                 : null,
//         child: (status.uploaderAvatarUrl == null ||
//                 status.uploaderAvatarUrl!.isEmpty)
//             ? const Icon(
//                 Icons.person,
//                 color: Colors.white,
//                 size: 28,
//               )
//             : null,
//       ),
//     ),
//   ),
// ),

//                               const SizedBox(height: 18),
//                               // Like button
//                               GestureDetector(
//                                 onTap: () async {
//                                   if (!status.isLikingInProgress) {
//                                     await context
//                                         .read<StatusController>()
//                                         .toggleLike(status);
//                                   }
//                                 },
//                                 child: Column(
//                                   children: [
//                                     AnimatedScale(
//                                       scale: status.isLikedByCurrentUser
//                                           ? 1.3
//                                           : 1.0,
//                                       duration: const Duration(
//                                         milliseconds: 200,
//                                       ),
//                                       child: Container(
//                                         padding: const EdgeInsets.all(8),
//                                         decoration: const BoxDecoration(
//                                           color: Colors.black45,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: Icon(
//                                           status.isLikedByCurrentUser
//                                               ? Icons.favorite
//                                               : Icons.favorite_border,
//                                           color: status.isLikedByCurrentUser
//                                               ? Colors.red
//                                               : Colors.white,
//                                           size: 32,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Text(
//                                       '${status.likeCount}',
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 14,
//                                         shadows: [
//                                           Shadow(
//                                             color: Colors.black54,
//                                             offset: Offset(1, 1),
//                                             blurRadius: 3,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               const SizedBox(height: 18),

//                               // Comment button
//                               Container(
//                                 decoration: const BoxDecoration(
//                                   color: Colors.black45,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: IconButton(
//                                   icon: const Icon(
//                                     Icons.comment,
//                                     color: Colors.white,
//                                     size: 28,
//                                   ),
//                                   onPressed: () {
//                                     showModalBottomSheet(
//                                       context: context,
//                                       isScrollControlled: true,
//                                       builder: (_) => StatusCommentsWidget(
//                                         statusId: status.id,
//                                         currentUserId: widget.currentUserId,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),

//                               const SizedBox(height: 18),

//                               // Add status button bottom-right
//                               if (widget.isProvider)
//                                 FloatingActionButton(
//                                   backgroundColor: kPrimaryColor,
//                                   onPressed: _openAddStatusDialog,
//                                   child: const Icon(
//                                     Icons.add,
//                                     color: kTextPrimary,
//                                     size: 28,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/status_widget.dart';
import '../helpers/backend.dart';
import 'MyProfileScreen.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/status_comments_widget.dart';
import '../helpers/coolors.dart';
import 'package:flutter/services.dart';

class StatusPage extends StatefulWidget {
  final int currentUserId;
  final bool isProvider;
  final VoidCallback? onViewed;
  const StatusPage({
    Key? key,
    required this.currentUserId,
    required this.isProvider,
    this.onViewed,
  }) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  late StatusController statusController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    statusController = StatusController(currentUserId: widget.currentUserId);
    statusController.fetchPublicStatuses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onViewed?.call();
    });
  }

  Future<void> _openAddStatusDialog() async {
    final picker = ImagePicker();
    XFile? pickedFile;
    String? type;

    // 🌆 Step 1: Pick Image or Video
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Status",
                style: TextStyle(
                  fontSize: 20,
                  color: kTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Choose what you want to share:",
                style: TextStyle(color: kTextSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      foregroundColor: kTextPrimary,
                    ),
                    icon: const Icon(Icons.image),
                    label: const Text("Image"),
                    onPressed: () async {
                      pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      type = 'image';
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      foregroundColor: kTextPrimary,
                    ),
                    icon: const Icon(Icons.videocam),
                    label: const Text("Video"),
                    onPressed: () async {
                      pickedFile = await picker.pickVideo(
                        source: ImageSource.gallery,
                      );
                      type = 'video';
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // 🚀 Step 2: Add Caption (Corrected for Keyboard)
    if (pickedFile != null && type != null) {
      TextEditingController captionController = TextEditingController();
      ValueNotifier<int> wordCount = ValueNotifier<int>(0);

      await showGeneralDialog(
        context: context,
        barrierDismissible: false,
        pageBuilder: (context, anim1, anim2) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              color: kSecondaryColor,
                              size: 26,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Add Caption",
                              style: TextStyle(
                                color: kTextPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // ... inside showGeneralDialog builder ...
                        ValueListenableBuilder<int>(
                          valueListenable: wordCount,
                          builder: (context, value, _) => TextField(
                            controller: captionController,
                            maxLines: 4,
                            maxLength: 2000, // Character limit safety
                            style: TextStyle(color: kTextPrimary),
                            decoration: InputDecoration(
                              hintText: "Write your caption...",
                              hintStyle: TextStyle(color: kTextSecondary),
                              filled: true,
                              counterText:
                                  "", // Hides the default character counter
                              fillColor: kCardColor.withOpacity(0.9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  "$value/300 words", // Your specific word limit
                                  style: TextStyle(
                                    color: value > 300
                                        ? Colors.red
                                        : kSecondaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            onChanged: (text) {
                              // Logic to count actual words
                              wordCount.value = text.trim().isEmpty
                                  ? 0
                                  : text.trim().split(RegExp(r'\s+')).length;
                            },
                          ),
                        ),
                        // ... rest of the code ...
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: kTextSecondary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSecondaryColor,
                                foregroundColor: kTextPrimary,
                              ),
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text("Upload"),
                              onPressed: () async {
                                Navigator.pop(context); // Close caption dialog
                                //  _showProgressDialog(context, statusController);

                                try {
                                  await statusController.uploadStatusWithMeta(
                                    pickedFile!.path,
                                    type!,
                                    captionController.text,
                                    true,
                                  );

                                  // Give user time to see the 100%
                                  await Future.delayed(
                                    const Duration(milliseconds: 800),
                                  );
                                } catch (e) {
                                  print("Upload error: $e");
                                } finally {
                                  if (mounted) {
                                    // 1. Close the Progress Dialog first
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop();

                                    // 2. WAIT for the closing animation to finish before resetting to 0%
                                    // This prevents the "jump" back to 0 while the circle is still on screen
                                    Future.delayed(
                                      const Duration(milliseconds: 300),
                                      () {
                                        statusController.uploadProgress.value =
                                            0.0;
                                      },
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  // // Separate helper for cleaner code
  // // 📍 Updated helper with controller parameter
  // void _showProgressDialog(BuildContext context, StatusController controller) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => PopScope(
  //       // 👑 canPop: false prevents the back button from closing the dialog while uploading
  //       canPop: false,
  //       onPopInvoked: (didPop) {
  //         if (didPop) return;
  //         // Optionally show a toast: "Please wait for upload to finish"
  //       },
  //       child: Center(
  //         child: ValueListenableBuilder<double>(
  //           valueListenable: controller.uploadProgress,
  //           builder: (context, progress, _) {
  //             return Container(
  //               padding: const EdgeInsets.all(25),
  //               decoration: BoxDecoration(
  //                 color: kCardColor,
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Stack(
  //                     alignment: Alignment.center,
  //                     children: [
  //                       CircularProgressIndicator(
  //                         value: progress.clamp(0.01, 1.0),
  //                         color: kPrimaryColor,
  //                         strokeWidth: 5,
  //                       ),
  //                       Text(
  //                         "${(progress * 100).toInt()}%",
  //                         style: TextStyle(
  //                           color: kTextPrimary,
  //                           fontSize: 10,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 15),
  //                   Text(
  //                     progress >= 1.0 ? "Uploaded ✅" : "Uploading...",
  //                     style: TextStyle(color: kTextPrimary),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: statusController,
      child: Scaffold(
        backgroundColor: kTextPrimary,
        body: Stack(
          children: [
            // 👑 Add this at the very top of the Stack
            ValueListenableBuilder<double>(
              valueListenable: statusController.uploadProgress,
              builder: (context, progress, _) {
                return progress > 0 && progress < 1.0
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          color: kPrimaryColor,
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            Consumer<StatusController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  );
                }

                final hasStatuses = controller.publicStatuses.isNotEmpty;

                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: hasStatuses ? controller.publicStatuses.length : 1,
                  onPageChanged: (index) {
                    final status = controller.publicStatuses[index];
                    if (!status.isViewed) {
                      controller.markStatusAsViewed(
                        status.id,
                      ); // ✅ Controller ka method call karo
                    }
                  },

                  itemBuilder: (context, index) {
                    if (!hasStatuses) {
                      // Empty state screen
                      return Stack(
                        children: [
                          Center(
                            child: Text(
                              "No status is uploaded yet",
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (widget.isProvider)
                            Positioned(
                              bottom: 30,
                              right: 20,
                              child: FloatingActionButton(
                                backgroundColor: kPrimaryColor,
                                onPressed: _openAddStatusDialog,
                                child: const Icon(
                                  Icons.add,
                                  color: kTextPrimary,
                                  size: 28,
                                ),
                              ),
                            ),
                        ],
                      );
                    }

                    final status = controller.publicStatuses[index];
                    final mediaUrl = Backend.buildMediaUrl(status.url);

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onDoubleTap: () async {
                              if (!status.isLikingInProgress) {
                                await context
                                    .read<StatusController>()
                                    .toggleLike(status);
                              }
                            },
                            child: status.type == 'image'
                                ? InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 1,
                                    maxScale: 4,
                                    child: Image.network(
                                      mediaUrl,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : VideoStatusViewer(url: mediaUrl),
                          ),
                        ),

                        // Top progress indicator placeholder
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),

                        // Caption & uploader name
                        if (status.caption != null ||
                            status.uploaderName != null)
                          // 📍 UPDATE THIS SECTION: Caption & uploader name
                          // 📍 UPDATE YOUR POSITIONED WIDGET HERE
                          Positioned(
                            left: 20,
                            bottom: 50,
                            right: 80, // Giving it a bit more width
                            child: StatefulBuilder(
                              builder: (context, setElementState) {
                                final String captionText = status.caption ?? "";
                                final bool isLongText = captionText.length > 60;

                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (status.uploaderName != null)
                                        Text(
                                          status.uploaderName!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      if (captionText.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () {
                                            if (isLongText) {
                                              setElementState(
                                                () => status.isExpanded =
                                                    !status.isExpanded,
                                              );
                                            }
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                captionText,
                                                // Removed the ?? false because isExpanded is non-nullable
                                                maxLines: status.isExpanded
                                                    ? 10
                                                    : 2,
                                                overflow: status.isExpanded
                                                    ? TextOverflow.visible
                                                    : TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              if (isLongText)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    status.isExpanded
                                                        ? "Show less"
                                                        : "Show more",
                                                    style: TextStyle(
                                                      color: kSecondaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        // Right side buttons
                        Positioned(
                          right: 20,
                          bottom: 50,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Profile button
                              Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  splashColor: Colors.white24,
                                  highlightColor: Colors.white10,
                                  onTap: () async {
                                    if (status.uploaderUserId == null) return;

                                    if (!status.isViewed) {
                                      await context
                                          .read<StatusController>()
                                          .markStatusAsViewed(status.id);
                                      widget.onViewed?.call();
                                    }

                                    final url = Uri.parse(
                                      '${Backend.baseUrl}/provider/services/providers/${status.uploaderUserId}',
                                    );

                                    final res = await http.get(url);
                                    if (res.statusCode != 200) return;

                                    final data =
                                        jsonDecode(res.body)['provider'] ?? {};

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MyProfileScreen(
                                          userData: data,
                                          readOnly:
                                              widget.currentUserId !=
                                              status.uploaderUserId,
                                          currentUserId: widget.currentUserId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: status.isViewed
                                            ? Colors.grey
                                            : Colors.green,
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.black45,
                                      backgroundImage:
                                          (status.uploaderAvatarUrl != null &&
                                              status
                                                  .uploaderAvatarUrl!
                                                  .isNotEmpty)
                                          ? NetworkImage(
                                              Backend.buildMediaUrl(
                                                status.uploaderAvatarUrl!,
                                              ),
                                            )
                                          : null,
                                      child:
                                          (status.uploaderAvatarUrl == null ||
                                              status.uploaderAvatarUrl!.isEmpty)
                                          ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 28,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),
                              // Like button
                              GestureDetector(
                                onTap: () async {
                                  if (!status.isLikingInProgress) {
                                    await context
                                        .read<StatusController>()
                                        .toggleLike(status);
                                  }
                                },
                                child: Column(
                                  children: [
                                    AnimatedScale(
                                      scale: status.isLikedByCurrentUser
                                          ? 1.3
                                          : 1.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          status.isLikedByCurrentUser
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: status.isLikedByCurrentUser
                                              ? Colors.red
                                              : Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${status.likeCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(1, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Comment button
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.comment,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) => StatusCommentsWidget(
                                        statusId: status.id,
                                        currentUserId: widget.currentUserId,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Add status button bottom-right
                              if (widget.isProvider)
                                FloatingActionButton(
                                  backgroundColor: kPrimaryColor,
                                  onPressed: _openAddStatusDialog,
                                  child: const Icon(
                                    Icons.add,
                                    color: kTextPrimary,
                                    size: 28,
                                  ),
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
          ],
        ),
      ),
    );
  }
}
