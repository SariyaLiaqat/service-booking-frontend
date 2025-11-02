// /////////////////////////////////

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
// import '../helpers/my_colors.dart';

// class StatusPage extends StatefulWidget {
//   final int currentUserId;
//   final bool isProvider;
// final VoidCallback? onViewed;
//   const StatusPage({
//     Key? key,
//     required this.currentUserId,
//     required this.isProvider,
//      this.onViewed,
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
//    WidgetsBinding.instance.addPostFrameCallback((_) {
//   widget.onViewed?.call();
// });
//   }

//   Future<void> _openAddStatusDialog() async {
//     final picker = ImagePicker();
//     XFile? pickedFile;
//     String? type;

//     // 🌆 Step 1: Pick Image or Video (Stylish Dialog)
//     await showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (_) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//         child: Container(
//           decoration: BoxDecoration(
//             color: MyColors.surface,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Add Status",
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: MyColors.textPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 "Choose what you want to share:",
//                 style: TextStyle(color: MyColors.textSecondary),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: MyColors.secondary,
//                       foregroundColor: MyColors.textPrimary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                     ),
//                     icon: const Icon(Icons.image, size: 22),
//                     label: const Text("Image"),
//                     onPressed: () async {
//                       pickedFile = await picker.pickImage(
//                         source: ImageSource.gallery,
//                       );
//                       type = 'image';
//                       if (Navigator.of(context).canPop())
//                         Navigator.of(context).pop();
//                     },
//                   ),
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: MyColors.secondary.withOpacity(0.9),
//                       foregroundColor: MyColors.textPrimary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                     ),
//                     icon: const Icon(Icons.videocam, size: 22),
//                     label: const Text("Video"),
//                     onPressed: () async {
//                       pickedFile = await picker.pickVideo(
//                         source: ImageSource.gallery,
//                       );
//                       type = 'video';
//                       if (Navigator.of(context).canPop())
//                         Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     // 🚀 Step 2: Add Caption (only if file chosen)
//     if (pickedFile != null && type != null) {
//       TextEditingController captionController = TextEditingController();

//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.symmetric(
//             horizontal: 24,
//             vertical: 24,
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: MyColors.surface,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.edit_note, color: MyColors.secondary, size: 26),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Add Caption",
//                       style: TextStyle(
//                         color: MyColors.textPrimary,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "You are going to upload a public story.",
//                   style: TextStyle(color: MyColors.textSecondary, fontSize: 14),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: captionController,
//                   maxLines: 3,

