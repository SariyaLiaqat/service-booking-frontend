// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'task_detail_screen.dart';
// import '../helpers/backend.dart';

// import '../helpers/coolors.dart';
// import 'sp_user_payment.dart';

// class Task {
//   final int id;
//   final int userId;
//   final int providerId;
//   final int serviceId;
//   final String status;
//   final DateTime scheduledDate;
//   final String? address; // new
//   final double? latitude; // new
//   final double? longitude; // new
//   final String notes;
//   final String serviceTitle;
//   final String userName;
//   final String providerName;
//   final String? attachmentDetails;
//   final DateTime? completedAt;
//   final List<Map<String, dynamic>> attachments; // <-- changed type
//   final String? payment_status;
//    double amount;
//   Task({
//     required this.id,
//     required this.userId,
//     required this.providerId,
//     required this.serviceId,
//     required this.status,
//     required this.scheduledDate,
//     this.address,
//     this.latitude,
//     this.longitude,
//     required this.notes,
//     required this.serviceTitle,
//     required this.userName,
//     required this.providerName,
//     this.attachmentDetails,
//     this.completedAt,
//     this.attachments = const [], // default empty list of maps
//     this.payment_status,
//     required this.amount, // new field
//   });

//   factory Task.fromJson(Map<String, dynamic> json) => Task(
//     id: json['id'] ?? 0,
//     userId: json['user_id'] ?? 0,
//     providerId: json['provider_id'] ?? 0,
//     serviceId: json['service_id'] ?? 0,
//     status: json['status'] ?? "pending",
//     scheduledDate:
//         DateTime.tryParse(json['scheduled_date'] ?? "") ?? DateTime.now(),
//     address: json['address'],
//     latitude: json['latitude'] != null
//         ? double.tryParse(json['latitude'].toString())
//         : null,
//     longitude: json['longitude'] != null
//         ? double.tryParse(json['longitude'].toString())
//         : null,
//     notes: json['notes'] ?? "",
//     serviceTitle: json['service_title'] ?? "Service",
//     userName: json['user_name'] ?? "User",
//     providerName: json['provider_name'] ?? "Provider",
//     attachmentDetails: json['attachment_details'],
//     completedAt: json['completed_at'] != null
//         ? DateTime.tryParse(json['completed_at'])
//         : null,
//     attachments: (json['attachments'] != null && json['attachments'] is List)
//         ? List<Map<String, dynamic>>.from(
//             (json['attachments'] as List).map(
//               (a) => Map<String, dynamic>.from(a),
//             ),
//           )
//         : [],
//     payment_status: json['payment_status'],
//      amount: json['amount'] != null
//       ? double.tryParse(json['amount'].toString()) ?? 0
//       : 0, // new
//   );
// }

// class TasksApi {
//   static Future<List<Task>> fetchTasks({int? userId, int? providerId}) async {
//     final Map<String, String> queryParams = {};
//     if (userId != null) queryParams['user_id'] = userId.toString();
//     if (providerId != null) queryParams['provider_id'] = providerId.toString();

//     final uri = Uri.parse(
//       "${Backend.baseUrl}/tasks",
//     ).replace(queryParameters: queryParams);

//     final response = await http.get(uri);

//     if (response.statusCode == 200) {
//       final List data = json.decode(response.body)['tasks'];
//       return data.map((t) => Task.fromJson(t)).toList();
//     } else {
//       throw Exception("Failed to load tasks");
//     }
//   }

//   static Future<Task> updateTaskStatus(int taskId, String status) async {
//     final uri = Uri.parse("${Backend.baseUrl}/tasks/$taskId");

//     final response = await http.patch(
//       uri,
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({"status": status}),
//     );

//     if (response.statusCode == 200) {
//       return Task.fromJson(json.decode(response.body)['task']);
//     } else {
//       throw Exception("Failed to update task");
//     }
//   }
// }

// class MyTasksScreen extends StatefulWidget {
//   final String role; // "user" or "provider"
//   final int currentUserId;

//   const MyTasksScreen({
//     super.key,
//     required this.role,
//     required this.currentUserId,
//   });

//   @override
//   State<MyTasksScreen> createState() => _MyTasksScreenState();
// }

// class _MyTasksScreenState extends State<MyTasksScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<Task> pendingTasks = [];
//   List<Task> completedTasks = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadTasks();
//   }

//  void _payNow(Task task) async {
//   print("💡 _payNow called for Task ID: ${task.id}");

//   if (task.userId == 0 || task.providerId == 0) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           "⚠️ Task missing user or provider info. Please refresh.",
//         ),
//         backgroundColor: Colors.red,
//       ),
//     );
//     return;
//   }

//   // Step 1: Ask user to enter the amount dynamically
//   double enteredAmount = task.amount; // default value
//   final result = await showDialog<double>(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: const Text("Enter Amount to Pay"),
//       content: TextField(
//         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//         decoration: InputDecoration(
//           hintText: task.amount.toStringAsFixed(2), // show default nicely
//         ),
//         onChanged: (val) {
//           enteredAmount = double.tryParse(val) ?? task.amount;
//         },
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(ctx, null),
//           child: const Text("Cancel"),
//         ),
//         TextButton(
//           onPressed: () {
//             if (enteredAmount <= 0) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text("❌ Enter a valid amount greater than 0"),
//                   backgroundColor: Colors.redAccent,
//                 ),
//               );
//               return;
//             }
//             Navigator.pop(ctx, enteredAmount);
//           },
//           child: const Text("Pay"),
//         ),
//       ],
//     ),
//   );

//   if (result == null) return; // user cancelled
//   task.amount = result; // set task amount dynamically

//   // Step 2: Show loading while creating payment
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) =>
//         const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
//   );

//   try {
//     // ✅ Use task.amount dynamically
//     final paymentResponse = await PaymentApi.createPayment(
//       userId: task.userId,
//       spId: task.providerId,
//       taskId: task.id,
//       amount: task.amount,
//     );

