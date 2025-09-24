


// // ////////////////////////////////
// // ///
// // ///


// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/foundation.dart'; // ✅ for kIsWeb
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// // import '../helpers/backend.dart';
// // import 'my_tasks_screen.dart';

// // class TaskDetailPage extends StatefulWidget {
// //   final int currentUserId;
// //   final int providerId;
// //   final Map<String, dynamic> serviceData;

// //   const TaskDetailPage({
// //     Key? key,
// //     required this.currentUserId,
// //     required this.providerId,
// //     required this.serviceData,
// //   }) : super(key: key);

// //   @override
// //   State<TaskDetailPage> createState() => _TaskDetailPageState();
// // }

// // class _TaskDetailPageState extends State<TaskDetailPage> {
// //   DateTime? selectedDate;
// //   TextEditingController notesController = TextEditingController();
// //   final List<File> _attachments = [];

// //   Future<void> _pickDate() async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now().add(const Duration(days: 1)),
// //       firstDate: DateTime.now(),
// //       lastDate: DateTime.now().add(const Duration(days: 365)),
// //     );
// //     if (picked != null) {
// //       setState(() {
// //         selectedDate = picked;
// //       });
// //     }
// //   }

// //   Future<void> _pickImage() async {
// //     final picker = ImagePicker();
// //     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _attachments.add(File(pickedFile.path));
// //       });
// //     }
// //   }

// //   Future<void> _confirmBooking() async {
// //     if (selectedDate == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Please select a date 📅")),
// //       );
// //       return;
// //     }

// //     try {
// //       final request = http.MultipartRequest(
// //         "POST",
// //         Uri.parse("${Backend.baseUrl}/tasks"),
// //       );

// //       request.fields["user_id"] = widget.currentUserId.toString();
// //       request.fields["provider_id"] = widget.providerId.toString();
// //       request.fields["service_id"] = widget.serviceData['id'].toString();
// //       request.fields["scheduled_date"] = selectedDate!.toIso8601String();
// //       request.fields["notes"] = notesController.text;

// //       for (var file in _attachments) {
// //         request.files.add(await http.MultipartFile.fromPath(
// //           'attachments',
// //           file.path,
// //         ));
// //       }

// //       final response = await request.send();

// //       if (response.statusCode == 201) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("Booking Confirmed ✅")),
// //         );

// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => MyTasksScreen(
// //               currentUserId: widget.currentUserId,
// //               role: "user",
// //             ),
// //           ),
// //         );
// //       } else {
// //         final resBody = await response.stream.bytesToString();
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text("Booking failed ❌ $resBody")),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error: $e")),
// //       );
// //     }
// //   }

// //   // ✅ Universal Image Preview (Mobile + Web safe)
// //   Widget buildImagePreview(File file) {
// //     if (kIsWeb) {
// //       // Web ke liye file.path accessible nahi hota
// //       return Image.network(
// //         file.path,
// //         width: 100,
// //         height: 100,
// //         fit: BoxFit.cover,
// //         errorBuilder: (context, error, stackTrace) {
// //           return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
// //         },
// //       );
// //     } else {
// //       return Image.file(
// //         file,
// //         width: 100,
// //         height: 100,
// //         fit: BoxFit.cover,
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final service = widget.serviceData;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Task Details"),
// //         backgroundColor: Colors.teal,
// //         centerTitle: true,
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Service Info
// //             Card(
// //               color: Colors.teal.shade50,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: ListTile(
// //                 title: Text(
// //                   service['title'],
// //                   style: const TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 18,
// //                   ),
// //                 ),
// //                 subtitle: Text(
// //                   "PKR ${service['price']} • ${service['description'] ?? ''}",
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 20),

// //             // Date Picker
// //             ListTile(
// //               leading: const Icon(Icons.calendar_today, color: Colors.teal),
// //               title: const Text("Select Date"),
// //               subtitle: Text(
// //                 selectedDate != null
// //                     ? "${selectedDate!.toLocal()}".split(' ')[0]
// //                     : "No date selected",
// //               ),
// //               onTap: _pickDate,
// //             ),
// //             const Divider(),

// //             // Notes
// //             const Text("Notes / Requirements"),
// //             const SizedBox(height: 6),
// //             TextField(
// //               controller: notesController,
// //               maxLines: 3,
// //               decoration: InputDecoration(
// //                 hintText: "Write any additional notes...",
// //                 filled: true,
// //                 fillColor: Colors.grey.shade200,
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 20),

// //             // Attachments
// //             const Text(
// //               "Attachments",
// //               style: TextStyle(fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 10),
// //             Wrap(
// //               spacing: 8,
// //               runSpacing: 8,
// //               children: [
// //                 // Existing Attachments Preview
// //                 ..._attachments.map((file) {
// //                   return Stack(
// //                     children: [
// //                       ClipRRect(
// //                         borderRadius: BorderRadius.circular(8),
// //                         child: buildImagePreview(file), // ✅ FIXED
// //                       ),
// //                       Positioned(
// //                         top: 2,
// //                         right: 2,
// //                         child: GestureDetector(
// //                           onTap: () {
// //                             setState(() {
// //                               _attachments.remove(file);
// //                             });
// //                           },
// //                           child: Container(
// //                             decoration: const BoxDecoration(
// //                               color: Colors.black54,
// //                               shape: BoxShape.circle,
// //                             ),
// //                             padding: const EdgeInsets.all(4),
// //                             child: const Icon(
// //                               Icons.close,
// //                               size: 16,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   );
// //                 }).toList(),

// //                 // Add More Button
// //                 GestureDetector(
// //                   onTap: _pickImage,
// //                   child: Container(
// //                     width: 100,
// //                     height: 100,
// //                     decoration: BoxDecoration(
// //                       border: Border.all(color: Colors.teal),
// //                       borderRadius: BorderRadius.circular(8),
// //                       color: Colors.teal.withOpacity(0.05),
// //                     ),
// //                     child: const Icon(
// //                       Icons.add,
// //                       color: Colors.teal,
// //                       size: 30,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 30),

// //             // Confirm Button
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: _confirmBooking,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.teal,
// //                   padding: const EdgeInsets.symmetric(vertical: 14),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                 ),
// //                 child: const Text(
// //                   "Confirm Booking",
// //                   style: TextStyle(fontSize: 16),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }




















// ///////////////////////////////////////////////////////////




// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/foundation.dart'; // ✅ for kIsWeb
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// // import '../helpers/backend.dart';
// // import 'my_tasks_screen.dart';

// // class TaskDetailPage extends StatefulWidget {
// //   final int currentUserId;
// //   final int providerId;
// //   final Map<String, dynamic>? serviceData;
// //   final bool readOnly; // ✅ true for provider, false for user
// //   final Map<String, dynamic>? taskData; // ✅ for provider view

// //   const TaskDetailPage({
// //     Key? key,
// //     required this.currentUserId,
// //     required this.providerId,
// //     this.serviceData,
// //     this.readOnly = false,
// //     this.taskData,
// //   })  : assert((!readOnly && serviceData != null) || (readOnly && taskData != null),
// //             "Provide serviceData for user or taskData for provider"),
// //         super(key: key);

// //   @override
// //   State<TaskDetailPage> createState() => _TaskDetailPageState();
// // }

// // class _TaskDetailPageState extends State<TaskDetailPage> {
// //   DateTime? selectedDate;
// //   TextEditingController notesController = TextEditingController();
// //   final List<File> _attachments = [];
// //   final List<String> providerAttachments = []; // For provider view