//                   textInputAction: TextInputAction.newline,
//                   style: TextStyle(color: MyColors.textPrimary),
//                   decoration: InputDecoration(
//                     hintText: "Write your caption...",
//                     hintStyle: TextStyle(color: MyColors.textSecondary),
//                     filled: true,
//                     fillColor: MyColors.surface.withOpacity(0.9),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(
//                         color: MyColors.secondary.withOpacity(0.4),
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide(
//                         color: MyColors.secondary,
//                         width: 1.5,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text(
//                         "Cancel",
//                         style: TextStyle(color: MyColors.textSecondary),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: MyColors.secondary,
//                         foregroundColor: MyColors.textPrimary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 12,
//                         ),
//                       ),
//                       icon: const Icon(Icons.cloud_upload, size: 20),
//                       label: const Text(
//                         "Upload",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       onPressed: () async {
//                         Navigator.of(context).pop(); // Close caption dialog

//                         // 🌠 Step 3: Upload progress dialog
//                         showDialog(
//                           context: context,
//                           barrierDismissible: false,
//                           builder: (_) => WillPopScope(
//                             onWillPop: () async => false,
//                             child: Dialog(
//                               backgroundColor: Colors.transparent,
//                               insetPadding: EdgeInsets.all(0),
//                               child: Center(
//                                 child: ValueListenableBuilder<double>(
//                                   valueListenable:
//                                       statusController.uploadProgress,
//                                   builder: (context, progress, _) {
//                                     if (progress >= 1.0) {
//                                       Future.delayed(
//                                         const Duration(seconds: 1),
//                                         () {
//                                           if (Navigator.of(
//                                             context,
//                                             rootNavigator: true,
//                                           ).canPop()) {
//                                             Navigator.of(
//                                               context,
//                                               rootNavigator: true,
//                                             ).pop();
//                                           }
//                                         },
//                                       );
//                                     }

//                                     return Container(
//                                       padding: const EdgeInsets.all(20),
//                                       decoration: BoxDecoration(
//                                         color: MyColors.surface,
//                                         borderRadius: BorderRadius.circular(16),
//                                       ),
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           CircularProgressIndicator(
//                                             value: progress.clamp(0.0, 1.0),
//                                             color: MyColors.secondary,
//                                           ),
//                                           const SizedBox(height: 12),
//                                           Text(
//                                             progress < 1.0
//                                                 ? "Uploading... ${(progress * 100).toStringAsFixed(0)}%"
//                                                 : "Upload Complete",
//                                             style: TextStyle(
//                                               color: MyColors.textPrimary,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );

//                         // 🌍 Step 4: Upload Logic (original intact)
//                         await statusController.uploadStatusWithMeta(
//                           pickedFile!.path,
//                           type!,
//                           captionController.text,
//                           true, // Always public
//                         );

//                         // ✅ Step 5: Reset and Close
//                         statusController.uploadProgress.value = 0.0;
//                         if (Navigator.of(
//                           context,
//                           rootNavigator: true,
//                         ).canPop()) {
//                           Navigator.of(context, rootNavigator: true).pop();
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: statusController,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             Consumer<StatusController>(
//               builder: (context, controller, _) {
//                 if (controller.isLoading) {
//                   // Agar abhi load ho raha hai
//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
//                   );
//                 }

//                 if (controller.publicStatuses.isEmpty) {
//                   // Agar load ho gaya aur list empty hai
//                   return Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           "No status is uploaded yet",
//                           style: TextStyle(color: Colors.white, fontSize: 18),
//                         ),
//                         const SizedBox(height: 20),
//                         if (widget.isProvider)
//                           Container(
//                             decoration: BoxDecoration(
//                               color: MyColors.secondary,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   spreadRadius: 2,
//                                 ),
//                               ],
//                             ),
//                             child: IconButton(
//                               icon: const Icon(
//                                 Icons.add,
//                                 color: MyColors.textPrimary,
//                                 size: 32,
//                               ),
//                               onPressed: _openAddStatusDialog,
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 }

//                 return PageView.builder(
//                   controller: _pageController,
//                   scrollDirection: Axis.vertical,
//                   itemCount: controller.publicStatuses.length,
//                  onPageChanged: (index) {
//   final status = controller.publicStatuses[index];
//   if (!status.isViewed) {
//     controller.markStatusAsViewed(status.id); // DB update
//     status.isViewed = true;                   // ✅ immediate client update
//     widget.onViewed?.call();                  // badge update
//   }
// },

//                   itemBuilder: (context, index) {
//                     final status = controller.publicStatuses[index];
//                     final mediaUrl = Backend.buildMediaUrl(status.url);
//                     return Stack(
//                       children: [
//                         Positioned.fill(
//                           child: GestureDetector(
//                             onDoubleTap: () async {
//                               if (status.isLikingInProgress) return;
//                               await context.read<StatusController>().toggleLike(
//                                 status,
//                               );
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

//                         Positioned(
//                           left: 20,
//                           bottom: 50,
//                           right: 100, // ensure text doesn't collide with icons
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors
//                                   .black54, // semi-transparent black background
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   status.uploaderName ?? "Unknown",
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                     shadows: [
//                                       Shadow(
//                                         color: Colors.black87,
//                                         offset: Offset(1, 1),
//                                         blurRadius: 2,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (status.caption != null &&
//                                     status.caption!.isNotEmpty)
//                                   GestureDetector(
//                                     onTap: () {
//                                       // Full caption dialog
//                                       showDialog(
//                                         context: context,
//                                         builder: (_) => AlertDialog(
//                                           backgroundColor: Colors.black87,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                           ),
//                                           content: Text(
//                                             status.caption!,
//                                             style: const TextStyle(
//                                               color: Colors.white70,
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                           actions: [
//                                             TextButton(
//                                               onPressed: () =>
//                                                   Navigator.of(context).pop(),
//                                               child: const Text(
//                                                 "Close",
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                     child: Text(
//                                       status.caption!,
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: const TextStyle(
//                                         color: Colors.white70,
//                                         fontSize: 16,
//                                         shadows: [
//                                           Shadow(
//                                             color: Colors.black87,
//                                             offset: Offset(1, 1),
//                                             blurRadius: 2,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         Positioned(
//                           right: 20,
//                           bottom: 50,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               // ❤️ Like Icon (Top)
//                               GestureDetector(
//                                 onTap: () async {
//                                   if (status.isLikingInProgress) return;
//   await context.read<StatusController>().toggleLike(status);

//                                   final prevLiked = status.isLikedByCurrentUser;
//                                   final prevCount = status.likeCount;

//                                   // 💨 Optimistic change
//                                   setState(() {
//                                     status.isLikedByCurrentUser = !prevLiked;
//                                     status.likeCount += prevLiked ? -1 : 1;
//                                   });

//                                   try {
//                                     await context
//                                         .read<StatusController>()
//                                         .toggleLike(status);
//                                   } catch (_) {
//                                     // ❌ Network error → revert
//                                     setState(() {
//                                       status.isLikedByCurrentUser = prevLiked;
//                                       status.likeCount = prevCount;
//                                     });
//                                   } finally {
//                                     status.isLikingInProgress = false;
//                                   }
//                                 },

//                                 child: AnimatedScale(
//                                   scale: status.isLikedByCurrentUser
//                                       ? 1.3
//                                       : 1.0,
//                                   duration: const Duration(milliseconds: 200),
//                                   child: Container(
//                                     padding: const EdgeInsets.all(8),
//                                     decoration: const BoxDecoration(
//                                       color: Colors.black45,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: Icon(
//                                       status.isLikedByCurrentUser
//                                           ? Icons.favorite
//                                           : Icons.favorite_border,
//                                       color: status.isLikedByCurrentUser
//                                           ? Colors.red
//                                           : Colors.white,
//                                       size: 32,
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               const SizedBox(height: 6),
//                               Text(
//                                 '${status.likeCount}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   shadows: [
//                                     Shadow(
//                                       color: Colors.black54,
//                                       offset: Offset(1, 1),
//                                       blurRadius: 3,
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               const SizedBox(height: 18),

//                               // 👤 Profile Icon (Middle)
//                             Container(
//   padding: const EdgeInsets.all(2), // circle ke liye thodi space
//   decoration: BoxDecoration(
//     shape: BoxShape.circle,
//     border: Border.all(
//       color: status.isViewed ? Colors.grey : Colors.green, // ✅ color logic
//       width: 3, // thickness of outer circle
//     ),
//   ),
//   child: CircleAvatar(
//     radius: 28,
//     backgroundColor: Colors.black45,
//     child: IconButton(
//       icon: const Icon(
//         Icons.person,
//         color: Colors.white,
//         size: 28,
//       ),
//       onPressed: () async {
//         try {
//           final uploaderId = status.uploaderUserId;
//           if (uploaderId == null) return;
//           // ✅ Mark status as viewed
//     if (!status.isViewed) {
//       setState(() {
//         status.isViewed = true;
//       });
//       // 🔹 Update unseen status count
//       widget.onViewed?.call();
//     }
//           final url = Uri.parse(
//             '${Backend.baseUrl}/provider/services/providers/$uploaderId',
//           );
//           final response = await http.get(url);
//           if (response.statusCode != 200) return;
//           final data = jsonDecode(response.body);
//           final providerDetails = data['provider'] ?? {};
//           final bool readOnly = widget.currentUserId != uploaderId;
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => MyProfileScreen(
//                 userData: providerDetails,
//                 readOnly: readOnly,
//                 currentUserId: widget.currentUserId,
//               ),
//             ),
//           );

//         } catch (_) {}
//       },
//     ),
//   ),
// ),

//                               const SizedBox(height: 18),

//                               // 💬 Comment Icon
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

//                               // ➕ Add Status (Bottom)
//                               if (widget.isProvider)
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: MyColors.secondary,
//                                     shape: BoxShape.circle,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.3),
//                                         blurRadius: 8,
//                                         spreadRadius: 2,
//                                       ),
//                                     ],
//                                   ),
//                                   child: IconButton(
//                                     icon: const Icon(
//                                       Icons.add,
//                                       color: MyColors.textPrimary,
//                                       size: 32,
//                                     ),
//                                     onPressed: _openAddStatusDialog,
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

/////////////////////////////////

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

    // 🌆 Step 1: Pick Image or Video (Stylish Dialog)
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
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
                      foregroundColor: kBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.image, size: 22),
                    label: const Text("Image"),
                    onPressed: () async {
                      pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      type = 'image';
                      if (Navigator.of(context).canPop())
                        Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor.withOpacity(0.9),
                      foregroundColor: kTextPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.videocam, size: 22),
                    label: const Text("Video"),
                    onPressed: () async {
                      pickedFile = await picker.pickVideo(
                        source: ImageSource.gallery,
                      );
                      type = 'video';
                      if (Navigator.of(context).canPop())
                        Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // 🚀 Step 2: Add Caption (only if file chosen)
    if (pickedFile != null && type != null) {
      TextEditingController captionController = TextEditingController();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note, color: kSecondaryColor, size: 26),
                    const SizedBox(width: 8),
                    Text(
                      "Add Caption",
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "You are going to upload a public story.",
                  style: TextStyle(color: kTextSecondary, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: captionController,
                  maxLines: 3,

                  textInputAction: TextInputAction.newline,
                  style: TextStyle(color: kTextPrimary),
                  decoration: InputDecoration(
                    hintText: "Write your caption...",
                    hintStyle: TextStyle(color: kTextSecondary),
                    filled: true,
                    fillColor: kCardColor.withOpacity(0.9),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: kSecondaryColor.withOpacity(0.4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: kSecondaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload, size: 20),
                      label: const Text(
                        "Upload",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close caption dialog

                        // 🌠 Step 3: Upload progress dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => WillPopScope(
                            onWillPop: () async => false,
                            child: Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.all(0),
                              child: Center(
                                child: ValueListenableBuilder<double>(
                                  valueListenable:
                                      statusController.uploadProgress,
                                  builder: (context, progress, _) {
                                    if (progress >= 1.0) {
                                      Future.delayed(
                                        const Duration(seconds: 1),
                                        () {
                                          if (Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).canPop()) {
                                            Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pop();
                                          }
                                        },
                                      );
                                    }

                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: kTextPrimary,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            value: progress.clamp(0.0, 1.0),
                                            color: kPrimaryColor,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            progress < 1.0
                                                ? "Uploading... ${(progress * 100).toStringAsFixed(0)}%"
                                                : "Upload Complete",
                                            style: TextStyle(
                                              color: kTextPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );

                        // 🌍 Step 4: Upload Logic (original intact)
                        await statusController.uploadStatusWithMeta(
                          pickedFile!.path,
                          type!,
                          captionController.text,
                          true, // Always public
                        );

                        // ✅ Step 5: Reset and Close
                        statusController.uploadProgress.value = 0.0;
                        if (Navigator.of(
                          context,
                          rootNavigator: true,
                        ).canPop()) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: statusController,
      child: Scaffold(
        backgroundColor: kTextPrimary,
        body: Stack(
          children: [
            Consumer<StatusController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  // Agar abhi load ho raha hai
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  );
                }

                if (controller.publicStatuses.isEmpty) {
                  // Agar load ho gaya aur list empty hai
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "No status is uploaded yet",
                          style: TextStyle(color: kTextSecondary, fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        if (widget.isProvider)
                          Container(
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: kCardColor,
                                size: 32,
                              ),
                              onPressed: _openAddStatusDialog,
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: controller.publicStatuses.length,
                  onPageChanged: (index) {
                    final status = controller.publicStatuses[index];
                    if (!status.isViewed) {
                      controller.markStatusAsViewed(status.id); // DB update
                      status.isViewed = true; // ✅ immediate client update
                      widget.onViewed?.call(); // badge update
                    }
                  },

                  itemBuilder: (context, index) {
                    final status = controller.publicStatuses[index];
                    final mediaUrl = Backend.buildMediaUrl(status.url);
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onDoubleTap: () async {
                              if (status.isLikingInProgress) return;
                              await context.read<StatusController>().toggleLike(
                                status,
                              );
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

                        Positioned(
                          left: 20,
                          bottom: 50,
                          right: 100, // ensure text doesn't collide with icons
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors
                                  .black54, // semi-transparent black background
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status.uploaderName ?? "Unknown",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black87,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                if (status.caption != null &&
                                    status.caption!.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      // Full caption dialog
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: Colors.black87,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          content: Text(
                                            status.caption!,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Text(
                                      status.caption!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black87,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          right: 20,
                          bottom: 50,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ❤️ Like Icon (Top)
                              GestureDetector(
                                onTap: () async {
                                  if (status.isLikingInProgress) return;
                                  await context
                                      .read<StatusController>()
                                      .toggleLike(status);

                                  final prevLiked = status.isLikedByCurrentUser;
                                  final prevCount = status.likeCount;

                                  // 💨 Optimistic change
                                  setState(() {
                                    status.isLikedByCurrentUser = !prevLiked;
                                    status.likeCount += prevLiked ? -1 : 1;
                                  });

                                  try {
                                    await context
                                        .read<StatusController>()
                                        .toggleLike(status);
                                  } catch (_) {
                                    // ❌ Network error → revert
                                    setState(() {
                                      status.isLikedByCurrentUser = prevLiked;
                                      status.likeCount = prevCount;
                                    });
                                  } finally {
                                    status.isLikingInProgress = false;
                                  }
                                },

                                child: AnimatedScale(
                                  scale: status.isLikedByCurrentUser
                                      ? 1.3
                                      : 1.0,
                                  duration: const Duration(milliseconds: 200),
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

                              const SizedBox(height: 18),

                              // 👤 Profile Icon (Middle)
                              Container(
                                padding: const EdgeInsets.all(
                                  2,
                                ), // circle ke liye thodi space
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: status.isViewed
                                        ? Colors.grey
                                        : Colors.green, // ✅ color logic
                                    width: 3, // thickness of outer circle
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.black45,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () async {
                                      try {
                                        final uploaderId =
                                            status.uploaderUserId;
                                        if (uploaderId == null) return;
                                        // ✅ Mark status as viewed
                                        if (!status.isViewed) {
                                          setState(() {
                                            status.isViewed = true;
                                          });
                                          // 🔹 Update unseen status count
                                          widget.onViewed?.call();
                                        }
                                        final url = Uri.parse(
                                          '${Backend.baseUrl}/provider/services/providers/$uploaderId',
                                        );
                                        final response = await http.get(url);
                                        if (response.statusCode != 200) return;
                                        final data = jsonDecode(response.body);
                                        final providerDetails =
                                            data['provider'] ?? {};
                                        final bool readOnly =
                                            widget.currentUserId != uploaderId;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MyProfileScreen(
                                              userData: providerDetails,
                                              readOnly: readOnly,
                                              currentUserId:
                                                  widget.currentUserId,
                                            ),
                                          ),
                                        );
                                      } catch (_) {}
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // 💬 Comment Icon
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

                              // ➕ Add Status (Bottom)
                              if (widget.isProvider)
                                Container(
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: kTextPrimary,
                                      size: 32,
                                    ),
                                    onPressed: _openAddStatusDialog,
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
