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
// import '../helpers/colors.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import '../helpers/my_colors.dart';

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
//   TextEditingController addressController = TextEditingController();
//   double? selectedLat;
//   double? selectedLng;
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

//       // 🆕 Address and location
//       addressController.text = t['address'] ?? '';
//       selectedLat = t['latitude'] is double
//           ? t['latitude']
//           : double.tryParse(t['latitude']?.toString() ?? '');
//       selectedLng = t['longitude'] is double
//           ? t['longitude']
//           : double.tryParse(t['longitude']?.toString() ?? '');

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

//   Future<void> createTaskWithAttachments({
//     required int userId,
//     required int providerId,
//     required int serviceId,
//     required DateTime scheduledDate,
//     required String notes,
//     String? attachmentDetails,
//     required List<File> attachments,
//     required BuildContext context,
//     String? address, // 🆕 new param
//     double? latitude, // 🆕 new param
//     double? longitude, // 🆕 new param
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${Backend.baseUrl}/tasks'),
//       );

//       String sanitize(String input) {
//         return input.replaceAll(RegExp(r'[^\u0000-\uFFFF]'), '');
//       }

//       // ⚡ Task fields
//       request.fields['user_id'] = userId.toString();
//       request.fields['provider_id'] = providerId.toString();
//       request.fields['service_id'] = serviceId.toString();
//       request.fields['scheduled_date'] = scheduledDate.toIso8601String();
//       request.fields['notes'] = sanitize(notes);
//       request.fields['attachment_details'] = sanitize(attachmentDetails ?? '');
//       request.fields['title'] = sanitize(headingController.text);

//       // 🆕 Address & Location fields
//       if (address != null && address.isNotEmpty) {
//         request.fields['address'] = sanitize(address);
//       }
//       if (latitude != null && longitude != null) {
//         request.fields['latitude'] = latitude.toString();
//         request.fields['longitude'] = longitude.toString();
//       }

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
//           SnackBar(
//             content: const Text(
//               "🎉 Task created successfully!",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.white,
//               ),
//             ),
//             backgroundColor: Colors.green.shade600,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             duration: const Duration(seconds: 3),
//           ),
//         );

//         print("Task created: ${data['task']}");
//         // 🔔 Send notification to provider
//         await NotificationsApi.sendNotification(
//           userId: providerId, // receiver
//           title: "📢 New Task Assigned",
//           body: "You have a new task 📢 ,Go and check your Tasks Page... ",
//           senderId: userId, // sender
//         );
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
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: MyColors.primary, // Header background
//               onPrimary: Colors.white, // Header text (month/year/day)
//               onSurface: MyColors.primary, // Dates text
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: MyColors.primary, // Action button text
//                 textStyle: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (pickedDate != null) {
//       final pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: const ColorScheme.light(
//                 primary: MyColors.inputFocusedBorder, // Time picker dial color
//                 onPrimary: Colors.white, // Selected text
//                 onSurface: MyColors.inputFill, // Normal text
//               ),
//               textButtonTheme: TextButtonThemeData(
//                 style: TextButton.styleFrom(
//                   foregroundColor: MyColors.primary,
//                   textStyle: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             child: child!,
//           );
//         },
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
//         address: addressController.text,
//         latitude: selectedLat,
//         longitude: selectedLng,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "✅ Your task has been successfully sent. Please wait for provider approval.",
//           ),
//           backgroundColor: Colors.blue,
//         ),
//       );

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
//       backgroundColor: MyColors.background,

//       appBar: AppBar(
//         title: const Text(
//           "Task Details",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color(0xFF2A2A40), // royal indigo
//                 Color(0xFF3D3A8B), // violet glow
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),

//       body: loadingServices && !widget.readOnly
//           ? const Center(
//               child: CircularProgressIndicator(color: MyColors.primary),
//             )
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: headingController,
//                     readOnly: widget.readOnly,
//                     style: const TextStyle(
//                       fontSize: 24, // slightly bigger
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2A3A69),
//                     ),
//                     decoration: InputDecoration(
//                       hintText: "Task Title",
//                       hintStyle: const TextStyle(
//                         color: Color(0xFFA1A1A1),
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       filled: true,
//                       fillColor: const Color(
//                         0xFFEFF4FB,
//                       ), // soft bluish background
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 16,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(18),
//                         borderSide: BorderSide.none,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(18),
//                         borderSide: BorderSide.none,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(18),
//                         borderSide: const BorderSide(
//                           color: Color(0xFF2A3A69), // dark blue glow
//                           width: 2,
//                         ),
//                       ),
//                       // optional shadow inside
//                     ),
//                   ),