// //   @override
// //   void initState() {
// //     super.initState();
// //     if (widget.readOnly && widget.taskData != null) {
// //       notesController.text = widget.taskData!['notes'] ?? '';
// //       selectedDate = DateTime.parse(widget.taskData!['scheduled_date']);
// //       if (widget.taskData!['attachments'] != null) {
// //         providerAttachments.addAll(List<String>.from(widget.taskData!['attachments']));
// //       }
// //     }
// //   }

// //   Future<void> _pickDate() async {
// //     if (widget.readOnly) return;
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now().add(const Duration(days: 1)),
// //       firstDate: DateTime.now(),
// //       lastDate: DateTime.now().add(const Duration(days: 365)),
// //     );
// //     if (picked != null) {
// //       setState(() {
// //         selectedDate = picked;
// //       });
// //     }
// //   }

// //   Future<void> _pickImage() async {
// //     if (widget.readOnly) return;
// //     final picker = ImagePicker();
// //     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _attachments.add(File(pickedFile.path));
// //       });
// //     }
// //   }

// //   Future<void> _confirmBooking() async {
// //     if (widget.readOnly) return;

// //     if (selectedDate == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Please select a date 📅")),
// //       );
// //       return;
// //     }

// //     try {
// //       final request = http.MultipartRequest(
// //         "POST",
// //         Uri.parse("${Backend.baseUrl}/tasks"),
// //       );

// //       request.fields["user_id"] = widget.currentUserId.toString();
// //       request.fields["provider_id"] = widget.providerId.toString();
// //       request.fields["service_id"] = widget.serviceData!['id'].toString();
// //       request.fields["scheduled_date"] = selectedDate!.toIso8601String();
// //       request.fields["notes"] = notesController.text;

// //       for (var file in _attachments) {
// //         request.files.add(await http.MultipartFile.fromPath(
// //           'attachments',
// //           file.path,
// //         ));
// //       }

// //       final response = await request.send();

// //       if (response.statusCode == 201) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("Booking Confirmed ✅")),
// //         );

// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => MyTasksScreen(
// //               currentUserId: widget.currentUserId,
// //               role: "user",
// //             ),
// //           ),
// //         );
// //       } else {
// //         final resBody = await response.stream.bytesToString();
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text("Booking failed ❌ $resBody")),
// //         );
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error: $e")),
// //       );
// //     }
// //   }

// //   Widget buildImagePreview(File file) {
// //     if (kIsWeb) {
// //       return Image.network(
// //         file.path,
// //         width: 100,
// //         height: 100,
// //         fit: BoxFit.cover,
// //         errorBuilder: (context, error, stackTrace) {
// //           return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
// //         },
// //       );
// //     } else {
// //       return Image.file(
// //         file,
// //         width: 100,
// //         height: 100,
// //         fit: BoxFit.cover,
// //       );
// //     }
// //   }

// //   Widget buildProviderAttachment(String url) {
// //     return Container(
// //       width: 100,
// //       height: 100,
// //       margin: const EdgeInsets.only(right: 8),
// //       child: Image.network(
// //         url,
// //         width: 100,
// //         height: 100,
// //         fit: BoxFit.cover,
// //         errorBuilder: (context, error, stackTrace) =>
// //             const Icon(Icons.broken_image, size: 50, color: Colors.grey),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final service = widget.readOnly ? widget.taskData! : widget.serviceData!;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Task Details"),
// //         backgroundColor: Colors.teal,
// //         centerTitle: true,
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Service Info
// //             Card(
// //               color: Colors.teal.shade50,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: ListTile(
// //                 title: Text(
// //                   service['title'] ?? service['service_title'] ?? '',
// //                   style: const TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 18,
// //                   ),
// //                 ),
// //                 subtitle: Text(
// //                   "PKR ${service['price'] ?? ''} • ${service['description'] ?? ''}",
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 20),

// //             // Date Picker
// //             ListTile(
// //               leading: const Icon(Icons.calendar_today, color: Colors.teal),
// //               title: const Text("Scheduled Date"),
// //               subtitle: Text(
// //                 selectedDate != null
// //                     ? "${selectedDate!.toLocal()}".split(' ')[0]
// //                     : "No date selected",
// //               ),
// //               onTap: _pickDate,
// //             ),
// //             const Divider(),

// //             // Notes
// //             const Text("Notes / Requirements"),
// //             const SizedBox(height: 6),
// //             TextField(
// //               controller: notesController,
// //               maxLines: 3,
// //               readOnly: widget.readOnly,
// //               decoration: InputDecoration(
// //                 hintText: "Write any additional notes...",
// //                 filled: true,
// //                 fillColor: widget.readOnly ? Colors.grey.shade300 : Colors.grey.shade200,
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 20),

// //             // Attachments
// //             const Text(
// //               "Attachments",
// //               style: TextStyle(fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 10),
// //             Wrap(
// //               spacing: 8,
// //               runSpacing: 8,
// //               children: [
// //                 if (!widget.readOnly)
// //                   ..._attachments.map((file) {
// //                     return Stack(
// //                       children: [
// //                         ClipRRect(
// //                           borderRadius: BorderRadius.circular(8),
// //                           child: buildImagePreview(file),
// //                         ),
// //                         Positioned(
// //                           top: 2,
// //                           right: 2,
// //                           child: GestureDetector(
// //                             onTap: () {
// //                               setState(() {
// //                                 _attachments.remove(file);
// //                               });
// //                             },
// //                             child: Container(
// //                               decoration: const BoxDecoration(
// //                                 color: Colors.black54,
// //                                 shape: BoxShape.circle,
// //                               ),
// //                               padding: const EdgeInsets.all(4),
// //                               child: const Icon(
// //                                 Icons.close,
// //                                 size: 16,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     );
// //                   }).toList(),
// //                 if (!widget.readOnly)
// //                   GestureDetector(
// //                     onTap: _pickImage,
// //                     child: Container(
// //                       width: 100,
// //                       height: 100,
// //                       decoration: BoxDecoration(
// //                         border: Border.all(color: Colors.teal),
// //                         borderRadius: BorderRadius.circular(8),
// //                         color: Colors.teal.withOpacity(0.05),
// //                       ),
// //                       child: const Icon(
// //                         Icons.add,
// //                         color: Colors.teal,
// //                         size: 30,
// //                       ),
// //                     ),
// //                   ),
// //                 if (widget.readOnly)
// //                   ...providerAttachments.map((url) => buildProviderAttachment(url)),
// //               ],
// //             ),
// //             const SizedBox(height: 30),