//     final paymentUrl = paymentResponse['payment_url']!;
//     final txnId = paymentResponse['txnId']!;
//     final ordId = paymentResponse['ordId']!;

//     Navigator.pop(context); // close loading dialog

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PaymentWebViewScreen(
//           url: paymentUrl,
//           taskId: task.id,
//           userId: task.userId,
//           spId: task.providerId,
//           amount: task.amount,
//           txnId: txnId,
//           ordId: ordId,
//           onPaymentSuccess: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("✅ Payment successful!"),
//                 backgroundColor: Colors.green,
//               ),
//             );
//             _loadTasks(); // refresh tasks after payment success
//           },
//         ),
//       ),
//     );
//   } catch (e) {
//     if (Navigator.canPop(context)) Navigator.pop(context);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("❌ Payment failed: ${e.toString()}"),
//         backgroundColor: Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }

//   Future<void> _loadTasks() async {
//     setState(() => isLoading = true);
//     try {
//       List<Task> allTasks;
//       if (widget.role == "user") {
//         allTasks = await TasksApi.fetchTasks(userId: widget.currentUserId);
//       } else {
//         allTasks = await TasksApi.fetchTasks(providerId: widget.currentUserId);
//       }

//       setState(() {
//         pendingTasks = allTasks.where((t) => t.status != "completed").toList()
//           ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
//         completedTasks = allTasks.where((t) => t.status == "completed").toList()
//           ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("❌ Failed to load tasks: $e")));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _updateTask(Task task, String newStatus) async {
//     bool confirm = true;

//     if (newStatus == "completed") {
//       confirm =
//           await showDialog(
//             context: context,
//             builder: (ctx) => AlertDialog(
//               backgroundColor: kPrimaryColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               title: Text(
//                 'Complete Task',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: kCardColor,
//                 ),
//               ),
//               content: Text(
//                 'Are you sure you have completed this task carefully?',
//                 style: TextStyle(fontSize: 16, color: kTextPrimary),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, false),
//                   style: TextButton.styleFrom(
//                     backgroundColor: kPrimaryColor.withOpacity(0.3),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'Cancel',
//                     style: TextStyle(
//                       color: kCardColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, true),
//                   style: TextButton.styleFrom(
//                     backgroundColor: kPrimaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Yes, Completed',
//                     style: TextStyle(
//                       color: kCardColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ) ??
//           false;
//     }

//     if (!confirm) return;

//     try {
//       await TasksApi.updateTaskStatus(task.id, newStatus);

//       String message = '';
//       Color snackColor = kPrimaryColor;

//       if (newStatus == "confirmed") {
//         message = "✅ Task accepted";
//         snackColor = Colors.green.shade700;

//         // 🔹 Send notification to user
//         NotificationsApi.sendNotification(
//           userId: task.userId,
//           title: "Task Accepted ✅",
//           body:
//               "Your task '${task.serviceTitle}' has been accepted✅ by the provider",
//           senderId: task.providerId,
//         );
//       }

//       if (newStatus == "rejected") {
//         message = "❌ Task rejected";
//         snackColor = Colors.red.shade600;

//         // 🔹 Send notification to user
//         NotificationsApi.sendNotification(
//           userId: task.userId,
//           title: "Task Rejected ❌",
//           body:
//               "Your task '${task.serviceTitle}' has been rejected❌ by the provider",
//           senderId: task.providerId,
//         );
//       }

//       if (newStatus == "completed") {
//         message = "🎉 Task completed";
//         snackColor = kPrimaryColor;

//         // 🔹 Send notification to user
//         NotificationsApi.sendNotification(
//           userId: task.userId,
//           title: "Task Completed 🎉",
//           body:
//               "Your task '${task.serviceTitle}' has been marked as completed🎉 by the provider",
//           senderId: task.providerId,
//         );
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             message,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           backgroundColor: snackColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           duration: const Duration(seconds: 2),
//         ),
//       );

//       await _loadTasks();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "❌ Failed to update task: $e",
//             style: const TextStyle(color: Colors.white),
//           ),
//           backgroundColor: Colors.red.shade600,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return kSecondaryColor;
//       case 'confirmed':
//         return kPrimaryColor;
//       case 'completed':
//         return const Color(0xFF22C55E);
//       case 'rejected':
//         return const Color(0xFFEF4444);
//       default:
//         return const Color(0xFFA1A1A1);
//     }
//   }

//   Widget _statusBadge(String status) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _statusColor(status).withOpacity(0.15),
//         border: Border.all(color: _statusColor(status).withOpacity(0.8)),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           color: _statusColor(status),
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskCard(Task task) {
//     final isNew = task.status == 'pending' && widget.role == "provider";

//     // Status-based background color
//     Color cardBgColor = kCardColor;
//     switch (task.status) {
//       case "confirmed":
//         cardBgColor = Colors.blue.shade50;
//         break;
//       case "completed":
//         cardBgColor = Colors.green.shade50;
//         break;
//       case "rejected":
//         cardBgColor = Colors.red.shade50;
//         break;
//       default:
//         cardBgColor = kCardColor;
//     }

//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => TaskDetailPage(
//               currentUserId: widget.currentUserId,
//               providerId: task.providerId,
//               readOnly: widget.role == "provider",
//               taskData: widget.role == "provider"
//                   ? {
//                       'id': task.id,
//                       'user_id': task.userId,
//                       'notes': task.notes,
//                       'scheduled_date': task.scheduledDate.toIso8601String(),
//                       'title': task.serviceTitle,
//                       'service_title': task.serviceTitle,
//                       'price': '',
//                       'description': task.notes,
//                       'attachments': task.attachments,
//                       'attachment_details': task.attachmentDetails ?? '',
//                       'address': task.address,
//                       'latitude': task.latitude,
//                       'longitude': task.longitude,
//                     }
//                   : null,
//               serviceData: widget.role == "user"
//                   ? {
//                       'id': task.serviceId,
//                       'title': task.serviceTitle,
//                       'price': '',
//                       'description': task.notes,
//                     }
//                   : null,
//             ),
//           ),
//         );
//       },
//       child: Stack(
//         children: [
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             decoration: BoxDecoration(
//               color: cardBgColor,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isNew ? kPrimaryColor : Colors.transparent,
//                 width: isNew ? 1.5 : 0,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   offset: const Offset(0, 2),
//                   blurRadius: 4,
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(14.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Title & Status
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           task.serviceTitle,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 17,
//                             color: kTextPrimary,
//                           ),
//                         ),
//                       ),
//                       _statusBadge(task.status),
//                     ],
//                   ),
//                   const SizedBox(height: 8),

//                   // Scheduled Date
//                   _infoChip(
//                     icon: Icons.calendar_today,
//                     text: task.scheduledDate.toLocal().toString().split(' ')[0],
//                     color: kSecondaryColor,
//                   ),
//                   const SizedBox(height: 4),

//                   // User / Provider Info
//                   _infoChip(
//                     icon: widget.role == "user" ? Icons.handyman : Icons.person,
//                     text: widget.role == "user"
//                         ? task.providerName
//                         : task.userName,
//                     color: kTextPrimary,
//                   ),
//                   const SizedBox(height: 8),

//                   // Notes (1 line preview, tap to expand)
//                   if (task.notes.isNotEmpty)
//                     GestureDetector(
//                       onTap: () {
//                         showDialog(
//                           context: context,
//                           builder: (_) => AlertDialog(
//                             title: const Text("Notes"),
//                             content: Text(task.notes),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: const Text("Close"),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                       child: Text(
//                         "📝 Notes: ${task.notes.length > 50 ? task.notes.substring(0, 50) + "..." : task.notes}",
//                         style: TextStyle(color: kTextSecondary, fontSize: 13),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   const SizedBox(height: 8),

//                   // Task Status Message
//                   if (task.status != "completed")
//                     _statusMessage(
//                       "⚠️ This task is not completed yet",
//                       kSecondaryColor,
//                     ),
//                   if (task.status == "completed" && task.completedAt != null)
//                     _statusMessage(
//                       "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
//                       const Color(0xFF22C55E),
//                     ),
//                   const SizedBox(height: 8),

//                   // Action Buttons
//                   _buildActionButtons(task),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Widgets (same as before)
//   Widget _infoChip({
//     required IconData icon,
//     required String text,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: kBackgroundColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: color),
//           const SizedBox(width: 4),
//           Text(text, style: TextStyle(fontSize: 14, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _statusMessage(String message, Color color) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: kBackgroundColor,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         message,
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons(Task task) {
//     if (widget.role == "user") {
//       if (task.payment_status != "paid") {
//         return ElevatedButton(
//           onPressed: () => _payNow(task),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: kPrimaryColor,
//             foregroundColor: kCardColor,
//           ),
//           child: const Text("💳 Pay Now"),
//         );
//       }
//     } else if (widget.role == "provider") {
//       if (task.status == "pending") {
//         return Row(
//           children: [
//             ElevatedButton(
//               onPressed: () => _updateTask(task, "confirmed"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF22C55E),
//               ),
//               child: const Text(
//                 "Accept",
//                 style: TextStyle(color: kTextPrimary),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () => _updateTask(task, "rejected"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFEF4444),
//               ),
//               child: const Text(
//                 "Reject",
//                 style: TextStyle(color: kTextPrimary),
//               ),
//             ),
//           ],
//         );
//       } else if (task.status == "confirmed") {
//         return ElevatedButton(
//           onPressed: () => _updateTask(task, "completed"),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: kPrimaryColor,
//             foregroundColor: kCardColor,
//           ),
//           child: const Text("Mark Completed"),
//         );
//       }
//     }
//     return const SizedBox.shrink();
//   }

//   Widget _buildTaskList(List<Task> tasks) {
//     if (isLoading) return const Center(child: CircularProgressIndicator());
//     if (tasks.isEmpty)
//       return const Center(
//         child: Text("No tasks found", style: TextStyle(color: kTextSecondary)),
//       );

//     return RefreshIndicator(
//       onRefresh: _loadTasks,
//       child: ListView.builder(
//         itemCount: tasks.length,
//         itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kCardColor,
//       appBar: AppBar(
//         title: const Text(
//           "📋 My Tasks",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: heaidng,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 kBackgroundColor, // royal indigo
//                 kBackgroundColor, // violet glow
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(50),
//           child: Align(
//             alignment: Alignment.center,
//             child: TabBar(
//               controller: _tabController,
//               indicatorColor: kPrimaryColor, // soft gold underline
//               indicatorWeight: 3,
//               labelColor: kTextPrimary,
//               unselectedLabelColor: kTextSecondary,
//               labelStyle: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 16,
//               ),
//               tabs: const [
//                 Tab(text: "⏳ Pending"),
//                 Tab(text: "✅ Completed"),
//               ],
//             ),
//           ),
//         ),
//       ),

//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildTaskList(pendingTasks),
//           _buildTaskList(completedTasks),
//         ],
//       ),
//     );
//   }
// }




///////////////////////////////////////////////////////////////
///
///
///








// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'task_detail_screen.dart';
// import '../helpers/backend.dart';

// import '../helpers/coolors.dart';
// import 'sp_user_payment.dart';
// import '../providers/task_provider.dart';
// import 'package:provider/provider.dart';
// class Task {
//   final int id;
//   final int userId;
//   final int providerId;
//   final int serviceId;
//   final String status;
//   final DateTime scheduledDate;
//   final String? address; // new
//   final double? latitude; // new
//   final double? longitude; // new
//   final String notes;
//   final String serviceTitle;
//   final String userName;
//   final String providerName;
//   final String? attachmentDetails;
//   final DateTime? completedAt;
//   final List<Map<String, dynamic>> attachments; // <-- changed type
//   final String? payment_status;
//   double amount;
//   Task({
//     required this.id,
//     required this.userId,
//     required this.providerId,
//     required this.serviceId,
//     required this.status,
//     required this.scheduledDate,
//     this.address,
//     this.latitude,
//     this.longitude,
//     required this.notes,
//     required this.serviceTitle,
//     required this.userName,
//     required this.providerName,
//     this.attachmentDetails,
//     this.completedAt,
//     this.attachments = const [], // default empty list of maps
//     this.payment_status,
//     required this.amount, // new field
//   });

//   factory Task.fromJson(Map<String, dynamic> json) => Task(
//     id: json['id'] ?? 0,
//     userId: json['user_id'] ?? 0,
//     providerId: json['provider_id'] ?? 0,
//     serviceId: json['service_id'] ?? 0,
//     status: json['status'] ?? "pending",
//     scheduledDate:
//         DateTime.tryParse(json['scheduled_date'] ?? "") ?? DateTime.now(),
//     address: json['address'],
//     latitude: json['latitude'] != null
//         ? double.tryParse(json['latitude'].toString())
//         : null,
//     longitude: json['longitude'] != null
//         ? double.tryParse(json['longitude'].toString())
//         : null,
//     notes: json['notes'] ?? "",
//     serviceTitle: json['service_title'] ?? "Service",
//     userName: json['user_name'] ?? "User",
//     providerName: json['provider_name'] ?? "Provider",
//     attachmentDetails: json['attachment_details'],
//     completedAt: json['completed_at'] != null
//         ? DateTime.tryParse(json['completed_at'])
//         : null,
//     attachments: (json['attachments'] != null && json['attachments'] is List)
//         ? List<Map<String, dynamic>>.from(
//             (json['attachments'] as List).map(
//               (a) => Map<String, dynamic>.from(a),
//             ),
//           )
//         : [],
//     payment_status: json['payment_status'],
//     amount: json['amount'] != null
//         ? double.tryParse(json['amount'].toString()) ?? 0
//         : 0, // new
//   );
// }

// class TasksApi {
//   static Future<List<Task>> fetchTasks({int? userId, int? providerId}) async {
//     final Map<String, String> queryParams = {};
//     if (userId != null) queryParams['user_id'] = userId.toString();
//     if (providerId != null) queryParams['provider_id'] = providerId.toString();

//     final uri = Uri.parse(
//       "${Backend.baseUrl}/tasks",
//     ).replace(queryParameters: queryParams);

//     final response = await http.get(uri);

//     if (response.statusCode == 200) {
//       final List data = json.decode(response.body)['tasks'];
//       return data.map((t) => Task.fromJson(t)).toList();
//     } else {
//       throw Exception("Failed to load tasks");
//     }
//   }

//   static Future<Task> updateTaskStatus(int taskId, String status) async {
//     final uri = Uri.parse("${Backend.baseUrl}/tasks/$taskId");

//     final response = await http.patch(
//       uri,
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({"status": status}),
//     );

//     if (response.statusCode == 200) {
//       return Task.fromJson(json.decode(response.body)['task']);
//     } else {
//       throw Exception("Failed to update task");
//     }
//   }
// }

// class MyTasksScreen extends StatefulWidget {
//   final String role; // "user" or "provider"
//   final int currentUserId;

//   const MyTasksScreen({
//     super.key,
//     required this.role,
//     required this.currentUserId,
//   });

//   @override
//   State<MyTasksScreen> createState() => _MyTasksScreenState();
// }

// class _MyTasksScreenState extends State<MyTasksScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   // List<Task> pendingTasks = [];
//   // List<Task> completedTasks = [];
//   // bool isLoading = true;

//   @override
// void initState() {
//   super.initState();
//   _tabController = TabController(length: 2, vsync: this);

//   // Load tasks via Provider
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     final taskProvider = Provider.of<TaskProvider>(context, listen: false);
//     taskProvider.loadTasks(widget.currentUserId, role: widget.role);
//   });
// }


//   void _payNow(Task task) async {
//     print("💡 _payNow called for Task ID: ${task.id}");

//     if (task.userId == 0 || task.providerId == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "⚠️ Task missing user or provider info. Please refresh.",
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // Step 1: Ask user to enter the amount dynamically
//     double enteredAmount = task.amount; // default value
//     final result = await showDialog<double>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Enter Amount to Pay"),
//         content: TextField(
//           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//           decoration: InputDecoration(
//             hintText: task.amount.toStringAsFixed(2), // show default nicely
//           ),
//           onChanged: (val) {
//             enteredAmount = double.tryParse(val) ?? task.amount;
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, null),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               if (enteredAmount <= 0) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("❌ Enter a valid amount greater than 0"),
//                     backgroundColor: Colors.redAccent,
//                   ),
//                 );
//                 return;
//               }
//               Navigator.pop(ctx, enteredAmount);
//             },
//             child: const Text("Pay"),
//           ),
//         ],
//       ),
//     );

//     if (result == null) return; // user cancelled
//     task.amount = result; // set task amount dynamically

//     // Step 2: Show loading while creating payment
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) =>
//           const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
//     );

//     try {
//       // ✅ Use task.amount dynamically
//       final paymentResponse = await PaymentApi.createPayment(
//         userId: task.userId,
//         spId: task.providerId,
//         taskId: task.id,
//         amount: task.amount,
//       );

//       final paymentUrl = paymentResponse['payment_url']!;
//       final txnId = paymentResponse['txnId']!;
//       final ordId = paymentResponse['ordId']!;

//       Navigator.pop(context); // close loading dialog

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => PaymentWebViewScreen(
//             url: paymentUrl,
//             taskId: task.id,
//             userId: task.userId,
//             spId: task.providerId,
//             amount: task.amount,
//             txnId: txnId,
//             ordId: ordId,
//             onPaymentSuccess: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text("✅ Payment successful!"),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//               Provider.of<TaskProvider>(context, listen: false)
//     .refreshTasks(widget.currentUserId, role: widget.role);
//  // refresh tasks after payment success
//             },
//           ),
//         ),
//       );
//     } catch (e) {
//       if (Navigator.canPop(context)) Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("❌ Payment failed: ${e.toString()}"),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }









  



//   Future<void> _updateTask(Task task, String newStatus) async {
//     bool confirm = true;

//     if (newStatus == "completed") {
//       confirm =
//           await showDialog(
//             context: context,
//             builder: (ctx) => AlertDialog(
//               backgroundColor: kPrimaryColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               title: Text(
//                 'Complete Task',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: kCardColor,
//                 ),
//               ),
//               content: Text(
//                 'Are you sure you have completed this task carefully?',
//                 style: TextStyle(fontSize: 16, color: kTextPrimary),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, false),
//                   style: TextButton.styleFrom(
//                     backgroundColor: kPrimaryColor.withOpacity(0.3),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'Cancel',
//                     style: TextStyle(
//                       color: kCardColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, true),
//                   style: TextButton.styleFrom(
//                     backgroundColor: kPrimaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Yes, Completed',
//                     style: TextStyle(
//                       color: kCardColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ) ??
//           false;
//     }

//     if (!confirm) return;

//     try {
//       await TasksApi.updateTaskStatus(task.id, newStatus);

//       String message = '';
//       Color snackColor = kPrimaryColor;

//       if (newStatus == "confirmed") {
//         message = "✅ Task accepted";
//         snackColor = Colors.green.shade700;

//         // 🔹 Send notification to user
//         NotificationsApi.sendNotification(
//           userId: task.userId,
//           title: "Task Accepted ✅",
//           body:
//               "Your task '${task.serviceTitle}' has been accepted✅ by the provider",
//           senderId: task.providerId,
//         );
//       }

//       if (newStatus == "rejected") {
//         message = "❌ Task rejected";
//         snackColor = Colors.red.shade600;

//         // 🔹 Send notification to user
//         NotificationsApi.sendNotification(
//           userId: task.userId,
//           title: "Task Rejected ❌",
//           body:
//               "Your task '${task.serviceTitle}' has been rejected❌ by the provider",
//           senderId: task.providerId,
//         );
//       }

//       if (newStatus == "completed") {
//         message = "🎉 Task completed";
//         snackColor = kPrimaryColor;

//         // 🔹 Send notification to user
//         NotificationsApi.sendNotification(
//           userId: task.userId,
//           title: "Task Completed 🎉",
//           body:
//               "Your task '${task.serviceTitle}' has been marked as completed🎉 by the provider",
//           senderId: task.providerId,
//         );
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             message,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           backgroundColor: snackColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           duration: const Duration(seconds: 2),
//         ),
//       );

//       Provider.of<TaskProvider>(context, listen: false)
//     .refreshTasks(widget.currentUserId, role: widget.role);

//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "❌ Failed to update task: $e",
//             style: const TextStyle(color: Colors.white),
//           ),
//           backgroundColor: Colors.red.shade600,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return kSecondaryColor;
//       case 'confirmed':
//         return kPrimaryColor;
//       case 'completed':
//         return const Color(0xFF22C55E);
//       case 'rejected':
//         return const Color(0xFFEF4444);
//       default:
//         return const Color(0xFFA1A1A1);
//     }
//   }

//   Widget _statusBadge(String status) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _statusColor(status).withOpacity(0.15),
//         border: Border.all(color: _statusColor(status).withOpacity(0.8)),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           color: _statusColor(status),
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }












//   Widget _buildTaskCard(Task task) {
//     final isNew = task.status == 'pending' && widget.role == "provider";

//     // Status-based background color
//     Color cardBgColor = kCardColor;
//     switch (task.status) {
//       case "confirmed":
//         cardBgColor = Colors.blue.shade50;
//         break;
//       case "completed":
//         cardBgColor = Colors.green.shade50;
//         break;
//       case "rejected":
//         cardBgColor = Colors.red.shade50;
//         break;
//       default:
//         cardBgColor = kCardColor;
//     }

//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => TaskDetailPage(
//               currentUserId: widget.currentUserId,
//               providerId: task.providerId,
//               readOnly: widget.role == "provider",
//               taskData: widget.role == "provider"
//                   ? {
//                       'id': task.id,
//                       'user_id': task.userId,
//                       'notes': task.notes,
//                       'scheduled_date': task.scheduledDate.toIso8601String(),
//                       'title': task.serviceTitle,
//                       'service_title': task.serviceTitle,
//                       'price': '',
//                       'description': task.notes,
//                       'attachments': task.attachments,
//                       'attachment_details': task.attachmentDetails ?? '',
//                       'address': task.address,
//                       'latitude': task.latitude,
//                       'longitude': task.longitude,
//                     }
//                   : null,
//               serviceData: widget.role == "user"
//                   ? {
//                       'id': task.serviceId,
//                       'title': task.serviceTitle,
//                       'price': '',
//                       'description': task.notes,
//                     }
//                   : null,
//             ),
//           ),
//         );
//       },
//       child: Stack(
//         children: [
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             decoration: BoxDecoration(
//               color: cardBgColor,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isNew ? kPrimaryColor : Colors.transparent,
//                 width: isNew ? 1.5 : 0,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   offset: const Offset(0, 2),
//                   blurRadius: 4,
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(14.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Title & Status
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           task.serviceTitle,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 17,
//                             color: kTextPrimary,
//                           ),
//                         ),
//                       ),
//                       _statusBadge(task.status),
//                     ],
//                   ),
//                   const SizedBox(height: 8),

//                   // Scheduled Date
//                   _infoChip(
//                     icon: Icons.calendar_today,
//                     text: task.scheduledDate.toLocal().toString().split(' ')[0],
//                     color: kSecondaryColor,
//                   ),
//                   const SizedBox(height: 4),

//                   // User / Provider Info
//                   _infoChip(
//                     icon: widget.role == "user" ? Icons.handyman : Icons.person,
//                     text: widget.role == "user"
//                         ? task.providerName
//                         : task.userName,
//                     color: kTextPrimary,
//                   ),
//                   const SizedBox(height: 8),

//                   // Notes (1 line preview, tap to expand)
//                   if (task.notes.isNotEmpty)
//                     GestureDetector(
//                       onTap: () {
//                         showDialog(
//                           context: context,
//                           builder: (_) => AlertDialog(
//                             title: const Text("Notes"),
//                             content: Text(task.notes),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: const Text("Close"),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                       child: Text(
//                         "📝 Notes: ${task.notes.length > 50 ? task.notes.substring(0, 50) + "..." : task.notes}",
//                         style: TextStyle(color: kTextSecondary, fontSize: 13),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   const SizedBox(height: 8),

//                   // Task Status Message
//                   if (task.status != "completed")
//                     _statusMessage(
//                       "⚠️ This task is not completed yet",
//                       kSecondaryColor,
//                     ),
//                   if (task.status == "completed" && task.completedAt != null)
//                     _statusMessage(
//                       "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
//                       const Color(0xFF22C55E),
//                     ),
//                   const SizedBox(height: 8),

//                   // Action Buttons
//                   _buildActionButtons(task),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
















//   // Helper Widgets (same as before)
//   Widget _infoChip({
//     required IconData icon,
//     required String text,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: kBackgroundColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: color),
//           const SizedBox(width: 4),
//           Text(text, style: TextStyle(fontSize: 14, color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _statusMessage(String message, Color color) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: kBackgroundColor,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         message,
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons(Task task) {
//     if (widget.role == "user") {
//       if (task.payment_status != "paid") {
//         return ElevatedButton(
//           onPressed: () => _payNow(task),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: kPrimaryColor,
//             foregroundColor: kCardColor,
//           ),
//           child: const Text("💳 Pay Now"),
//         );
//       }
//     } else if (widget.role == "provider") {
//       if (task.status == "pending") {
//         return Row(
//           children: [
//             ElevatedButton(
//               onPressed: () => _updateTask(task, "confirmed"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF22C55E),
//               ),
//               child: const Text(
//                 "Accept",
//                 style: TextStyle(color: kTextPrimary),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () => _updateTask(task, "rejected"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFEF4444),
//               ),
//               child: const Text(
//                 "Reject",
//                 style: TextStyle(color: kTextPrimary),
//               ),
//             ),
//           ],
//         );
//       } else if (task.status == "confirmed") {
//         return ElevatedButton(
//           onPressed: () => _updateTask(task, "completed"),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: kPrimaryColor,
//             foregroundColor: kCardColor,
//           ),
//           child: const Text("Mark Completed"),
//         );
//       }
//     }
//     return const SizedBox.shrink();
//   }

//  Widget _buildTaskList(bool isPending) {
//   return RefreshIndicator(
//     onRefresh: () => Provider.of<TaskProvider>(context, listen: false)
//         .refreshTasks(widget.currentUserId, role: widget.role),
//     child: Consumer<TaskProvider>(
//       builder: (context, taskProvider, _) {
//         final taskList =
//             isPending ? taskProvider.pendingTasks : taskProvider.completedTasks;

//         if (taskProvider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (taskList.isEmpty) {
//           return const Center(
//             child: Text("No tasks found", style: TextStyle(color: kTextSecondary)),
//           );
//         }

//         return ListView.builder(
//           itemCount: taskList.length,
//           itemBuilder: (context, index) => _buildTaskCard(taskList[index]),
//         );
//       },
//     ),
//   );
// }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: kCardColor,
//     appBar: AppBar(
//       title: const Text(
//         "📋 My Tasks",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//           color: heaidng,
//         ),
//       ),
//       centerTitle: true,
//       elevation: 0,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               kBackgroundColor,
//               kBackgroundColor,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//       ),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//       ),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(50),
//         child: Align(
//           alignment: Alignment.center,
//           child: TabBar(
//             controller: _tabController,
//             indicatorColor: kPrimaryColor,
//             indicatorWeight: 3,
//             labelColor: kTextPrimary,
//             unselectedLabelColor: kTextSecondary,
//             labelStyle: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontWeight: FontWeight.w500,
//               fontSize: 16,
//             ),
//             tabs: const [
//               Tab(text: "⏳ Pending"),
//               Tab(text: "✅ Completed"),
//             ],
//           ),
//         ),
//       ),
//     ),
//     body: TabBarView(
//       controller: _tabController,
//       children: [
//         _buildTaskList(true),  // Pending tasks
//         _buildTaskList(false), // Completed tasks
//       ],
//     ),
//   );
// }

// }
























/////////////////////////////////////////
///

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'task_detail_screen.dart';
import '../helpers/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ExternalProfileWidget.dart'; 
import '../helpers/coolors.dart';
import 'sp_user_payment.dart';
import '../providers/task_provider.dart';
import 'package:provider/provider.dart';
class Task {
  final int id;
  final int userId;
  final int providerId;
  final int serviceId;
  final String status;
  final DateTime scheduledDate;
  final String? address; // new
  final double? latitude; // new
  final double? longitude; // new
  final String notes;
  final String serviceTitle;
  final String userName;
  final String providerName;
  final String? attachmentDetails;
  final DateTime? completedAt;
  final List<Map<String, dynamic>> attachments; // <-- changed type
  final String? payment_status;
  double amount;
  Task({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.scheduledDate,
    this.address,
    this.latitude,
    this.longitude,
    required this.notes,
    required this.serviceTitle,
    required this.userName,
    required this.providerName,
    this.attachmentDetails,
    this.completedAt,
    this.attachments = const [], // default empty list of maps
    this.payment_status,
    required this.amount, // new field
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] ?? 0,
    userId: json['user_id'] ?? 0,
    providerId: json['provider_id'] ?? 0,
    serviceId: json['service_id'] ?? 0,
    status: json['status'] ?? "pending",
    scheduledDate:
        DateTime.tryParse(json['scheduled_date'] ?? "") ?? DateTime.now(),
    address: json['address'],
    latitude: json['latitude'] != null
        ? double.tryParse(json['latitude'].toString())
        : null,
    longitude: json['longitude'] != null
        ? double.tryParse(json['longitude'].toString())
        : null,
    notes: json['notes'] ?? "",
    serviceTitle: json['service_title'] ?? "Service",
    userName: json['user_name'] ?? "User",
    providerName: json['provider_name'] ?? "Provider",
    attachmentDetails: json['attachment_details'],
    completedAt: json['completed_at'] != null
        ? DateTime.tryParse(json['completed_at'])
        : null,
    attachments: (json['attachments'] != null && json['attachments'] is List)
        ? List<Map<String, dynamic>>.from(
            (json['attachments'] as List).map(
              (a) => Map<String, dynamic>.from(a),
            ),
          )
        : [],
    payment_status: json['payment_status'],
    amount: json['amount'] != null
        ? double.tryParse(json['amount'].toString()) ?? 0
        : 0, // new
  );
}

class TasksApi {
  static Future<List<Task>> fetchTasks({int? userId, int? providerId}) async {
    final Map<String, String> queryParams = {};
    if (userId != null) queryParams['user_id'] = userId.toString();
    if (providerId != null) queryParams['provider_id'] = providerId.toString();

    final uri = Uri.parse(
      "${Backend.baseUrl}/tasks",
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['tasks'];
      return data.map((t) => Task.fromJson(t)).toList();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  static Future<Task> updateTaskStatus(int taskId, String status) async {
    final uri = Uri.parse("${Backend.baseUrl}/tasks/$taskId");

    final response = await http.patch(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": status}),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body)['task']);
    } else {
      throw Exception("Failed to update task");
    }
  }
}

class MyTasksScreen extends StatefulWidget {
  final String role; // "user" or "provider"
  final int currentUserId;

  const MyTasksScreen({
    super.key,
    required this.role,
    required this.currentUserId,
  });

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);

  // Load tasks via Provider
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.loadTasks(widget.currentUserId, role: widget.role);
  });
}




  void _payNow(Task task) async {
    print("💡 _payNow called for Task ID: ${task.id}");

    if (task.userId == 0 || task.providerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "⚠️ Task missing user or provider info. Please refresh.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Step 1: Ask user to enter the amount dynamically
    double enteredAmount = task.amount; // default value
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Amount to Pay"),
        content: TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: task.amount.toStringAsFixed(2), // show default nicely
          ),
          onChanged: (val) {
            enteredAmount = double.tryParse(val) ?? task.amount;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (enteredAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❌ Enter a valid amount greater than 0"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              Navigator.pop(ctx, enteredAmount);
            },
            child: const Text("Pay"),
          ),
        ],
      ),
    );

    if (result == null) return; // user cancelled
    task.amount = result; // set task amount dynamically

    // Step 2: Show loading while creating payment
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
    );

    try {
      // ✅ Use task.amount dynamically
      final paymentResponse = await PaymentApi.createPayment(
        userId: task.userId,
        spId: task.providerId,
        taskId: task.id,
        amount: task.amount,
      );

      final paymentUrl = paymentResponse['payment_url']!;
      final txnId = paymentResponse['txnId']!;
      final ordId = paymentResponse['ordId']!;

      Navigator.pop(context); // close loading dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            url: paymentUrl,
            taskId: task.id,
            userId: task.userId,
            spId: task.providerId,
            amount: task.amount,
            txnId: txnId,
            ordId: ordId,
            onPaymentSuccess: () async{
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Payment successful!"),
                  backgroundColor: Colors.green,
                ),
              );
              Provider.of<TaskProvider>(context, listen: false)
    .refreshTasks(widget.currentUserId, role: widget.role);

// ----------------- Add Comment Popup Logic -----------------
  final prefs = await SharedPreferences.getInstance();
  final key = 'comment_dialog_shown_task_${task.id}';
  final alreadyShown = prefs.getBool(key) ?? false;

  if (!alreadyShown) {
    // show dialog once
    showDialog(
      context: context,
      builder: (_) {
        return ExternalProfileWidget(
          userData: {
            'id': task.providerId,
            'name': task.providerName,
            'role': 'provider',
          },
          currentUserId: widget.currentUserId,
        );
      },
    );

    await prefs.setBool(key, true); // mark as shown
  }


            },
          ),
        ),
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Payment failed: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }









  



  Future<void> _updateTask(Task task, String newStatus) async {
    bool confirm = true;

    if (newStatus == "completed") {
      confirm =
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Complete Task',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: kCardColor,
                ),
              ),
              content: Text(
                'Are you sure you have completed this task carefully?',
                style: TextStyle(fontSize: 16, color: kTextPrimary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: TextButton.styleFrom(
                    backgroundColor: kPrimaryColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: kCardColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Yes, Completed',
                    style: TextStyle(
                      color: kCardColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    }

    if (!confirm) return;

    try {
      await TasksApi.updateTaskStatus(task.id, newStatus);

      String message = '';
      Color snackColor = kPrimaryColor;

      if (newStatus == "confirmed") {
        message = "✅ Task accepted";
        snackColor = Colors.green.shade700;

        // 🔹 Send notification to user
        NotificationsApi.sendNotification(
          userId: task.userId,
          title: "Task Accepted ✅",
          body:
              "Your task '${task.serviceTitle}' has been accepted✅ by the provider",
          senderId: task.providerId,
        );
      }

      if (newStatus == "rejected") {
        message = "❌ Task rejected";
        snackColor = Colors.red.shade600;

        // 🔹 Send notification to user
        NotificationsApi.sendNotification(
          userId: task.userId,
          title: "Task Rejected ❌",
          body:
              "Your task '${task.serviceTitle}' has been rejected❌ by the provider",
          senderId: task.providerId,
        );
      }

      if (newStatus == "completed") {
        message = "🎉 Task completed";
        snackColor = kPrimaryColor;

        // 🔹 Send notification to user
        NotificationsApi.sendNotification(
          userId: task.userId,
          title: "Task Completed 🎉",
          body:
              "Your task '${task.serviceTitle}' has been marked as completed🎉 by the provider",
          senderId: task.providerId,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: snackColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          duration: const Duration(seconds: 2),
        ),
      );

      Provider.of<TaskProvider>(context, listen: false)
    .refreshTasks(widget.currentUserId, role: widget.role);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ Failed to update task: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return kSecondaryColor;
      case 'confirmed':
        return kPrimaryColor;
      case 'completed':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFA1A1A1);
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.15),
        border: Border.all(color: _statusColor(status).withOpacity(0.8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }












  Widget _buildTaskCard(Task task) {
    final isNew = task.status == 'pending' && widget.role == "provider";

    // Status-based background color
    Color cardBgColor = kCardColor;
    switch (task.status) {
      case "confirmed":
        cardBgColor = Colors.blue.shade50;
        break;
      case "completed":
        cardBgColor = Colors.green.shade50;
        break;
      case "rejected":
        cardBgColor = Colors.red.shade50;
        break;
      default:
        cardBgColor = kCardColor;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailPage(
              currentUserId: widget.currentUserId,
              providerId: task.providerId,
              readOnly: widget.role == "provider",
              taskData: widget.role == "provider"
                  ? {
                      'id': task.id,
                      'user_id': task.userId,
                      'notes': task.notes,
                      'scheduled_date': task.scheduledDate.toIso8601String(),
                      'title': task.serviceTitle,
                      'service_title': task.serviceTitle,
                      'price': '',
                      'description': task.notes,
                      'attachments': task.attachments,
                      'attachment_details': task.attachmentDetails ?? '',
                      'address': task.address,
                      'latitude': task.latitude,
                      'longitude': task.longitude,
                    }
                  : null,
              serviceData: widget.role == "user"
                  ? {
                      'id': task.serviceId,
                      'title': task.serviceTitle,
                      'price': '',
                      'description': task.notes,
                    }
                  : null,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNew ? kPrimaryColor : Colors.transparent,
                width: isNew ? 1.5 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.serviceTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: kTextPrimary,
                          ),
                        ),
                      ),
                      _statusBadge(task.status),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Scheduled Date
                  _infoChip(
                    icon: Icons.calendar_today,
                    text: task.scheduledDate.toLocal().toString().split(' ')[0],
                    color: kSecondaryColor,
                  ),
                  const SizedBox(height: 4),

                  // User / Provider Info
                  _infoChip(
                    icon: widget.role == "user" ? Icons.handyman : Icons.person,
                    text: widget.role == "user"
                        ? task.providerName
                        : task.userName,
                    color: kTextPrimary,
                  ),
                  const SizedBox(height: 8),

                  // Notes (1 line preview, tap to expand)
                  if (task.notes.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Notes"),
                            content: Text(task.notes),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        "📝 Notes: ${task.notes.length > 50 ? task.notes.substring(0, 50) + "..." : task.notes}",
                        style: TextStyle(color: kTextSecondary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Task Status Message
                  if (task.status != "completed")
                    _statusMessage(
                      "⚠️ This task is not completed yet",
                      kSecondaryColor,
                    ),
                  if (task.status == "completed" && task.completedAt != null)
                    _statusMessage(
                      "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
                      const Color(0xFF22C55E),
                    ),
                  const SizedBox(height: 8),

                  // Action Buttons
                  _buildActionButtons(task),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
















  // Helper Widgets (same as before)
  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
    );
  }

  Widget _statusMessage(String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Task task) {
    if (widget.role == "user") {
      if (task.payment_status != "paid") {
        return ElevatedButton(
          onPressed: () => _payNow(task),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: kCardColor,
          ),
          child: const Text("💳 Pay Now"),
        );
      }
    } else if (widget.role == "provider") {
      if (task.status == "pending") {
        return Row(
          children: [
            ElevatedButton(
              onPressed: () => _updateTask(task, "confirmed"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
              ),
              child: const Text(
                "Accept",
                style: TextStyle(color: kTextPrimary),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _updateTask(task, "rejected"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text(
                "Reject",
                style: TextStyle(color: kTextPrimary),
              ),
            ),
          ],
        );
      } else if (task.status == "confirmed") {
        return ElevatedButton(
          onPressed: () => _updateTask(task, "completed"),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: kCardColor,
          ),
          child: const Text("Mark Completed"),
        );
      }
    }
    return const SizedBox.shrink();
  }

 Widget _buildTaskList(bool isPending) {
  return RefreshIndicator(
    onRefresh: () => Provider.of<TaskProvider>(context, listen: false)
        .refreshTasks(widget.currentUserId, role: widget.role),
    child: Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final taskList =
            isPending ? taskProvider.pendingTasks : taskProvider.completedTasks;

        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskList.isEmpty) {
          return const Center(
            child: Text("No tasks found", style: TextStyle(color: kTextSecondary)),
          );
        }

        return ListView.builder(
          itemCount: taskList.length,
          itemBuilder: (context, index) => _buildTaskCard(taskList[index]),
        );
      },
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: kCardColor,
    appBar: AppBar(
      title: const Text(
        "📋 My Tasks",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: heaidng,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kBackgroundColor,
              kBackgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Align(
          alignment: Alignment.center,
          child: TabBar(
            controller: _tabController,
            indicatorColor: kPrimaryColor,
            indicatorWeight: 3,
            labelColor: kTextPrimary,
            unselectedLabelColor: kTextSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            tabs: const [
              Tab(text: "⏳ Pending"),
              Tab(text: "✅ Completed"),
            ],
          ),
        ),
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        _buildTaskList(true),  // Pending tasks
        _buildTaskList(false), // Completed tasks
      ],
    ),
  );
}

}