//                   const SizedBox(height: 20),
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     child: Text(
//                       "Choose the service You need",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         foreground: Paint()
//                           ..shader =
//                               LinearGradient(
//                                 colors: <Color>[
//                                   MyColors.primary, // theme primary color
//                                   MyColors.secondary, // theme secondary color
//                                 ],
//                               ).createShader(
//                                 const Rect.fromLTWH(0.0, 0.0, 250.0, 50.0),
//                               ),
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 3),
//                             blurRadius: 6,
//                             color: Colors.black26,
//                           ),
//                         ],
//                         letterSpacing: 0.5,
//                         height: 1.3,
//                       ),
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
//                                 label: const Text(
//                                   "Refresh services",
//                                   style: TextStyle(color: MyColors.primary),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : DropdownButtonFormField<int?>(
//                             value: selectedServiceId,
//                            hint: const Text(
//     "Select a service",
//     style: TextStyle(
//       color: MyColors.textSecondary, // placeholder color
//       fontSize: 15,
//     ),
//   ),
//   style: const TextStyle(
//     color: MyColors.textPrimary, // selected item ka color
//     fontSize: 16,
//   ),
//    dropdownColor: MyColors.surface,
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

//                   const SizedBox(height: 40),
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Text(
//                       "Set Expiry Date For Task",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: MyColors.textPrimary, // simple white from theme
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 2),
//                             blurRadius: 5,
//                             color: Colors.black26, // optional subtle shadow
//                           ),
//                         ],
//                         letterSpacing: 0.4,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 8),
//                   ListTile(
//                     leading: Icon(
//                       Icons.calendar_today,
//                       color: MyColors.textPrimary, // theme white
//                     ),
//                     title: Text(
//                       selectedDate != null
//                           ? "${selectedDate!.toLocal()}".split(
//                               '.',
//                             )[0] // yyyy-mm-dd hh:mm:ss
//                           : "No date & time selected",
//                       style: const TextStyle(
//                         color: MyColors.textPrimary, // theme white
//                         fontWeight: FontWeight.w500,
//                         fontSize: 16,
//                       ),
//                     ),
//                     onTap: widget.readOnly ? null : _pickDate,
//                     contentPadding: EdgeInsets.zero,
//                     tileColor:
//                         MyColors.surface, // optional: dark background for tile
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(
//                         12,
//                       ), // optional: rounded corners
//                     ),
//                   ),

//                   SizedBox(height: 20),

//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Text(
//                       "Share Your Location",
//                       style: TextStyle(
//                         fontSize: 16, // slightly bigger than default
//                         fontWeight: FontWeight.bold,
//                         color: MyColors.textPrimary, // theme white
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 2),
//                             blurRadius: 5,
//                             color: Colors.black26,
//                           ),
//                         ],
//                         letterSpacing: 0.4,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),

//                   // Address Section
//                   if (!widget.readOnly) ...[
//                     TextField(
//                       controller: addressController,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: MyColors.textPrimary, // theme white text
//                         fontWeight: FontWeight.w500,
//                       ),
//                       decoration: InputDecoration(
//                         labelText: "Type your address",
//                         labelStyle: const TextStyle(
//                           color: MyColors.primary, // theme primary color
//                           fontWeight: FontWeight.bold,
//                         ),
//                         filled: true,
//                         fillColor:
//                             MyColors.inputFill, // theme input background (dark)
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 16,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(18),
//                           borderSide: BorderSide(
//                             color: MyColors.inputBorder.withOpacity(
//                               0.3,
//                             ), // theme border
//                             width: 1.2,
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(18),
//                           borderSide: BorderSide(
//                             color: MyColors.inputBorder.withOpacity(0.3),
//                             width: 1.2,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(18),
//                           borderSide: const BorderSide(
//                             color: MyColors
//                                 .primary, // focus glow with theme primary
//                             width: 2,
//                           ),
//                         ),
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                       ),
//                     ),