// //             // Confirm Button
// //             if (!widget.readOnly)
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: ElevatedButton(
// //                   onPressed: _confirmBooking,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.teal,
// //                     padding: const EdgeInsets.symmetric(vertical: 14),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                   child: const Text(
// //                     "Confirm Booking",
// //                     style: TextStyle(fontSize: 16),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }




// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart'; // ✅ for kIsWeb
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../helpers/backend.dart';
// import 'my_tasks_screen.dart';

// class TaskDetailPage extends StatefulWidget {
//   final int currentUserId;
//   final int providerId;
//   final Map<String, dynamic>? serviceData;
//   final bool readOnly; 
//   final Map<String, dynamic>? taskData;

//   const TaskDetailPage({
//     Key? key,
//     required this.currentUserId,
//     required this.providerId,
//     this.serviceData,
//     this.readOnly = false,
//     this.taskData,
//   })  : assert((!readOnly && serviceData != null) || (readOnly && taskData != null),
//             "Provide serviceData for user or taskData for provider"),
//         super(key: key);

//   @override
//   State<TaskDetailPage> createState() => _TaskDetailPageState();
// }

// class _TaskDetailPageState extends State<TaskDetailPage> {
//   DateTime? selectedDate;
//   TextEditingController notesController = TextEditingController();
//   final List<File> _attachments = [];
//   final List<String> providerAttachments = [];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.readOnly && widget.taskData != null) {
//       notesController.text = widget.taskData!['notes'] ?? '';
//       selectedDate = DateTime.parse(widget.taskData!['scheduled_date']);
//       if (widget.taskData!['attachments'] != null) {
//         providerAttachments.addAll(List<String>.from(widget.taskData!['attachments']));
//       }
//     }
//   }

//   Future<void> _pickDate() async {
//     if (widget.readOnly) return;
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.dark().copyWith(
//             colorScheme: const ColorScheme.dark(
//               primary: Colors.teal,
//               onPrimary: Colors.white,
//               surface: Color(0xFF1E1E1E),
//               onSurface: Colors.white70,
//             ),
//             dialogBackgroundColor: const Color(0xFF121212),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) setState(() => selectedDate = picked);
//   }

//   Future<void> _pickImage() async {
//     if (widget.readOnly) return;
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _attachments.add(File(pickedFile.path));
//       });
//     }
//   }

//   Future<void> _confirmBooking() async {
//     if (widget.readOnly) return;

//     if (selectedDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a date 📅")),
//       );
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         "POST",
//         Uri.parse("${Backend.baseUrl}/tasks"),
//       );

//       request.fields["user_id"] = widget.currentUserId.toString();
//       request.fields["provider_id"] = widget.providerId.toString();
//       request.fields["service_id"] = widget.serviceData!['id'].toString();
//       request.fields["scheduled_date"] = selectedDate!.toIso8601String();
//       request.fields["notes"] = notesController.text;

//       for (var file in _attachments) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'attachments',
//           file.path,
//         ));
//       }

//       final response = await request.send();

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Booking Confirmed ✅")),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MyTasksScreen(
//               currentUserId: widget.currentUserId,
//               role: "user",
//             ),
//           ),
//         );
//       } else {
//         final resBody = await response.stream.bytesToString();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Booking failed ❌ $resBody")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   Widget buildImagePreview(File file) {
//     if (kIsWeb) {
//       return Image.network(
//         file.path,
//         width: 100,
//         height: 100,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) =>
//             const Icon(Icons.broken_image, size: 50, color: Colors.grey),
//       );
//     } else {
//       return Image.file(
//         file,
//         width: 100,
//         height: 100,
//         fit: BoxFit.cover,
//       );
//     }
//   }

//   Widget buildProviderAttachment(String url) {
//     return Container(
//       width: 100,
//       height: 100,
//       margin: const EdgeInsets.only(right: 8),
//       child: Image.network(
//         url,
//         width: 100,
//         height: 100,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) =>
//             const Icon(Icons.broken_image, size: 50, color: Colors.grey),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final service = widget.readOnly ? widget.taskData! : widget.serviceData!;

//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       appBar: AppBar(
//         title: const Text("Task Details"),
//         backgroundColor: Colors.teal,
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Service Info
//             Card(
//               color: const Color(0xFF1E1E1E),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 title: Text(
//                   service['title'] ?? service['service_title'] ?? '',
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
//                 ),
//                 subtitle: Text(
//                   "PKR ${service['price'] ?? ''} • ${service['description'] ?? ''}",
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Date Picker
//             ListTile(
//               leading: const Icon(Icons.calendar_today, color: Colors.teal),
//               title: const Text("Scheduled Date", style: TextStyle(color: Colors.white70)),
//               subtitle: Text(
//                 selectedDate != null
//                     ? "${selectedDate!.toLocal()}".split(' ')[0]
//                     : "No date selected",
//                 style: const TextStyle(color: Colors.white70),
//               ),
//               onTap: _pickDate,
//             ),
//             const Divider(color: Colors.white24),

//             // Notes
//             const Text("Notes / Requirements", style: TextStyle(color: Colors.white70)),
//             const SizedBox(height: 6),
//             TextField(
//               controller: notesController,
//               maxLines: 3,
//               readOnly: widget.readOnly,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: "Write any additional notes...",
//                 hintStyle: const TextStyle(color: Colors.white54),
//                 filled: true,
//                 fillColor: widget.readOnly ? Colors.grey.shade800 : const Color(0xFF1E1E1E),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Attachments
//             const Text(
//               "Attachments",
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 if (!widget.readOnly)
//                   ..._attachments.map((file) {
//                     return Stack(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: buildImagePreview(file),
//                         ),
//                         Positioned(
//                           top: 2,
//                           right: 2,
//                           child: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _attachments.remove(file);
//                               });
//                             },
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                 color: Colors.black54,
//                                 shape: BoxShape.circle,
//                               ),
//                               padding: const EdgeInsets.all(4),
//                               child: const Icon(
//                                 Icons.close,
//                                 size: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 if (!widget.readOnly)
//                   GestureDetector(
//                     onTap: _pickImage,
//                     child: Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.teal),
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.teal.withOpacity(0.05),
//                       ),
//                       child: const Icon(
//                         Icons.add,
//                         color: Colors.teal,
//                         size: 30,
//                       ),
//                     ),
//                   ),
//                 if (widget.readOnly)
//                   ...providerAttachments.map((url) => buildProviderAttachment(url)),
//               ],
//             ),
//             const SizedBox(height: 30),

//             // Confirm Button
//             if (!widget.readOnly)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _confirmBooking,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Confirm Booking",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart'; // ✅ for kIsWeb
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../helpers/backend.dart';
// import 'my_tasks_screen.dart';

// class TaskDetailPage extends StatefulWidget {
//   final int currentUserId;
//   final int providerId;
//   final Map<String, dynamic>? serviceData;
//   final bool readOnly; 
//   final Map<String, dynamic>? taskData;

//   const TaskDetailPage({
//     Key? key,
//     required this.currentUserId,
//     required this.providerId,
//     this.serviceData,
//     this.readOnly = false,
//     this.taskData,
//   })  : assert((!readOnly && serviceData != null) || (readOnly && taskData != null),
//             "Provide serviceData for user or taskData for provider"),
//         super(key: key);

//   @override
//   State<TaskDetailPage> createState() => _TaskDetailPageState();
// }

// class _TaskDetailPageState extends State<TaskDetailPage> {
//   DateTime? selectedDate;
//   TextEditingController notesController = TextEditingController();
//   final List<File> _attachments = [];
//   final List<String> providerAttachments = [];
//   Map<String, dynamic> service = {};




//   @override
// void initState() {
//   super.initState();

//   if (widget.readOnly && widget.taskData != null) {
//     // Provider view
//     notesController.text = widget.taskData!['notes'] ?? '';
//     selectedDate = DateTime.parse(widget.taskData!['scheduled_date']);

//     // Attachments
//     if (widget.taskData!['attachments'] != null) {
//       providerAttachments.addAll(List<String>.from(widget.taskData!['attachments']));
//     }

//     // Service info from backend task
//     service = {
//       'title': widget.taskData!['service_title'] ?? 'Unknown Service',
//       'price': widget.taskData!['price']?.toString() ?? '0',
//       'description': widget.taskData!['description'] ?? '',
//     };
//   } else if (!widget.readOnly && widget.serviceData != null) {
//     // User booking a service
//     service = {
//       'title': widget.serviceData!['title'] ?? 'Unknown Service',
//       'price': widget.serviceData!['price']?.toString() ?? '0',
//       'description': widget.serviceData!['description'] ?? '',
//       'id': widget.serviceData!['id'], // needed for POST booking
//     };
//   } else {
//     // Fallback (should not happen due to assert)
//     service = {
//       'title': 'Unknown Service',
//       'price': '0',
//       'description': '',
//     };
//   }
// }





//   Future<void> _pickDate() async {
//     if (widget.readOnly) return;
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF2A3A69),
//               onPrimary: Colors.white,
//               surface: Color(0xFFD9E1F0),
//               onSurface: Color(0xFF5C74B1),
//             ),
//             dialogBackgroundColor: const Color(0xFFD9E1F0),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) setState(() => selectedDate = picked);
//   }

//   Future<void> _pickImage() async {
//     if (widget.readOnly) return;
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _attachments.add(File(pickedFile.path));
//       });
//     }
//   }





//   Future<void> _confirmBooking() async {
//     if (widget.readOnly) return;

//     if (selectedDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a date 📅")),
//       );
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         "POST",
//         Uri.parse("${Backend.baseUrl}/tasks"),
//       );

//       request.fields["user_id"] = widget.currentUserId.toString();
//       request.fields["provider_id"] = widget.providerId.toString();

//       request.fields["service_id"] = service['id'].toString();
//       request.fields["scheduled_date"] = selectedDate!.toIso8601String();
//       request.fields["notes"] = notesController.text;

//       for (var file in _attachments) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'attachments',
//           file.path,
//         ));
//       }

//       final response = await request.send();

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Booking Confirmed ✅")),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MyTasksScreen(
//               currentUserId: widget.currentUserId,
//               role: "user",
//             ),
//           ),
//         );
//       } else {
//         final resBody = await response.stream.bytesToString();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Booking failed ❌ $resBody")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   Widget buildImagePreview(File file) {
//     if (kIsWeb) {
//       return Image.network(
//         file.path,
//         width: 100,
//         height: 100,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) =>
//             const Icon(Icons.broken_image, size: 50, color: Color(0xFF5C74B1)),
//       );
//     } else {
//       return Image.file(
//         file,
//         width: 100,
//         height: 100,
//         fit: BoxFit.cover,
//       );
//     }
//   }

//   Widget buildProviderAttachment(String url) {
//     return Container(
//       width: 100,
//       height: 100,
//       margin: const EdgeInsets.only(right: 8),
//       child: Image.network(
//         url,
//         width: 100,
//         height: 100,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) =>
//             const Icon(Icons.broken_image, size: 50, color: Color(0xFF5C74B1)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF),
//       appBar: AppBar(
//         title: const Text("Task Details"),
//         backgroundColor: const Color(0xFF2A3A69),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Service Info
//             Card(
//               color: const Color(0xFFD9E1F0),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 title: Text(
//                   service['title'] ?? '',
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2A3A69)),
//                 ),
//                 subtitle: Text(
//                   "PKR ${service['price'] ?? ''} • ${service['description'] ?? ''}",
//                   style: const TextStyle(color: Color(0xFF5C74B1)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Date Picker
//             ListTile(
//               leading: const Icon(Icons.calendar_today, color: Color(0xFF2A3A69)),
//               title: const Text("Scheduled Date", style: TextStyle(color: Color(0xFF5C74B1))),
//               subtitle: Text(
//                 selectedDate != null
//                     ? "${selectedDate!.toLocal()}".split(' ')[0]
//                     : "No date selected",
//                 style: const TextStyle(color: Color(0xFF5C74B1)),
//               ),
//               onTap: _pickDate,
//             ),
//             const Divider(color: Color(0xFFD9E1F0)),

