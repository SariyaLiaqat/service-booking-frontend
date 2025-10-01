
// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../helpers/backend.dart';
// import 'my_tasks_screen.dart';
// import 'full_scree.dart';
// import 'chat_page.dart';

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
//   }) : assert(
//          (readOnly && taskData != null) ||
//              (!readOnly && (serviceData != null || providerServices != null)),
//          "Provide serviceData/providerServices for user, or taskData for provider view",
//        ),
//        super(key: key);

//   @override
//   State<TaskDetailPage> createState() => _TaskDetailPageState();
// }

// class _TaskDetailPageState extends State<TaskDetailPage> {
//   DateTime? selectedDate;
//   final TextEditingController notesController = TextEditingController();
//   final TextEditingController headingController = TextEditingController();
//   final TextEditingController imageDetailsController = TextEditingController();
//   final List<File> _attachments = [];
//   final List<String> providerAttachments = [];
//   Map<String, dynamic> service = {};
//   bool loadingServices = false;
//   late List<Map<String, dynamic>> _providerServices;
//   int? selectedServiceId;

//   @override
//   void initState() {
//     super.initState();

//     _providerServices = widget.providerServices != null
//         ? List<Map<String, dynamic>>.from(widget.providerServices!)
//         : [];

//     headingController.text = widget.taskData?['title'] ?? "Enter task title";

//     // Provider view (readOnly)
//     // Provider view (readOnly)
//     if (widget.readOnly && widget.taskData != null) {
//       final t = widget.taskData!;
//       headingController.text = t['title'] ?? t['service_title'];
//       notesController.text = t['notes'] ?? t['description'] ?? '';
//       imageDetailsController.text = t['attachment_details'] ?? '';
//       try {
//         selectedDate = DateTime.parse(t['scheduled_date']);
//       } catch (_) {}

//       // ✅ Fix for attachments
//       if (t['attachments'] != null) {
//         providerAttachments.clear();
//         for (var a in t['attachments']) {
//           final path = a['file_path']?.toString() ?? "";
//           if (path.isNotEmpty) {
//             final fullUrl = path.startsWith("http")
//                 ? path
//                 : "${Backend.baseUrl}/$path";
//             providerAttachments.add(fullUrl);
//           }
//         }
//       }

//       _setService({
//         'id': t['service_id'],
//         'title': t['service_title'] ?? 'Unknown Service',
//         'price': t['price']?.toString() ?? '0',
//         'description': t['description'] ?? '',
//       });
//     }

//     // User view: set serviceData if available
//     if (!widget.readOnly && widget.serviceData != null) {
//       _setService(widget.serviceData!);
//     }

//     // If provider services exist but no service selected, pick first
//     if (!widget.readOnly && _providerServices.isNotEmpty && service.isEmpty) {
//       _setService(_providerServices.first);
//     }

//     // If no services → fetch
//     if (!widget.readOnly && _providerServices.isEmpty) {
//       fetchProviderServices();
//     }
//   }

//   void _setService(Map<String, dynamic> s) {
//     setState(() {
//       service = {
//         'id': s['id'],
//         'title': s['title'] ?? '',
//         'price': s['price']?.toString() ?? '',
//         'description': s['description'] ?? '',
//       };
//       selectedServiceId = s['id'] is int
//           ? s['id']
//           : int.tryParse(s['id'].toString());
//     });
//   }

//   Future<void> fetchProviderServices() async {
//     setState(() => loadingServices = true);
//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/provider/${widget.providerId}/services',
//       );
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> servicesRaw = data['services'] is List
//             ? data['services']
//             : [];

//         _providerServices = servicesRaw
//             .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s))
//             .toList();

//         if (_providerServices.isNotEmpty &&
//             (service.isEmpty || selectedServiceId == null)) {
//           _setService(_providerServices.first);
//         }