//                     const SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         LocationPermission permission =
//                             await Geolocator.requestPermission();
//                         if (permission == LocationPermission.always ||
//                             permission == LocationPermission.whileInUse) {
//                           Position pos = await Geolocator.getCurrentPosition(
//                             desiredAccuracy: LocationAccuracy.high,
//                           );
//                           setState(() {
//                             selectedLat = pos.latitude;
//                             selectedLng = pos.longitude;
//                           });
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 "Location set: $selectedLat, $selectedLng",
//                                 style: const TextStyle(
//                                   color: MyColors.textPrimary,
//                                 ),
//                               ),
//                               backgroundColor: MyColors.primary,
//                             ),
//                           );
//                         }
//                       },
//                       icon: const Icon(
//                         Icons.my_location,
//                         color: MyColors.buttonText,
//                       ),
//                       label: const Text(
//                         "Share my location",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: MyColors.buttonText,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: MyColors.secondary,
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 14,
//                           horizontal: 20,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 6,
//                         shadowColor: MyColors.secondary.withOpacity(0.3),
//                       ),
//                     ),
//                   ] else ...[
//                     const Text(
//                       "Address",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: MyColors.textSecondary,
//                       ),
//                     ),

//                     const SizedBox(height: 6),
//                     _infoBox(
//                       addressController.text.isNotEmpty
//                           ? addressController.text
//                           : "No address provided",
//                     ),
//                     const SizedBox(height: 10),
//                     if (selectedLat != null && selectedLng != null)
//                       GestureDetector(
//                         onTap: () {
//                           final url =
//                               "https://www.google.com/maps/search/?api=1&query=$selectedLat,$selectedLng";
//                           launchUrlString(url); // url_launcher package se
//                         },
//                         child: _infoBox("📍 View location on map"),
//                       ),
//                   ],

//                   const SizedBox(height: 35),
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Text(
//                       "Notes/Requirements",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: MyColors.textPrimary, // theme ka white
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 1),
//                             blurRadius: 3,
//                             color: Colors.black26, // soft shadow
//                           ),
//                         ],
//                         letterSpacing: 0.4,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: notesController,
//                     maxLines: 6,
//                     style: TextStyle(color: MyColors.textPrimary),
//                     readOnly: widget.readOnly,
//                     decoration: _inputDecoration(
//                       "Write any additional notes...",
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Text(
//                       "Attachments",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: MyColors.textPrimary, // theme ka white
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 1),
//                             blurRadius: 3,
//                             color: Colors.black26, // soft shadow
//                           ),
//                         ],
//                         letterSpacing: 0.4,
//                         height: 1.3,
//                       ),
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
//                                       color: MyColors.divider,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     padding: const EdgeInsets.all(4),
//                                     child: const Icon(
//                                       Icons.close,
//                                       size: 16,
//                                       color: MyColors.buttonText,
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
//                               border: Border.all(color: MyColors.textSecondary),
//                               borderRadius: BorderRadius.circular(8),
//                               color: AppColors.textLight.withOpacity(0.1),
//                             ),
//                             child: const Icon(
//                               Icons.add,
//                               color: MyColors.primary,
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
//                         color: MyColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _infoBox(imageDetailsController.text),
//                   ],