//             // Notes
//             const Text("Notes / Requirements", style: TextStyle(color: Color(0xFF5C74B1))),
//             const SizedBox(height: 6),
//             TextField(
//               controller: notesController,
//               maxLines: 3,
//               readOnly: widget.readOnly,
//               style: const TextStyle(color: Color(0xFF2A3A69)),
//               decoration: InputDecoration(
//                 hintText: "Write any additional notes...",
//                 hintStyle: const TextStyle(color: Color(0xFF5C74B1)),
//                 filled: true,
//                 fillColor: const Color(0xFFD9E1F0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Attachments
//             const Text(
//               "Attachments",
//               style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 if (!widget.readOnly)
//                   ..._attachments.map((file) {
//                     return Stack(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: buildImagePreview(file),
//                         ),
//                         Positioned(
//                           top: 2,
//                           right: 2,
//                           child: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _attachments.remove(file);
//                               });
//                             },
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                 color: Color(0xFFD9E1F0),
//                                 shape: BoxShape.circle,
//                               ),
//                               padding: const EdgeInsets.all(4),
//                               child: const Icon(
//                                 Icons.close,
//                                 size: 16,
//                                 color: Color(0xFF2A3A69),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 if (!widget.readOnly)
//                   GestureDetector(
//                     onTap: _pickImage,
//                     child: Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: const Color(0xFF2A3A69)),
//                         borderRadius: BorderRadius.circular(8),
//                         color: const Color(0xFF5C74B1).withOpacity(0.1),
//                       ),
//                       child: const Icon(
//                         Icons.add,
//                         color: Color(0xFF2A3A69),
//                         size: 30,
//                       ),
//                     ),
//                   ),
//                 if (widget.readOnly)
//                   ...providerAttachments.map((url) => buildProviderAttachment(url)),
//               ],
//             ),
//             const SizedBox(height: 30),

//             // Confirm Button
//             if (!widget.readOnly)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _confirmBooking,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2A3A69),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Confirm Booking",
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../helpers/backend.dart';
// import 'my_tasks_screen.dart';

// class TaskDetailPage extends StatefulWidget {
//   final int currentUserId;
//   final int providerId;
//   final bool readOnly;
//   final Map<String, dynamic>? taskData;
//   final Map<String, dynamic>? serviceData;
//   final List<Map<String, dynamic>>? providerServices;

//   const TaskDetailPage({
//     Key? key,
//     required this.currentUserId,
//     required this.providerId,
//     this.readOnly = false,
//     this.taskData,
//     this.serviceData,
//     this.providerServices,
//   })  : assert((!readOnly && serviceData != null) || (readOnly && taskData != null),
//             "Provide serviceData for user or taskData for provider"),
//         super(key: key);

//   @override
//   State<TaskDetailPage> createState() => _TaskDetailPageState();
// }

// class _TaskDetailPageState extends State<TaskDetailPage> {
//   DateTime? selectedDate;
//   TextEditingController notesController = TextEditingController();
//   final List<File> _attachments = [];
//   final List<String> providerAttachments = [];
//   Map<String, dynamic> service = {};
//   bool loadingServices = false;

//   // ✅ Local mutable copy of provider services
//   late List<Map<String, dynamic>> _providerServices;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize local services list
//     _providerServices = widget.providerServices != null
//         ? List<Map<String, dynamic>>.from(widget.providerServices!)
//         : [];

//     // Fetch provider services if user view and empty
//     if (!widget.readOnly && _providerServices.isEmpty) {
//       fetchProviderServices();
//     }