//         if (_providerServices.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("No services available for this provider."),
//             ),
//           );
//         }
//       } else {
//         String msg = "";
//         try {
//           msg = jsonDecode(response.body)['error'] ?? "";
//         } catch (_) {}
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to fetch services ❌ $msg")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error fetching services: $e")));
//     } finally {
//       setState(() => loadingServices = false);
//     }
//   }

//   /////
//   Future<void> createTaskWithAttachments({
//     required int userId,
//     required int providerId,
//     required int serviceId,
//     required DateTime scheduledDate,
//     required String notes,
//     String? attachmentDetails,
//     required List<File> attachments,
//     required BuildContext context,
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${Backend.baseUrl}/tasks'),
//       );

//       // ⚡ Task fields
//       request.fields['user_id'] = userId.toString();
//       request.fields['provider_id'] = providerId.toString();
//       request.fields['service_id'] = serviceId.toString();
//       request.fields['scheduled_date'] = scheduledDate.toIso8601String();
//       request.fields['notes'] = notes;
//       request.fields['attachment_details'] = attachmentDetails ?? '';
//       request.fields['title'] = headingController.text;

//       // ⚡ Add attachments
//       for (var file in attachments) {
//         request.files.add(
//           await http.MultipartFile.fromPath('attachments', file.path),
//         );
//       }

//       // ⚡ Send request
//       var response = await request.send();

//       if (response.statusCode == 201) {
//         final resBody = await response.stream.bytesToString();
//         final data = jsonDecode(resBody);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Task created successfully ✅")),
//         );

//         print("Task created: ${data['task']}");
//         // ✅ Ab aap data['task']['attachments'] me files dekh sakte ho
//       } else {
//         final resBody = await response.stream.bytesToString();
//         print("Failed to create task: $resBody");
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Failed to create task ❌")));
//       }
//     } catch (e) {
//       print("Error: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   Future<void> _pickDate() async {
//     if (widget.readOnly) return;

//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );

//     if (pickedDate != null) {
//       final pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );

//       if (pickedTime != null) {
//         setState(() {
//           selectedDate = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         });
//       }
//     }
//   }

//   Future<void> _pickImage() async {
//     if (widget.readOnly) return;
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null)
//       setState(() => _attachments.add(File(pickedFile.path)));
//   }

//   Future<void> _confirmBooking() async {
//     FocusScope.of(context).unfocus();

//     if (selectedDate == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please select a date 📅")));
//       return;
//     }

//     if (selectedServiceId == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Invalid service ❌")));
//       return;
//     }

//     try {
//       // ⚡ Call helper function to create task with attachments
//       await createTaskWithAttachments(
//         userId: widget.currentUserId,
//         providerId: widget.providerId,
//         serviceId: selectedServiceId!,
//         scheduledDate: selectedDate!,
//         notes: notesController.text,
//         attachmentDetails: imageDetailsController.text,
//         attachments: _attachments,
//         context: context,
//       );

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Booking Confirmed ✅")));

//       // Navigate to MyTasksScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) =>
//               MyTasksScreen(currentUserId: widget.currentUserId, role: "user"),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   @override
//   void dispose() {
//     notesController.dispose();
//     headingController.dispose();
//     imageDetailsController.dispose();
//     super.dispose();
//   }

//   Widget buildImagePreview(File file) {
//     if (kIsWeb) {
//       return FutureBuilder(
//         future: file.readAsBytes(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done &&
//               snapshot.hasData) {
//             return Image.memory(
//               snapshot.data as Uint8List,
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//             );
//           }
//           return Container(
//             width: 100,
//             height: 100,
//             color: Colors.grey[200],
//             child: const Center(child: CircularProgressIndicator()),
//           );
//         },
//       );
//     } else {
//       return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
//     }
//   }

//   Widget buildProviderAttachment(String url) {
//     final lower = url.toLowerCase();
//     Widget content;