//                   const SizedBox(height: 12),
//                   if (!widget.readOnly)
//                     TextField(
//                       controller: imageDetailsController,
//                       minLines: 1, // start with 1 line
//                       maxLines: 7, // expand up to 7 lines only
//                       style: TextStyle(color: MyColors.textPrimary),
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
//                                   : MyColors.buttonBackground,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 6,
//                               shadowColor: Colors.black.withOpacity(0.3),
//                             ),
//                             child: const Text(
//                               "Confirm Booking",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: MyColors.buttonText,
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
//                               side: const BorderSide(
//                                 color: MyColors.textSecondary,
//                               ),
//                             ),
//                             child: const Text(
//                               "Cancel Booking",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: MyColors.primary,
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
//                         icon: const Icon(
//                           Icons.message,
//                           color: MyColors.buttonText,
//                         ),
//                         label: const Text(
//                           "Message User",
//                           style: TextStyle(color: MyColors.buttonText),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: MyColors.buttonBackground,
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
//     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
//     decoration: BoxDecoration(
//       color: MyColors.surface, // theme surface dark background
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(
//         color: MyColors.primary.withOpacity(0.4), // subtle primary border
//         width: 1.5,
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.25),
//           offset: const Offset(0, 6),
//           blurRadius: 20,
//           spreadRadius: 1,
//         ),
//         BoxShadow(
//           color: MyColors.secondary.withOpacity(
//             0.15,
//           ), // soft gold top highlight
//           offset: const Offset(-2, -2),
//           blurRadius: 10,
//           spreadRadius: 0,
//         ),
//       ],
//     ),
//     child: Text(
//       text,
//       style: const TextStyle(
//         color: MyColors.textPrimary, // white text for contrast
//         fontWeight: FontWeight.w600,
//         fontSize: 16,
//         height: 1.5,
//         letterSpacing: 0.2,
//       ),
//     ),
//   );