//     // Initialize service for user view
//     if (!widget.readOnly && _providerServices.isNotEmpty) {
//       service = {
//         'id': widget.serviceData?['id'] ?? _providerServices.first['id'],
//         'title': widget.serviceData?['title'] ?? _providerServices.first['title'],
//         'price': widget.serviceData?['price']?.toString() ?? _providerServices.first['price'].toString(),
//         'description': widget.serviceData?['description'] ?? _providerServices.first['description'],
//       };
//     }

//     // Provider read-only view
//     if (widget.readOnly && widget.taskData != null) {
//       notesController.text = widget.taskData!['notes'] ?? '';
//       try {
//         selectedDate = DateTime.parse(widget.taskData!['scheduled_date']);
//       } catch (_) {
//         selectedDate = null;
//       }

//       if (widget.taskData!['attachments'] != null) {
//         providerAttachments.addAll(
//           (widget.taskData!['attachments'] as List)
//               .map<String>((a) => Backend.baseUrl + "/" + a['file_path'])
//               .toList(),
//         );
//       }

//       service = {
//         'id': widget.taskData!['service_id'],
//         'title': widget.taskData!['service_title'] ?? 'Unknown Service',
//         'price': widget.taskData!['price']?.toString() ?? '0',
//         'description': widget.taskData!['description'] ?? '',
//       };
//     }
//   }

//   Future<void> fetchProviderServices() async {
//     setState(() => loadingServices = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/provider/${widget.providerId}/services');




//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _providerServices.clear();
//         _providerServices.addAll(List<Map<String, dynamic>>.from(data['services']));

//         if (!widget.readOnly && _providerServices.isNotEmpty && service.isEmpty) {
//           service = {
//             'id': _providerServices.first['id'],
//             'title': _providerServices.first['title'],
//             'price': _providerServices.first['price'].toString(),
//             'description': _providerServices.first['description'],
//           };
//         }
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Failed to fetch services ❌')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error fetching services: $e')));
//     } finally {
//       setState(() => loadingServices = false);
//     }
//   }

//   Future<void> _pickDate() async {
//     if (widget.readOnly) return;
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) => Theme(
//         data: ThemeData.light().copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF2A3A69),
//             onPrimary: Colors.white,
//             surface: Color(0xFFD9E1F0),
//             onSurface: Color(0xFF5C74B1),
//           ),
//           dialogBackgroundColor: const Color(0xFFD9E1F0),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) setState(() => selectedDate = picked);
//   }

//   Future<void> _pickImage() async {
//     if (widget.readOnly) return;
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _attachments.add(File(pickedFile.path)));
//     }
//   }

//   Future<void> _confirmBooking() async {
//     if (widget.readOnly) return;

//     if (selectedDate == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Please select a date 📅")));
//       return;
//     }

//     if (service['id'] == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Invalid service selected ❌")));
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         "POST",
//         Uri.parse("${Backend.baseUrl}/tasks"),
//       );

//       request.fields["user_id"] = widget.currentUserId.toString();
//       request.fields["provider_id"] = widget.providerId.toString();
//       request.fields["service_id"] = service['id'].toString();
//       request.fields["scheduled_date"] = selectedDate!.toIso8601String();
//       request.fields["notes"] = notesController.text;

//       for (var file in _attachments) {
//         request.files.add(await http.MultipartFile.fromPath('attachments', file.path));
//       }