//     if (lower.endsWith(".jpg") ||
//         lower.endsWith(".jpeg") ||
//         lower.endsWith(".png") ||
//         lower.endsWith(".gif")) {
//       content = Image.network(url, width: 100, height: 100, fit: BoxFit.cover);
//     } else {
//       content = Container(
//         width: 100,
//         height: 100,
//         color: Colors.grey[300],
//         child: const Icon(
//           Icons.insert_drive_file,
//           size: 40,
//           color: Colors.black54,
//         ),
//       );
//     }

//     return GestureDetector(
//       onTap:
//           lower.endsWith(".jpg") ||
//               lower.endsWith(".jpeg") ||
//               lower.endsWith(".png") ||
//               lower.endsWith(".gif")
//           ? () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => FullScreenImage(url: url)),
//               );
//             }
//           : null,
//       child: ClipRRect(borderRadius: BorderRadius.circular(8), child: content),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80),
//         child: AppBar(
//           elevation: 2,
//           backgroundColor: Colors.white,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//           ),
//           iconTheme: const IconThemeData(color: Color(0xFF2A3A69)),
//           title: const Text(
//             "Task Details",
//             style: TextStyle(
//               color: Color(0xFF2A3A69),
//               fontWeight: FontWeight.bold,
//               fontSize: 22,
//             ),
//           ),
//           centerTitle: true,
//         ),
//       ),
//       body: loadingServices && !widget.readOnly
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: headingController,
//                      readOnly: widget.readOnly, 
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2A3A69),
//                     ),
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       hintText: "Task",
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Service",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF5C74B1),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   if (!widget.readOnly)
//                     (_providerServices.isEmpty
//                         ? Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _infoBox(
//                                 service.isNotEmpty
//                                     ? "${service['title']} • PKR ${service['price']}"
//                                     : "No services available",
//                               ),
//                               const SizedBox(height: 8),
//                               TextButton.icon(
//                                 onPressed: fetchProviderServices,
//                                 icon: const Icon(Icons.refresh),
//                                 label: const Text("Refresh services"),
//                               ),
//                             ],
//                           )
//                         : DropdownButtonFormField<int?>(
//                             value: selectedServiceId,
//                             items: _providerServices.map((s) {
//                               final id = s['id'] is int
//                                   ? s['id']
//                                   : int.tryParse(s['id'].toString()) ?? 0;
//                               return DropdownMenuItem<int>(
//                                 value: id,
//                                 child: Text(
//                                   "${s['title']} • PKR ${s['price']}",
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (val) {
//                               if (val == null) return;
//                               final sel = _providerServices.firstWhere(
//                                 (s) =>
//                                     (s['id'] is int
//                                         ? s['id']
//                                         : int.tryParse(s['id'].toString())) ==
//                                     val,
//                                 orElse: () => {},
//                               );
//                               if (sel.isEmpty) return;
//                               _setService(sel);
//                             },
//                             decoration: _dropdownDecoration(),
//                           ))
//                   else
//                     _infoBox(
//                       "${service['title'] ?? ''} • PKR ${service['price'] ?? ''}",
//                     ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Scheduled Date",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF5C74B1),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ListTile(
//                     leading: const Icon(
//                       Icons.calendar_today,
//                       color: Color(0xFF2A3A69),
//                     ),
//                     title: Text(
//                       selectedDate != null
//                           ? "${selectedDate!.toLocal()}".split(
//                               '.',
//                             )[0] // yyyy-mm-dd hh:mm:ss
//                           : "No date & time selected",

//                       style: const TextStyle(color: Color(0xFF5C74B1)),
//                     ),
//                     onTap: _pickDate,
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                   const Divider(color: Color(0xFFD9E1F0)),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Notes / Requirements",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF5C74B1),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: notesController,
//                     maxLines: 3,
//                     readOnly: widget.readOnly,
//                     decoration: _inputDecoration(
//                       "Write any additional notes...",
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Attachments",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2A3A69),
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       // ✅ Local attachments (user added)
//                       if (!widget.readOnly)
//                         ..._attachments.map(
//                           (file) => Stack(
//                             children: [
//                               GestureDetector(
//                                 onTap: () => Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => FullScreenImage(file: file),
//                                   ),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: buildImagePreview(file),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 2,
//                                 right: 2,
//                                 child: GestureDetector(
//                                   onTap: () =>
//                                       setState(() => _attachments.remove(file)),
//                                   child: Container(
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFFD9E1F0),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     padding: const EdgeInsets.all(4),
//                                     child: const Icon(
//                                       Icons.close,
//                                       size: 16,
//                                       color: Color(0xFF2A3A69),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       // ➕ Add new attachment button
//                       if (!widget.readOnly)
//                         GestureDetector(
//                           onTap: _pickImage,
//                           child: Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: const Color(0xFF2A3A69),
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                               color: const Color(0xFF5C74B1).withOpacity(0.1),
//                             ),
//                             child: const Icon(
//                               Icons.add,
//                               color: Color(0xFF2A3A69),
//                               size: 30,
//                             ),
//                           ),
//                         ),
//                       // ✅ Provider attachments
//                       if (widget.readOnly)
//                         ...providerAttachments.map(
//                           (url) => GestureDetector(
//                             onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => FullScreenImage(url: url),
//                               ),
//                             ),
//                             child: buildProviderAttachment(url),
//                           ),
//                         ),
//                     ],
//                   ),