//   InputDecoration _inputDecoration(String hint) => InputDecoration(
//     hintText: hint,
//     hintStyle: TextStyle(
//       color: MyColors.textSecondary, // theme secondary text color
//       fontSize: 15,
//     ),
//     filled: true,
//     fillColor: MyColors.surface, // theme dark surface
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide(
//         color: MyColors.secondary, // premium gold glow
//         width: 1.5,
//       ),
//     ),
//   );

//   InputDecoration _dropdownDecoration() => InputDecoration(
//     filled: true,
//     fillColor: MyColors.surface,
//      // theme dark surface
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide(
//         color: MyColors.secondary, // premium gold accent
//         width: 1.5,
//       ),
//     ),
//     hintStyle: TextStyle(
//       color: MyColors.textSecondary, // subtle text color
//       fontSize: 15,
//     ),
//   );

//   // ----- msg btn logic function ----
//   Future<void> _messageUser(BuildContext context) async {
//     try {
//       int? receiverId;

//       // --- Determine receiver safely ---
//       if (widget.readOnly) {
//         // Provider view → receiver is task's user
//         receiverId = widget.taskData?['user_id'] as int?;
//       } else {
//         // User view → receiver is provider
//         receiverId = widget.providerId;
//       }

//       // ❌ Null check
//       if (receiverId == null || receiverId <= 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Cannot determine recipient ❌")),
//         );
//         debugPrint(
//           "❌ _messageUser: receiverId is invalid, taskData: ${widget.taskData}",
//         );
//         return;
//       }

//       // ✅ Use `receiverId!` here to tell Dart it's non-null
//       final response = await http.post(
//         Uri.parse("${Backend.baseUrl}/conversations"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "user_id": widget.currentUserId,
//           "provider_id": receiverId!, // <-- force non-null
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         final conversationId = data['conversation_id'] ?? data['id'];

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ChatPage(
//               conversationId: conversationId,
//               currentUserId: widget.currentUserId,
//               otherUserId: receiverId!, // <-- force non-null
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               "Failed to start chat ❌",
//               style: TextStyle(
//                 backgroundColor: MyColors.divider,
//                 color: MyColors.textPrimary,
//               ),
//             ),
//           ),
//         );
//         debugPrint(
//           "❌ _messageUser: Backend returned ${response.statusCode} - ${response.body}",
//         );
//       }
//     } catch (e, stack) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error starting chat: $e")));
//       debugPrint("❌ _messageUser exception: $e\n$stack");
//     }
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
import 'full_scree.dart';
import 'chat_page.dart';
import '../helpers/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../helpers/my_colors.dart';

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
  TextEditingController addressController = TextEditingController();
  double? selectedLat;
  double? selectedLng;
  bool _isCreatingTask = false;

  @override
  void initState() {
    super.initState();

    _providerServices = widget.providerServices != null
        ? List<Map<String, dynamic>>.from(widget.providerServices!)
        : [];

    headingController.text = widget.taskData?['title'] ?? "";
    if (widget.readOnly && widget.taskData != null) {
      final t = widget.taskData!;
      headingController.text = t['title'] ?? t['service_title'];
      notesController.text = t['notes'] ?? t['description'] ?? '';
      imageDetailsController.text = t['attachment_details'] ?? '';
      try {
        selectedDate = DateTime.parse(t['scheduled_date']);
      } catch (_) {}

      // 🆕 Address and location
      addressController.text = t['address'] ?? '';
      selectedLat = t['latitude'] is double
          ? t['latitude']
          : double.tryParse(t['latitude']?.toString() ?? '');
      selectedLng = t['longitude'] is double
          ? t['longitude']
          : double.tryParse(t['longitude']?.toString() ?? '');

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

  Future<void> createTaskWithAttachments({
    required int userId,
    required int providerId,
    required int serviceId,
    required DateTime scheduledDate,
    required String notes,
    String? attachmentDetails,
    required List<File> attachments,
    required BuildContext context,
    String? address, // 🆕 new param
    double? latitude, // 🆕 new param
    double? longitude, // 🆕 new param
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

      // 🆕 Address & Location fields
      if (address != null && address.isNotEmpty) {
        request.fields['address'] = sanitize(address);
      }
      if (latitude != null && longitude != null) {
        request.fields['latitude'] = latitude.toString();
        request.fields['longitude'] = longitude.toString();
      }

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
          SnackBar(
            content: const Text(
              "🎉 Task created successfully!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 3),
          ),
        );

        print("Task created: ${data['task']}");
        // 🔔 Send notification to provider
        await NotificationsApi.sendNotification(
          userId: providerId, // receiver
          title: "📢 New Task Assigned",
          body: "You have a new task 📢 ,Go and check your Tasks Page... ",
          senderId: userId, // sender
        );
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MyColors.primary, // Header background
              onPrimary: Colors.white, // Header text (month/year/day)
              onSurface: MyColors.primary, // Dates text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: MyColors.primary, // Action button text
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: MyColors.inputFocusedBorder, // Time picker dial color
                onPrimary: Colors.white, // Selected text
                onSurface: MyColors.inputFill, // Normal text
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: MyColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            child: child!,
          );
        },
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
    if (_isCreatingTask) return; // Prevent multiple taps
    _isCreatingTask = true;
    setState(() {}); // disable button
    FocusScope.of(context).unfocus();

    // 1️⃣ Service selected
    if (selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a service ❌")),
      );
      _isCreatingTask = false;
      setState(() {});
      return;
    }

    // 2️⃣ Date selected
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a date 📅")));
      _isCreatingTask = false;
      setState(() {});
      return;
    }

    // 3️⃣ Title entered
    if (headingController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a task title ✏️")),
      );
      _isCreatingTask = false;
      setState(() {});
      return;
    }

    // 4️⃣ Location/address set
    if (addressController.text.trim().isEmpty ||
        selectedLat == null ||
        selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set your location 📍")),
      );
      _isCreatingTask = false;
      setState(() {});
      return;
    }

    // 5️⃣ Notes/requirements filled
    if (notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add notes/requirements 📝")),
      );
      _isCreatingTask = false;
      setState(() {});
      return;
    }

    // ✅ If all validations pass, create the task
    try {
      await createTaskWithAttachments(
        userId: widget.currentUserId,
        providerId: widget.providerId,
        serviceId: selectedServiceId!,
        scheduledDate: selectedDate!,
        notes: notesController.text,
        attachmentDetails: imageDetailsController.text,
        attachments: _attachments,
        context: context,
        address: addressController.text,
        latitude: selectedLat,
        longitude: selectedLng,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "✅ Your task has been successfully sent. Please wait for provider approval.",
          ),
          backgroundColor: Colors.blue,
        ),
      );

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
    } finally {
      _isCreatingTask = false;
      setState(() {}); // re-enable button
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
      backgroundColor: MyColors.background,

      appBar: AppBar(
        title: const Text(
          "Task Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2A2A40), // royal indigo
                Color(0xFF3D3A8B), // violet glow
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: loadingServices && !widget.readOnly
          ? const Center(
              child: CircularProgressIndicator(color: MyColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: headingController,
                    readOnly: widget.readOnly,
                    style: const TextStyle(
                      fontSize: 20, // slightly bigger
                      fontWeight: FontWeight.bold,
                      color: MyColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: "Task Title",
                      hintStyle: const TextStyle(
                        color: Color(0xFFA1A1A1),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: MyColors.inputFill, // soft bluish background
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: Color(0xFF2A3A69), // dark blue glow
                          width: 2,
                        ),
                      ),
                      // optional shadow inside
                    ),
                  ),

                  const SizedBox(height: 30),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Choose the service You need",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader =
                              LinearGradient(
                                colors: <Color>[
                                  MyColors.textPrimary, // theme primary color
                                  MyColors.textPrimary, // theme secondary color
                                ],
                              ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 250.0, 50.0),
                              ),
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 3),
                            blurRadius: 6,
                            color: Colors.black26,
                          ),
                        ],
                        letterSpacing: 0.5,
                        height: 1.3,
                      ),
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
                                label: const Text(
                                  "Refresh services",
                                  style: TextStyle(color: MyColors.primary),
                                ),
                              ),
                            ],
                          )
                        : DropdownButtonFormField<int?>(
                            value: selectedServiceId,
                            hint: const Text(
                              "Select a service",
                              style: TextStyle(
                                color:
                                    MyColors.textSecondary, // placeholder color
                                fontSize: 15,
                              ),
                            ),
                            style: const TextStyle(
                              color: MyColors
                                  .textPrimary, // selected item ka color
                              fontSize: 14,
                            ),
                            dropdownColor: MyColors.surface,
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

                  const SizedBox(height: 40),

                  simpleDivider(),
                  const SizedBox(height: 40),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      "Set expiry date for task",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textPrimary, // simple white from theme
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 5,
                            color: Colors.black26, // optional subtle shadow
                          ),
                        ],
                        letterSpacing: 0.4,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: MyColors.textPrimary, // theme white
                    ),
                    title: Text(
                      selectedDate != null
                          ? "${selectedDate!.toLocal()}".split(
                              '.',
                            )[0] // yyyy-mm-dd hh:mm:ss
                          : "No date & time selected",
                      style: const TextStyle(
                        color: MyColors.textPrimary, // theme white
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    onTap: widget.readOnly ? null : _pickDate,
                    contentPadding: EdgeInsets.zero,
                    tileColor:
                        MyColors.surface, // optional: dark background for tile
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // optional: rounded corners
                    ),
                  ),

                  const SizedBox(height: 40),

                  simpleDivider(),
                  const SizedBox(height: 40),

                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      "Share Your Location",
                      style: TextStyle(
                        fontSize: 16, // slightly bigger than default
                        fontWeight: FontWeight.bold,
                        color: MyColors.textPrimary, // theme white
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 5,
                            color: Colors.black26,
                          ),
                        ],
                        letterSpacing: 0.4,
                        height: 1.3,
                      ),
                    ),
                  ),

                  // Address Section
                  if (!widget.readOnly) ...[
                    TextField(
                      controller: addressController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: MyColors.textPrimary, // theme white text
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: "Type your address",
                        labelStyle: const TextStyle(
                          color: MyColors.primary, // theme primary color
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor:
                            MyColors.inputFill, // theme input background (dark)
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: MyColors.inputBorder.withOpacity(
                              0.3,
                            ), // theme border
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: MyColors.inputBorder.withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: MyColors
                                .primary, // focus glow with theme primary
                            width: 2,
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),

                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        LocationPermission permission =
                            await Geolocator.requestPermission();
                        if (permission == LocationPermission.always ||
                            permission == LocationPermission.whileInUse) {
                          Position pos = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high,
                          );
                          setState(() {
                            selectedLat = pos.latitude;
                            selectedLng = pos.longitude;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Location set: $selectedLat, $selectedLng",
                                style: const TextStyle(
                                  color: MyColors.textPrimary,
                                ),
                              ),
                              backgroundColor: MyColors.primary,
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.my_location,
                        color: MyColors.buttonText,
                      ),
                      label: const Text(
                        "Share my location",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MyColors.buttonText,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: MyColors.secondary.withOpacity(0.3),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      "Address",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 6),
                    _infoBox(
                      addressController.text.isNotEmpty
                          ? addressController.text
                          : "No address provided",
                    ),
                    const SizedBox(height: 10),
                    if (selectedLat != null && selectedLng != null)
                      GestureDetector(
                        onTap: () {
                          final url =
                              "https://www.google.com/maps/search/?api=1&query=$selectedLat,$selectedLng";
                          launchUrlString(url); // url_launcher package se
                        },
                        child: _infoBox("📍 View location on map"),
                      ),
                  ],

                  const SizedBox(height: 40),

                  simpleDivider(),
                  const SizedBox(height: 40),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      "Notes/Requirements",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textPrimary, // theme ka white
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black26, // soft shadow
                          ),
                        ],
                        letterSpacing: 0.4,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 6,
                    style: TextStyle(color: MyColors.textPrimary),
                    readOnly: widget.readOnly,
                    decoration: _inputDecoration(
                      "Write any additional notes...",
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      "Attachments",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textPrimary, // theme ka white
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black26, // soft shadow
                          ),
                        ],
                        letterSpacing: 0.4,
                        height: 1.3,
                      ),
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
                                      color: MyColors.divider,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: MyColors.buttonText,
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
                              border: Border.all(color: MyColors.textSecondary),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.textLight.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: MyColors.primary,
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
                        color: MyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _infoBox(imageDetailsController.text),
                  ],

                  const SizedBox(height: 12),
                  if (!widget.readOnly)
                    TextField(
                      controller: imageDetailsController,
                      minLines: 1, // start with 1 line
                      maxLines: 7, // expand up to 7 lines only
                      style: TextStyle(color: MyColors.textPrimary),
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
                                    selectedServiceId == null ||
                                    _isCreatingTask)
                                ? null
                                : _confirmBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (_providerServices.isEmpty ||
                                      selectedServiceId == null ||
                                      _isCreatingTask)
                                  ? Colors.grey
                                  : MyColors.buttonBackground,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: _isCreatingTask
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Confirm Booking",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: MyColors.buttonText,
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
                              side: const BorderSide(
                                color: MyColors.textSecondary,
                              ),
                            ),
                            child: const Text(
                              "Cancel Booking",
                              style: TextStyle(
                                fontSize: 16,
                                color: MyColors.primary,
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
                        icon: const Icon(
                          Icons.message,
                          color: MyColors.buttonText,
                        ),
                        label: const Text(
                          "Message User",
                          style: TextStyle(color: MyColors.buttonText),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.buttonBackground,
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
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      color: MyColors.surface, // theme surface dark background
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: MyColors.primary.withOpacity(0.4), // subtle primary border
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(0, 6),
          blurRadius: 20,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: MyColors.secondary.withOpacity(
            0.15,
          ), // soft gold top highlight
          offset: const Offset(-2, -2),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: MyColors.textPrimary, // white text for contrast
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.5,
        letterSpacing: 0.2,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: MyColors.textSecondary, // theme secondary text color
      fontSize: 15,
    ),
    filled: true,
    fillColor: MyColors.surface, // theme dark surface
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: MyColors.secondary, // premium gold glow
        width: 1.5,
      ),
    ),
  );

  InputDecoration _dropdownDecoration() => InputDecoration(
    filled: true,
    fillColor: MyColors.surface,
    // theme dark surface
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: MyColors.secondary, // premium gold accent
        width: 1.5,
      ),
    ),
    hintStyle: TextStyle(
      color: MyColors.textSecondary, // subtle text color
      fontSize: 15,
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
        debugPrint(
          "❌ _messageUser: receiverId is invalid, taskData: ${widget.taskData}",
        );
        return;
      }

      // ✅ Use `receiverId!` here to tell Dart it's non-null
      final response = await http.post(
        Uri.parse("${Backend.baseUrl}/conversations"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.currentUserId,
          "provider_id": receiverId!, // <-- force non-null
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
              otherUserId: receiverId!, // <-- force non-null
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to start chat ❌",
              style: TextStyle(
                backgroundColor: MyColors.divider,
                color: MyColors.textPrimary,
              ),
            ),
          ),
        );
        debugPrint(
          "❌ _messageUser: Backend returned ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e, stack) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error starting chat: $e")));
      debugPrint("❌ _messageUser exception: $e\n$stack");
    }
  }
}

Widget simpleDivider() {
  return Divider(color: MyColors.textSecondary, thickness: 1, height: 20);
}