//       final response = await request.send();

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text("Booking Confirmed ✅")));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MyTasksScreen(currentUserId: widget.currentUserId, role: "user"),
//           ),
//         );
//       } else {
//         final resBody = await response.stream.bytesToString();
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text("Booking failed ❌ $resBody")));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   Widget buildImagePreview(File file) {
//     if (kIsWeb) {
//       return FutureBuilder(
//           future: file.readAsBytes(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//               return Image.memory(snapshot.data as Uint8List,
//                   width: 100, height: 100, fit: BoxFit.cover);
//             }
//             return Container(
//               width: 100,
//               height: 100,
//               color: Colors.grey[200],
//               child: const Center(child: CircularProgressIndicator()),
//             );
//           });
//     } else {
//       return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
//     }
//   }

//   Widget buildProviderAttachment(String url) => Container(
//         width: 100,
//         height: 100,
//         margin: const EdgeInsets.only(right: 8),
//         child: Image.network(url, fit: BoxFit.cover),
//       );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Task Details"),
//         backgroundColor: const Color(0xFF2A3A69),
//         centerTitle: true,
//       ),
//       body: loadingServices && !widget.readOnly
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 // ------------------- Service -------------------
//                 if (!widget.readOnly)
//                   DropdownButtonFormField<int>(
//                     value: service['id'],
//                     items: _providerServices.map((s) {
//                       return DropdownMenuItem<int>(
//                         value: s['id'],
//                         child: Text("${s['title']} • PKR ${s['price']}"),
//                       );
//                     }).toList(),
//                     onChanged: (val) {
//                       final sel = _providerServices.firstWhere((s) => s['id'] == val);
//                       setState(() {
//                         service = {
//                           'id': sel['id'],
//                           'title': sel['title'],
//                           'price': sel['price'].toString(),
//                           'description': sel['description'],
//                         };
//                       });
//                     },
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: const Color(0xFFD9E1F0),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//                     ),
//                   )
//                 else
//                   Card(
//                     color: const Color(0xFFD9E1F0),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: ListTile(
//                       title: Text(service['title'] ?? '',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                               color: Color(0xFF2A3A69))),
//                       subtitle: Text(
//                           "PKR ${service['price'] ?? ''} • ${service['description'] ?? ''}",
//                           style: const TextStyle(color: Color(0xFF5C74B1))),
//                     ),
//                   ),
//                 const SizedBox(height: 20),

//                 // ------------------- Date Picker -------------------
//                 ListTile(
//                   leading: const Icon(Icons.calendar_today, color: Color(0xFF2A3A69)),
//                   title: const Text("Scheduled Date", style: TextStyle(color: Color(0xFF5C74B1))),
//                   subtitle: Text(selectedDate != null
//                       ? "${selectedDate!.toLocal()}".split(' ')[0]
//                       : "No date selected"),
//                   onTap: _pickDate,
//                 ),
//                 const Divider(color: Color(0xFFD9E1F0)),

//                 // ------------------- Notes -------------------
//                 const Text("Notes / Requirements", style: TextStyle(color: Color(0xFF5C74B1))),
//                 const SizedBox(height: 6),
//                 TextField(
//                   controller: notesController,
//                   maxLines: 3,
//                   readOnly: widget.readOnly,
//                   decoration: InputDecoration(
//                     hintText: "Write any additional notes...",
//                     filled: true,
//                     fillColor: const Color(0xFFD9E1F0),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // ------------------- Attachments -------------------
//                 const Text("Attachments",
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
//                 const SizedBox(height: 10),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     if (!widget.readOnly)
//                       ..._attachments.map((file) => Stack(
//                             children: [
//                               ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: buildImagePreview(file)),
//                               Positioned(
//                                 top: 2,
//                                 right: 2,
//                                 child: GestureDetector(
//                                   onTap: () => setState(() => _attachments.remove(file)),
//                                   child: Container(
//                                     decoration: const BoxDecoration(
//                                         color: Color(0xFFD9E1F0), shape: BoxShape.circle),
//                                     padding: const EdgeInsets.all(4),
//                                     child: const Icon(Icons.close, size: 16, color: Color(0xFF2A3A69)),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )),
//                     if (!widget.readOnly)
//                       GestureDetector(
//                         onTap: _pickImage,
//                         child: Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: const Color(0xFF2A3A69)),
//                             borderRadius: BorderRadius.circular(8),
//                             color: const Color(0xFF5C74B1).withOpacity(0.1),
//                           ),
//                           child: const Icon(Icons.add, color: Color(0xFF2A3A69), size: 30),
//                         ),
//                       ),
//                     if (widget.readOnly)
//                       ...providerAttachments.map((url) => buildProviderAttachment(url)),
//                   ],
//                 ),
//                 const SizedBox(height: 30),

//                 // ------------------- Confirm Button -------------------
//                 if (!widget.readOnly)
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _confirmBooking,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2A3A69),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text("Confirm Booking",
//                           style: TextStyle(fontSize: 16, color: Colors.white)),
//                     ),
//                   ),
//               ]),
//             ),
//     );
//   }
// }










// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../helpers/backend.dart';
// import 'my_tasks_screen.dart';

// class TaskDetailPage extends StatefulWidget {
//   final int currentUserId;
//   final int providerId;
//   final bool readOnly;
//   final Map<String, dynamic>? taskData;
//   final Map<String, dynamic>? serviceData;
//   final List<Map<String, dynamic>>? providerServices;

//   const TaskDetailPage({
//     Key? key,
//     required this.currentUserId,
//     required this.providerId,
//     this.readOnly = false,
//     this.taskData,
//     this.serviceData,
//     this.providerServices,
//   })  : assert(
//           // If readOnly → taskData must be present.
//           // If not readOnly → either serviceData OR providerServices must be present (providerServices may later be fetched).
//           (readOnly && taskData != null) ||
//               (!readOnly && (serviceData != null || providerServices != null)),
//           "Provide serviceData or providerServices for user view, or taskData for provider view",
//         ),
//         super(key: key);

//   @override
//   State<TaskDetailPage> createState() => _TaskDetailPageState();
// }

// class _TaskDetailPageState extends State<TaskDetailPage> {
//   DateTime? selectedDate;
//   TextEditingController notesController = TextEditingController();
//   final List<File> _attachments = [];
//   final List<String> providerAttachments = [];
//   Map<String, dynamic> service = {};
//   bool loadingServices = false;

//   // Local mutable copy of provider services
//   late List<Map<String, dynamic>> _providerServices;

//   // Keep a nullable selected service id (safe for Dropdown)
//   int? selectedServiceId;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize local services list from constructor if provided
//     _providerServices = widget.providerServices != null
//         ? List<Map<String, dynamic>>.from(widget.providerServices!)
//         : [];

//     // If a specific serviceData was passed (preselected), use it now
//     if (!widget.readOnly && widget.serviceData != null) {
//       service = {
//         'id': widget.serviceData!['id'],
//         'title': widget.serviceData!['title'],
//         'price': widget.serviceData!['price']?.toString() ?? '',
//         'description': widget.serviceData!['description'] ?? '',
//       };
//       selectedServiceId = widget.serviceData!['id'] is int
//           ? widget.serviceData!['id'] as int
//           : int.tryParse(widget.serviceData!['id'].toString());
//     }

//     // If providerServices were passed we can preselect the first (if service not already set)
//     if (!widget.readOnly && _providerServices.isNotEmpty && service.isEmpty) {
//       final first = _providerServices.first;
//       service = {
//         'id': first['id'],
//         'title': first['title'],
//         'price': first['price'].toString(),
//         'description': first['description'],
//       };
//       selectedServiceId = first['id'] is int ? first['id'] as int : int.tryParse(first['id'].toString());
//     }

//     // If we still have no provider services and not readOnly, fetch them from backend
//     if (!widget.readOnly && _providerServices.isEmpty) {
//       fetchProviderServices();
//     }

//     // Provider (read-only) view initialization
//     if (widget.readOnly && widget.taskData != null) {
//       notesController.text = widget.taskData!['notes'] ?? '';
//       try {
//         selectedDate = DateTime.parse(widget.taskData!['scheduled_date']);
//       } catch (_) {
//         selectedDate = null;
//       }

//       if (widget.taskData!['attachments'] != null) {
//         providerAttachments.addAll(
//           (widget.taskData!['attachments'] as List)
//               .map<String>((a) => Backend.baseUrl + "/" + a['file_path'])
//               .toList(),
//         );
//       }

//       service = {
//         'id': widget.taskData!['service_id'],
//         'title': widget.taskData!['service_title'] ?? 'Unknown Service',
//         'price': widget.taskData!['price']?.toString() ?? '0',
//         'description': widget.taskData!['description'] ?? '',
//       };
//       selectedServiceId = service['id'] is int ? service['id'] as int : int.tryParse(service['id'].toString() ?? '');
//     }
//   }

//   Future<void> fetchProviderServices() async {
//     setState(() => loadingServices = true);
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/provider/${widget.providerId}/services');

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // Defensive: ensure data['services'] exists and is a List
//         final List<dynamic> servicesRaw = (data != null && data['services'] is List) ? data['services'] : [];

//         _providerServices = servicesRaw.map<Map<String, dynamic>>((s) {
//           // ensure maps
//           return Map<String, dynamic>.from(s as Map);
//         }).toList();

//         // If nothing selected yet and we have services, pick first
//         if (!widget.readOnly && _providerServices.isNotEmpty && (service.isEmpty || selectedServiceId == null)) {
//           final first = _providerServices.first;
//           setState(() {
//             service = {
//               'id': first['id'],
//               'title': first['title'],
//               'price': first['price'].toString(),
//               'description': first['description'],
//             };
//             selectedServiceId = first['id'] is int ? first['id'] as int : int.tryParse(first['id'].toString());
//           });
//         }

//         // If service list is empty, let UI handle it (no crash)
//         if (_providerServices.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("No services available for this provider.")),
//           );
//         }
//       } else {
//         // Try to extract message from server for debugging
//         String serverMsg = '';
//         try {
//           final body = jsonDecode(response.body);
//           serverMsg = body['error'] ?? body['message'] ?? '';
//         } catch (_) {}
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Failed to fetch services ❌ ${serverMsg}')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error fetching services: $e')));
//     } finally {
//       setState(() => loadingServices = false);
//     }
//   }

//   Future<void> _pickDate() async {
//     if (widget.readOnly) return;
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) => Theme(
//         data: ThemeData.light().copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xFF2A3A69),
//             onPrimary: Colors.white,
//             surface: Color(0xFFD9E1F0),
//             onSurface: Color(0xFF5C74B1),
//           ),
//           dialogBackgroundColor: const Color(0xFFD9E1F0),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) setState(() => selectedDate = picked);
//   }

//   Future<void> _pickImage() async {
//     if (widget.readOnly) return;
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _attachments.add(File(pickedFile.path)));
//     }
//   }

//   Future<void> _confirmBooking() async {
//     if (widget.readOnly) return;

//     if (selectedDate == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Please select a date 📅")));
//       return;
//     }

//     if (selectedServiceId == null || service['id'] == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Invalid service selected ❌")));
//       return;
//     }

//     try {
//       final request = http.MultipartRequest(
//         "POST",
//         Uri.parse("${Backend.baseUrl}/tasks"),
//       );