//                   // ✅ Show attachment details only for provider view
//                   if (widget.readOnly &&
//                       imageDetailsController.text.isNotEmpty) ...[
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Attachment Details",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF5C74B1),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _infoBox(imageDetailsController.text),
//                   ],

//                   const SizedBox(height: 12),
//                   if (!widget.readOnly)
//                     TextField(
//                       controller: imageDetailsController,
//                       maxLines: null,
//                       decoration: _inputDecoration(
//                         "You can add details about images...",
//                       ),
//                     ),
//                   const SizedBox(height: 30),
//                   if (!widget.readOnly)
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed:
//                                 (_providerServices.isEmpty ||
//                                     selectedServiceId == null)
//                                 ? null
//                                 : _confirmBooking,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   (_providerServices.isEmpty ||
//                                       selectedServiceId == null)
//                                   ? Colors.grey
//                                   : const Color(0xFF2A3A69),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: const Text(
//                               "Confirm Booking",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.pop(context),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               side: const BorderSide(color: Color(0xFF2A3A69)),
//                             ),
//                             child: const Text(
//                               "Cancel Booking",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Color(0xFF2A3A69),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   else
//                     Center(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           _messageUser(context);
//                         },
//                         icon: const Icon(Icons.message, color: Colors.white),
//                         label: const Text("Message User"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0A66C2),
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 14,
//                             horizontal: 20,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _infoBox(String text) => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: const Color(0xFFD9E1F0),
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: Text(text, style: const TextStyle(color: Color(0xFF2A3A69))),
//   );

//   InputDecoration _inputDecoration(String hint) => InputDecoration(
//     hintText: hint,
//     filled: true,
//     fillColor: const Color(0xFFD9E1F0),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: BorderSide.none,
//     ),
//   );

//   InputDecoration _dropdownDecoration() => InputDecoration(
//     filled: true,
//     fillColor: const Color(0xFFD9E1F0),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: BorderSide.none,
//     ),
//   );

//   // ----- msg btn logic function ----
//  Future<void> _messageUser(BuildContext context) async {
//   try {
//     int? receiverId;

//     // --- Determine receiver safely ---
//     if (widget.readOnly) {
//       // Provider view → receiver is task's user
//       receiverId = widget.taskData?['user_id'] as int?;
//     } else {
//       // User view → receiver is provider
//       receiverId = widget.providerId;
//     }