//       request.fields["user_id"] = widget.currentUserId.toString();
//       request.fields["provider_id"] = widget.providerId.toString();
//       request.fields["service_id"] = selectedServiceId.toString();
//       request.fields["scheduled_date"] = selectedDate!.toIso8601String();
//       request.fields["notes"] = notesController.text;

//       for (var file in _attachments) {
//         request.files.add(await http.MultipartFile.fromPath('attachments', file.path));
//       }

//       final response = await request.send();

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text("Booking Confirmed ✅")));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MyTasksScreen(currentUserId: widget.currentUserId, role: "user"),
//           ),
//         );
//       } else {
//         final resBody = await response.stream.bytesToString();
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text("Booking failed ❌ $resBody")));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   Widget buildImagePreview(File file) {
//     if (kIsWeb) {
//       return FutureBuilder(
//           future: file.readAsBytes(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//               return Image.memory(snapshot.data as Uint8List,
//                   width: 100, height: 100, fit: BoxFit.cover);
//             }
//             return Container(
//               width: 100,
//               height: 100,
//               color: Colors.grey[200],
//               child: const Center(child: CircularProgressIndicator()),
//             );
//           });
//     } else {
//       return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
//     }
//   }

//   Widget buildProviderAttachment(String url) => Container(
//         width: 100,
//         height: 100,
//         margin: const EdgeInsets.only(right: 8),
//         child: Image.network(url, fit: BoxFit.cover),
//       );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Task Details"),
//         backgroundColor: const Color(0xFF2A3A69),
//         centerTitle: true,
//       ),
//       body: loadingServices && !widget.readOnly
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 // ------------------- Service -------------------
//                 if (!widget.readOnly)
//                   // If provider services list is empty, show a friendly message instead of a broken Dropdown
//                   (_providerServices.isEmpty
//                       ? Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFD9E1F0),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Text(
//                                 service.isNotEmpty
//                                     ? "${service['title']} • PKR ${service['price']}"
//                                     : "No services available",
//                                 style: const TextStyle(color: Color(0xFF2A3A69)),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             TextButton.icon(
//                               onPressed: fetchProviderServices,
//                               icon: const Icon(Icons.refresh),
//                               label: const Text("Refresh services"),
//                             ),
//                           ],
//                         )
//                       : DropdownButtonFormField<int?>(
//                           // allow null value safely
//                           value: selectedServiceId,
//                           items: _providerServices.map((s) {
//                             final int id = s['id'] is int ? s['id'] : int.tryParse(s['id'].toString()) ?? 0;
//                             final title = s['title'] ?? '';
//                             final price = s['price'] != null ? s['price'].toString() : '';
//                             return DropdownMenuItem<int>(
//                               value: id,
//                               child: Text("$title • PKR $price"),
//                             );
//                           }).toList(),
//                           onChanged: (val) {
//                             if (val == null) return;
//                             final sel = _providerServices.firstWhere((s) {
//                               final id = s['id'] is int ? s['id'] : int.tryParse(s['id'].toString());
//                               return id == val;
//                             }, orElse: () => {});
//                             if (sel.isEmpty) return;
//                             setState(() {
//                               selectedServiceId = val;
//                               service = {
//                                 'id': sel['id'],
//                                 'title': sel['title'],
//                                 'price': sel['price'].toString(),
//                                 'description': sel['description'],
//                               };
//                             });
//                           },
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: const Color(0xFFD9E1F0),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//                           ),
//                         ))
//                 else
//                   Card(
//                     color: const Color(0xFFD9E1F0),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: ListTile(
//                       title: Text(service['title'] ?? '',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                               color: Color(0xFF2A3A69))),
//                       subtitle: Text(
//                           "PKR ${service['price'] ?? ''} • ${service['description'] ?? ''}",
//                           style: const TextStyle(color: Color(0xFF5C74B1))),
//                     ),
//                   ),
//                 const SizedBox(height: 20),

//                 // ------------------- Date Picker -------------------
//                 ListTile(
//                   leading: const Icon(Icons.calendar_today, color: Color(0xFF2A3A69)),
//                   title: const Text("Scheduled Date", style: TextStyle(color: Color(0xFF5C74B1))),
//                   subtitle: Text(selectedDate != null
//                       ? "${selectedDate!.toLocal()}".split(' ')[0]
//                       : "No date selected"),
//                   onTap: _pickDate,
//                 ),
//                 const Divider(color: Color(0xFFD9E1F0)),

//                 // ------------------- Notes -------------------
//                 const Text("Notes / Requirements", style: TextStyle(color: Color(0xFF5C74B1))),
//                 const SizedBox(height: 6),
//                 TextField(
//                   controller: notesController,
//                   maxLines: 3,
//                   readOnly: widget.readOnly,
//                   decoration: InputDecoration(
//                     hintText: "Write any additional notes...",
//                     filled: true,
//                     fillColor: const Color(0xFFD9E1F0),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // ------------------- Attachments -------------------
//                 const Text("Attachments",
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
//                 const SizedBox(height: 10),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     if (!widget.readOnly)
//                       ..._attachments.map((file) => Stack(
//                             children: [
//                               ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: buildImagePreview(file)),
//                               Positioned(
//                                 top: 2,
//                                 right: 2,
//                                 child: GestureDetector(
//                                   onTap: () => setState(() => _attachments.remove(file)),
//                                   child: Container(
//                                     decoration: const BoxDecoration(
//                                         color: Color(0xFFD9E1F0), shape: BoxShape.circle),
//                                     padding: const EdgeInsets.all(4),
//                                     child: const Icon(Icons.close, size: 16, color: Color(0xFF2A3A69)),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )),
//                     if (!widget.readOnly)
//                       GestureDetector(
//                         onTap: _pickImage,
//                         child: Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: const Color(0xFF2A3A69)),
//                             borderRadius: BorderRadius.circular(8),
//                             color: const Color(0xFF5C74B1).withOpacity(0.1),
//                           ),
//                           child: const Icon(Icons.add, color: Color(0xFF2A3A69), size: 30),
//                         ),
//                       ),
//                     if (widget.readOnly)
//                       ...providerAttachments.map((url) => buildProviderAttachment(url)),
//                   ],
//                 ),
//                 const SizedBox(height: 30),

//                 // ------------------- Confirm Button -------------------
//                 if (!widget.readOnly)
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: (_providerServices.isEmpty || selectedServiceId == null) ? null : _confirmBooking,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: (_providerServices.isEmpty || selectedServiceId == null)
//                             ? Colors.grey
//                             : const Color(0xFF2A3A69),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text("Confirm Booking",
//                           style: TextStyle(fontSize: 16, color: Colors.white)),
//                     ),
//                   ),
//               ]),
//             ),
//     );
//   }
// }



import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../helpers/backend.dart';
import 'my_tasks_screen.dart';

class TaskDetailPage extends StatefulWidget {
  final int currentUserId;
  final int providerId;
  final bool readOnly;
  final Map<String, dynamic>? taskData;
  final Map<String, dynamic>? serviceData;
  final List<Map<String, dynamic>>? providerServices;

  const TaskDetailPage({
    Key? key,
    required this.currentUserId,
    required this.providerId,
    this.readOnly = false,
    this.taskData,
    this.serviceData,
    this.providerServices,
  })  : assert(
          (readOnly && taskData != null) ||
              (!readOnly && (serviceData != null || providerServices != null)),
          "Provide serviceData/providerServices for user, or taskData for provider view",
        ),
        super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  DateTime? selectedDate;
  final TextEditingController notesController = TextEditingController();
  final List<File> _attachments = [];
  final List<String> providerAttachments = [];
  Map<String, dynamic> service = {};
  bool loadingServices = false;

  late List<Map<String, dynamic>> _providerServices;
  int? selectedServiceId;

  @override
  void initState() {
    super.initState();

    _providerServices = widget.providerServices != null
        ? List<Map<String, dynamic>>.from(widget.providerServices!)
        : [];

    // If user passed a preselected service
    if (!widget.readOnly && widget.serviceData != null) {
      _setService(widget.serviceData!);
    }

    // If provider services were passed but no service set, pick first
    if (!widget.readOnly && _providerServices.isNotEmpty && service.isEmpty) {
      _setService(_providerServices.first);
    }

    // If no services at all → fetch
    if (!widget.readOnly && _providerServices.isEmpty) {
      fetchProviderServices();
    }

    // ReadOnly (provider side)
    if (widget.readOnly && widget.taskData != null) {
      notesController.text = widget.taskData!['notes'] ?? '';
      try {
        selectedDate = DateTime.parse(widget.taskData!['scheduled_date']);
      } catch (_) {}

      if (widget.taskData!['attachments'] != null) {
        providerAttachments.addAll(
          (widget.taskData!['attachments'] as List)
              .map<String>((a) => Backend.baseUrl + "/" + a['file_path'])
              .toList(),
        );
      }

      _setService({
        'id': widget.taskData!['service_id'],
        'title': widget.taskData!['service_title'] ?? 'Unknown Service',
        'price': widget.taskData!['price']?.toString() ?? '0',
        'description': widget.taskData!['description'] ?? '',
      });
    }
  }

  void _setService(Map<String, dynamic> s) {
    setState(() {
      service = {
        'id': s['id'],
        'title': s['title'],
        'price': s['price']?.toString() ?? '',
        'description': s['description'] ?? '',
      };
      selectedServiceId = s['id'] is int ? s['id'] : int.tryParse(s['id'].toString());
    });
  }

  Future<void> fetchProviderServices() async {
    setState(() => loadingServices = true);
    try {
      final url = Uri.parse('${Backend.baseUrl}/provider/${widget.providerId}/services');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> servicesRaw = data['services'] is List ? data['services'] : [];

        _providerServices = servicesRaw.map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s)).toList();

        if (_providerServices.isNotEmpty && (service.isEmpty || selectedServiceId == null)) {
          _setService(_providerServices.first);
        }

        if (_providerServices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No services available for this provider.")),
          );
        }
      } else {
        String msg = "";
        try {
          msg = jsonDecode(response.body)['error'] ?? "";
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch services ❌ $msg")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching services: $e")),
      );
    } finally {
      setState(() => loadingServices = false);
    }
  }

  Future<void> _pickDate() async {
    if (widget.readOnly) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickImage() async {
    if (widget.readOnly) return;
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _attachments.add(File(pickedFile.path)));
  }

  Future<void> _confirmBooking() async {
    FocusScope.of(context).unfocus(); // close keyboard

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date 📅")),
      );
      return;
    }
    if (selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid service ❌")),
      );
      return;
    }

    try {
      final request = http.MultipartRequest("POST", Uri.parse("${Backend.baseUrl}/tasks"))
        ..fields["user_id"] = widget.currentUserId.toString()
        ..fields["provider_id"] = widget.providerId.toString()
        ..fields["service_id"] = selectedServiceId.toString()
        ..fields["scheduled_date"] = selectedDate!.toIso8601String()
        ..fields["notes"] = notesController.text;

      for (var file in _attachments) {
        request.files.add(await http.MultipartFile.fromPath('attachments', file.path));
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking Confirmed ✅")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyTasksScreen(currentUserId: widget.currentUserId, role: "user"),
          ),
        );
      } else {
        String msg = "";
        try {
          msg = jsonDecode(resBody)['error'] ?? resBody;
        } catch (_) {
          msg = resBody;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed ❌ $msg")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Widget buildImagePreview(File file) {
    if (kIsWeb) {
      return FutureBuilder(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return Image.memory(snapshot.data as Uint8List,
                width: 100, height: 100, fit: BoxFit.cover);
          }
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
    }
  }

  Widget buildProviderAttachment(String url) => Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        child: Image.network(url, fit: BoxFit.cover),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        backgroundColor: const Color(0xFF2A3A69),
        centerTitle: true,
      ),
      body: loadingServices && !widget.readOnly
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------- Service -------------------
                  if (!widget.readOnly)
                    (_providerServices.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoBox(
                                service.isNotEmpty
                                    ? "${service['title']} • PKR ${service['price']}"
                                    : "No services available",
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: fetchProviderServices,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Refresh services"),
                              ),
                            ],
                          )
                        : DropdownButtonFormField<int?>(
                            value: selectedServiceId,
                            items: _providerServices.map((s) {
                              final id = s['id'] is int ? s['id'] : int.tryParse(s['id'].toString()) ?? 0;
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text("${s['title']} • PKR ${s['price']}"),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              final sel = _providerServices.firstWhere(
                                (s) => (s['id'] is int ? s['id'] : int.tryParse(s['id'].toString())) == val,
                                orElse: () => {},
                              );
                              if (sel.isEmpty) return;
                              _setService(sel);
                            },
                            decoration: _dropdownDecoration(),
                          ))
                  else
                    _infoBox(
                        "${service['title'] ?? ''} • PKR ${service['price'] ?? ''}\n${service['description'] ?? ''}"),

                  const SizedBox(height: 20),

                  // ------------------- Date Picker -------------------
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Color(0xFF2A3A69)),
                    title: const Text("Scheduled Date", style: TextStyle(color: Color(0xFF5C74B1))),
                    subtitle: Text(
                      selectedDate != null
                          ? "${selectedDate!.toLocal()}".split(' ')[0]
                          : "No date selected",
                    ),
                    onTap: _pickDate,
                  ),
                  const Divider(color: Color(0xFFD9E1F0)),

                  // ------------------- Notes -------------------
                  const Text("Notes / Requirements", style: TextStyle(color: Color(0xFF5C74B1))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    readOnly: widget.readOnly,
                    decoration: _inputDecoration("Write any additional notes..."),
                  ),
                  const SizedBox(height: 20),

                  // ------------------- Attachments -------------------
                  const Text("Attachments",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (!widget.readOnly)
                        ..._attachments.map((file) => Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: buildImagePreview(file)),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _attachments.remove(file)),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFD9E1F0), shape: BoxShape.circle),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close, size: 16, color: Color(0xFF2A3A69)),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      if (!widget.readOnly)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF2A3A69)),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF5C74B1).withOpacity(0.1),
                            ),
                            child: const Icon(Icons.add, color: Color(0xFF2A3A69), size: 30),
                          ),
                        ),
                      if (widget.readOnly)
                        ...providerAttachments.map((url) => buildProviderAttachment(url)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ------------------- Confirm Button -------------------
                  if (!widget.readOnly)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_providerServices.isEmpty || selectedServiceId == null)
                            ? null
                            : _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_providerServices.isEmpty || selectedServiceId == null)
                              ? Colors.grey
                              : const Color(0xFF2A3A69),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Confirm Booking",
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _infoBox(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9E1F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xFF2A3A69))),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFD9E1F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );

  InputDecoration _dropdownDecoration() => InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD9E1F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );
}