//     // ❌ Null check
//     if (receiverId == null || receiverId <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Cannot determine recipient ❌")),
//       );
//       debugPrint("❌ _messageUser: receiverId is invalid, taskData: ${widget.taskData}");
//       return;
//     }

//     // ✅ Use `receiverId!` here to tell Dart it's non-null
//     final response = await http.post(
//       Uri.parse("${Backend.baseUrl}/conversations"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "user_id": widget.currentUserId,
//         "provider_id": receiverId!,  // <-- force non-null
//       }),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       final conversationId = data['conversation_id'] ?? data['id'];

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => ChatPage(
//             conversationId: conversationId,
//             currentUserId: widget.currentUserId,
//             otherUserId: receiverId!,  // <-- force non-null
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to start chat ❌")),
//       );
//       debugPrint("❌ _messageUser: Backend returned ${response.statusCode} - ${response.body}");
//     }
//   } catch (e, stack) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error starting chat: $e")),
//     );
//     debugPrint("❌ _messageUser exception: $e\n$stack");
//   }
// }

// }






import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../helpers/backend.dart';
import 'my_tasks_screen.dart';
import 'full_scree.dart';
import 'chat_page.dart';

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
  }) : assert(
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
  final TextEditingController headingController = TextEditingController();
  final TextEditingController imageDetailsController = TextEditingController();
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

    headingController.text = widget.taskData?['title'] ?? "Enter task title";

    // Provider view (readOnly)
    // Provider view (readOnly)
    if (widget.readOnly && widget.taskData != null) {
      final t = widget.taskData!;
      headingController.text = t['title'] ?? t['service_title'];
      notesController.text = t['notes'] ?? t['description'] ?? '';
      imageDetailsController.text = t['attachment_details'] ?? '';
      try {
        selectedDate = DateTime.parse(t['scheduled_date']);
      } catch (_) {}

      // ✅ Fix for attachments
      if (t['attachments'] != null) {
        providerAttachments.clear();
        for (var a in t['attachments']) {
          final path = a['file_path']?.toString() ?? "";
          if (path.isNotEmpty) {
            final fullUrl = path.startsWith("http")
                ? path
                : "${Backend.baseUrl}/$path";
            providerAttachments.add(fullUrl);
          }
        }
      }

      _setService({
        'id': t['service_id'],
        'title': t['service_title'] ?? 'Unknown Service',
        'price': t['price']?.toString() ?? '0',
        'description': t['description'] ?? '',
      });
    }

    // User view: set serviceData if available
    if (!widget.readOnly && widget.serviceData != null) {
      _setService(widget.serviceData!);
    }

    // If provider services exist but no service selected, pick first
    if (!widget.readOnly && _providerServices.isNotEmpty && service.isEmpty) {
      _setService(_providerServices.first);
    }

    // If no services → fetch
    if (!widget.readOnly && _providerServices.isEmpty) {
      fetchProviderServices();
    }
  }

  void _setService(Map<String, dynamic> s) {
    setState(() {
      service = {
        'id': s['id'],
        'title': s['title'] ?? '',
        'price': s['price']?.toString() ?? '',
        'description': s['description'] ?? '',
      };
      selectedServiceId = s['id'] is int
          ? s['id']
          : int.tryParse(s['id'].toString());
    });
  }

  Future<void> fetchProviderServices() async {
    setState(() => loadingServices = true);
    try {
      final url = Uri.parse(
        '${Backend.baseUrl}/provider/${widget.providerId}/services',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> servicesRaw = data['services'] is List
            ? data['services']
            : [];

        _providerServices = servicesRaw
            .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s))
            .toList();

        if (_providerServices.isNotEmpty &&
            (service.isEmpty || selectedServiceId == null)) {
          _setService(_providerServices.first);
        }

        if (_providerServices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No services available for this provider."),
            ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching services: $e")));
    } finally {
      setState(() => loadingServices = false);
    }
  }

  /////
  Future<void> createTaskWithAttachments({
    required int userId,
    required int providerId,
    required int serviceId,
    required DateTime scheduledDate,
    required String notes,
    String? attachmentDetails,
    required List<File> attachments,
    required BuildContext context,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Backend.baseUrl}/tasks'),
      );
String sanitize(String input) {
  return input.replaceAll(RegExp(r'[^\u0000-\uFFFF]'), '');
}

      // ⚡ Task fields
      request.fields['user_id'] = userId.toString();
      request.fields['provider_id'] = providerId.toString();
      request.fields['service_id'] = serviceId.toString();
      request.fields['scheduled_date'] = scheduledDate.toIso8601String();
      request.fields['notes'] = sanitize(notes);
request.fields['attachment_details'] = sanitize(attachmentDetails ?? '');
request.fields['title'] = sanitize(headingController.text);
      // ⚡ Add attachments
      for (var file in attachments) {
        request.files.add(
          await http.MultipartFile.fromPath('attachments', file.path),
        );
      }

      // ⚡ Send request
      var response = await request.send();

      if (response.statusCode == 201) {
        final resBody = await response.stream.bytesToString();
        final data = jsonDecode(resBody);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task created successfully ✅")),
        );

        print("Task created: ${data['task']}");
        // ✅ Ab aap data['task']['attachments'] me files dekh sakte ho
      } else {
        final resBody = await response.stream.bytesToString();
        print("Failed to create task: $resBody");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to create task ❌")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _pickDate() async {
    if (widget.readOnly) return;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImage() async {
    if (widget.readOnly) return;
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null)
      setState(() => _attachments.add(File(pickedFile.path)));
  }

  Future<void> _confirmBooking() async {
    FocusScope.of(context).unfocus();

    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a date 📅")));
      return;
    }

    if (selectedServiceId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid service ❌")));
      return;
    }

    try {
      // ⚡ Call helper function to create task with attachments
      await createTaskWithAttachments(
        userId: widget.currentUserId,
        providerId: widget.providerId,
        serviceId: selectedServiceId!,
        scheduledDate: selectedDate!,
        notes: notesController.text,
        attachmentDetails: imageDetailsController.text,
        attachments: _attachments,
        context: context,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking Confirmed ✅")));

      // Navigate to MyTasksScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MyTasksScreen(currentUserId: widget.currentUserId, role: "user"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    headingController.dispose();
    imageDetailsController.dispose();
    super.dispose();
  }

  Widget buildImagePreview(File file) {
    if (kIsWeb) {
      return FutureBuilder(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(
              snapshot.data as Uint8List,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            );
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

  Widget buildProviderAttachment(String url) {
    final lower = url.toLowerCase();
    Widget content;

    if (lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".png") ||
        lower.endsWith(".gif")) {
      content = Image.network(url, width: 100, height: 100, fit: BoxFit.cover);
    } else {
      content = Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(
          Icons.insert_drive_file,
          size: 40,
          color: Colors.black54,
        ),
      );
    }

    return GestureDetector(
      onTap:
          lower.endsWith(".jpg") ||
              lower.endsWith(".jpeg") ||
              lower.endsWith(".png") ||
              lower.endsWith(".gif")
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FullScreenImage(url: url)),
              );
            }
          : null,
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          elevation: 2,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF2A3A69)),
          title: const Text(
            "Task Details",
            style: TextStyle(
              color: Color(0xFF2A3A69),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: loadingServices && !widget.readOnly
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: headingController,
                     readOnly: widget.readOnly, 
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3A69),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Task",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Service",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C74B1),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                              final id = s['id'] is int
                                  ? s['id']
                                  : int.tryParse(s['id'].toString()) ?? 0;
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  "${s['title']} • PKR ${s['price']}",
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              final sel = _providerServices.firstWhere(
                                (s) =>
                                    (s['id'] is int
                                        ? s['id']
                                        : int.tryParse(s['id'].toString())) ==
                                    val,
                                orElse: () => {},
                              );
                              if (sel.isEmpty) return;
                              _setService(sel);
                            },
                            decoration: _dropdownDecoration(),
                          ))
                  else
                    _infoBox(
                      "${service['title'] ?? ''} • PKR ${service['price'] ?? ''}",
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    "Scheduled Date",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C74B1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF2A3A69),
                    ),
                    title: Text(
                      selectedDate != null
                          ? "${selectedDate!.toLocal()}".split(
                              '.',
                            )[0] // yyyy-mm-dd hh:mm:ss
                          : "No date & time selected",

                      style: const TextStyle(color: Color(0xFF5C74B1)),
                    ),
                    onTap: _pickDate,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(color: Color(0xFFD9E1F0)),
                  const SizedBox(height: 20),
                  const Text(
                    "Notes / Requirements",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C74B1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    readOnly: widget.readOnly,
                    decoration: _inputDecoration(
                      "Write any additional notes...",
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Attachments",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3A69),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // ✅ Local attachments (user added)
                      if (!widget.readOnly)
                        ..._attachments.map(
                          (file) => Stack(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImage(file: file),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: buildImagePreview(file),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _attachments.remove(file)),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD9E1F0),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Color(0xFF2A3A69),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // ➕ Add new attachment button
                      if (!widget.readOnly)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF2A3A69),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF5C74B1).withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFF2A3A69),
                              size: 30,
                            ),
                          ),
                        ),
                      // ✅ Provider attachments
                      if (widget.readOnly)
                        ...providerAttachments.map(
                          (url) => GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImage(url: url),
                              ),
                            ),
                            child: buildProviderAttachment(url),
                          ),
                        ),
                    ],
                  ),

                  // ✅ Show attachment details only for provider view
                  if (widget.readOnly &&
                      imageDetailsController.text.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "Attachment Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C74B1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _infoBox(imageDetailsController.text),
                  ],

                  const SizedBox(height: 12),
                  if (!widget.readOnly)
                    TextField(
                      controller: imageDetailsController,
                      maxLines: null,
                      decoration: _inputDecoration(
                        "You can add details about images...",
                      ),
                    ),
                  const SizedBox(height: 30),
                  if (!widget.readOnly)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                (_providerServices.isEmpty ||
                                    selectedServiceId == null)
                                ? null
                                : _confirmBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (_providerServices.isEmpty ||
                                      selectedServiceId == null)
                                  ? Colors.grey
                                  : const Color(0xFF2A3A69),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Confirm Booking",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFF2A3A69)),
                            ),
                            child: const Text(
                              "Cancel Booking",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2A3A69),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _messageUser(context);
                        },
                        icon: const Icon(Icons.message, color: Colors.white),
                        label: const Text("Message User"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A66C2),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
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

  // ----- msg btn logic function ----
 Future<void> _messageUser(BuildContext context) async {
  try {
    int? receiverId;

    // --- Determine receiver safely ---
    if (widget.readOnly) {
      // Provider view → receiver is task's user
      receiverId = widget.taskData?['user_id'] as int?;
    } else {
      // User view → receiver is provider
      receiverId = widget.providerId;
    }

    // ❌ Null check
    if (receiverId == null || receiverId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot determine recipient ❌")),
      );
      debugPrint("❌ _messageUser: receiverId is invalid, taskData: ${widget.taskData}");
      return;
    }

    // ✅ Use `receiverId!` here to tell Dart it's non-null
    final response = await http.post(
      Uri.parse("${Backend.baseUrl}/conversations"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": widget.currentUserId,
        "provider_id": receiverId!,  // <-- force non-null
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
            otherUserId: receiverId!,  // <-- force non-null
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to start chat ❌")),
      );
      debugPrint("❌ _messageUser: Backend returned ${response.statusCode} - ${response.body}");
    }
  } catch (e, stack) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error starting chat: $e")),
    );
    debugPrint("❌ _messageUser exception: $e\n$stack");
  }
}

}





