// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'task_detail_screen.dart';
// import '../helpers/backend.dart';
// import 'MyProfileScreen.dart';
// import '../helpers/coolors.dart';
// import 'sp_user_payment.dart';
// import '../providers/task_provider.dart';
// import 'package:provider/provider.dart';
// import '../widgets/tasksWidget.dart';
// import 'package:lottie/lottie.dart';
// import 'notifications_page.dart';
// import '../widgets/fourCardsTask.dart';

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

// int toDo = 0;
// int inProgress = 0;
// int inReview = 0;
// int completed = 0;

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
//   final Map<String, dynamic> currentUser;

//   const MyTasksScreen({
//     super.key,
//     required this.role,
//     required this.currentUserId,
//     required this.currentUser,
//   });

//   @override
//   State<MyTasksScreen> createState() => _MyTasksScreenState();
// }

// class _MyTasksScreenState extends State<MyTasksScreen>
//     with SingleTickerProviderStateMixin {
//   late Map<String, dynamic> currentUser;
//   @override
//   void initState() {
//     super.initState();

//     // ✅ Use widget.currentUser directly
//     currentUser = widget.currentUser;
//     print("Profile Image URL: ${currentUser['profile_image']}");
//     fetchTaskSummary();
//     // Load tasks via Provider
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final taskProvider = Provider.of<TaskProvider>(context, listen: false);
//       taskProvider.loadTasks(widget.currentUserId, role: widget.role);
//     });
//   }

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
//            onPaymentSuccess: () async {
//   // 1️⃣ Refresh tasks silently
//   Provider.of<TaskProvider>(
//     context,
//     listen: false,
//   ).refreshTasks(widget.currentUserId, role: widget.role);

//   // 2️⃣ Close payment WebView
//   Navigator.pop(context);

//   // 3️⃣ Go to the provider profile (jis ka task pay hua)
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => MyProfileScreen(
//         userData: {
//           'id': task.providerId,
//           'name': task.providerName,
//           'role': 'provider',
//         },
//         currentUserId: widget.currentUserId,
//         readOnly: true, // user kisi aur ki profile dekh raha hai
//       ),
//     ),
//   );
// },

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

//   Future<void> fetchTaskSummary() async {
//     try {
//       final uri = Uri.parse(
//         '${Backend.baseUrl}/tasks/summary?user_id=${widget.currentUserId}',
//       ); // changed provider_id → user_id
//       final res = await http.get(uri);

//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         setState(() {
//           toDo = data['totalTasks'] ?? 0; // Total tasks
//           inProgress = data['inProgressTasks'] ?? 0; // In progress (confirmed)
//           inReview = data['rejectedTasks'] ?? 0; // Rejected
//           completed = data['completedTasks'] ?? 0; // Completed
//         });
//       } else {
//         throw Exception('Failed to fetch task summary');
//       }
//     } catch (e) {
//       print("Error fetching task summary: $e");
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

//       Provider.of<TaskProvider>(
//         context,
//         listen: false,
//       ).refreshTasks(widget.currentUserId, role: widget.role);
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

//   // --- Status Badge ---
//   Widget _statusBadge(String status) {
//     final Color badgeColor;
//     switch (status) {
//       case "confirmed":
//         badgeColor = Color(0xFF40916C); // Soft green
//         break;
//       case "completed":
//         badgeColor = Color(0xFF1E6091); // Soft blue
//         break;
//       case "rejected":
//         badgeColor = Color(0xFFB02A37); // Soft red
//         break;
//       default:
//         badgeColor = Color(0xFF9D6B53); // Soft brown/orange for pending
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: badgeColor.withOpacity(0.15), // Light tint
//         border: Border.all(color: badgeColor.withOpacity(0.8)),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           color: badgeColor,
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskCard(Task task) {
//     final isNew = task.status == 'pending' && widget.role == "provider";

//     // --- Status-based background color (Soft & Calm) ---
//     Color cardBgColor;
//     switch (task.status) {
//       case "confirmed": // In Progress
//         cardBgColor = Color(0xFFD1E7DD); // Soft green
//         break;
//       case "completed":
//         cardBgColor = Color(0xFFCCE5FF); // Light blue
//         break;
//       case "rejected":
//         cardBgColor = Color(0xFFF8D7DA); // Soft pink
//         break;
//       default: // pending
//         cardBgColor = Color(0xFFFFF3CD); // Soft yellow
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
//                   color: Colors.black.withOpacity(0.05), // Soft shadow
//                   offset: const Offset(0, 1),
//                   blurRadius: 3,
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
//                             color: Colors.black87, // Soft text
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
//                     color: Colors.grey[700]!,
//                   ),
//                   const SizedBox(height: 4),

//                   // User / Provider Info
//                   _infoChip(
//                     icon: widget.role == "user" ? Icons.handyman : Icons.person,
//                     text: widget.role == "user"
//                         ? task.providerName
//                         : task.userName,
//                     color: Colors.grey[800]!,
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
//                         style: TextStyle(color: Colors.grey[700], fontSize: 13),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   const SizedBox(height: 8),

//                   // Task Status Message
//                   if (task.status != "completed")
//                     _statusMessage(
//                       "⚠️ This task is not completed yet",
//                       Colors.grey[700]!,
//                     ),
//                   if (task.status == "completed" && task.completedAt != null)
//                     _statusMessage(
//                       "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
//                       Color(0xFF22C55E),
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
//   // --- Info Chip ---
//   Widget _infoChip({
//     required IconData icon,
//     required String text,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey[100], // Soft background
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: Colors.grey[800]), // Soft dark gray
//           const SizedBox(width: 4),
//           Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
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

//   // --- Action Buttons ---
//   Widget _buildActionButtons(Task task) {
//     if (widget.role == "user") {
//       if (task.payment_status != "paid") {
//         return ElevatedButton(
//           onPressed: () => _payNow(task),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue[300], // Soft blue
//             foregroundColor: Colors.white,
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
//                 backgroundColor: Colors.green[300], // Soft green
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Accept"),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () => _updateTask(task, "rejected"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red[300], // Soft red
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text("Reject"),
//             ),
//           ],
//         );
//       } else if (task.status == "confirmed") {
//         return ElevatedButton(
//           onPressed: () => _updateTask(task, "completed"),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.teal[300], // Soft teal
//             foregroundColor: Colors.white,
//           ),
//           child: const Text("Mark Completed"),
//         );
//       }
//     }
//     return const SizedBox.shrink();
//   }

//   Widget _buildFilteredTasks(
//     TaskProvider taskProvider, {
//     String? status,
//     String? filterByDate,
//   }) {
//     List<Task> tasks = [
//       ...taskProvider.pendingTasks,
//       ...taskProvider.completedTasks,
//     ];

//     // Status filter
//     if (status != null) {
//       tasks = tasks.where((t) => t.status == status).toList();
//     }

//     // Date filter
//     if (filterByDate != null) {
//       DateTime now = DateTime.now();
//       tasks = tasks.where((t) {
//         if (filterByDate == "week") {
//           return t.scheduledDate.isAfter(now.subtract(const Duration(days: 7)));
//         } else if (filterByDate == "month") {
//           return t.scheduledDate.isAfter(
//             DateTime(now.year, now.month - 1, now.day),
//           );
//         } else if (filterByDate == "older") {
//           return t.scheduledDate.isBefore(
//             DateTime(now.year, now.month - 1, now.day),
//           );
//         }
//         return true;
//       }).toList();
//     }

//     if (tasks.isEmpty) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Lottie.asset(
//               'assets/lottie/No History.json',
//               width: 200,
//               height: 200,
//               repeat: true,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "No tasks found",
//               style: TextStyle(
//                 color: kTextSecondary,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//     return ListView.builder(
//       physics: const BouncingScrollPhysics(),
//       itemCount: tasks.length,
//       itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: kBackgroundColor,

//       // ---------------------- AppBar ----------------------
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(50),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           elevation: 0,
//           backgroundColor: kPrimaryColor.withOpacity(0.1) ,

//           title: Padding(
//             padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Profile
//                 Builder(
//                   builder: (_) {
//                     String profileImagePath =
//                         currentUser['profile_image'] ?? '';
//                     String fullImageUrl = profileImagePath.startsWith("http")
//                         ? profileImagePath
//                         : "${Backend.baseUrl}/$profileImagePath";

//                     return CircleAvatar(
//                       radius: 20,
//                       backgroundColor: Colors.grey.shade300,
//                       backgroundImage: fullImageUrl.isNotEmpty
//                           ? NetworkImage(fullImageUrl)
//                           : null,
//                       child: fullImageUrl.isEmpty
//                           ? Icon(
//                               Icons.person,
//                               color: Colors.grey.shade600,
//                               size: 24,
//                             )
//                           : null,
//                     );
//                   },
//                 ),

//                 const SizedBox(width: 14),

//                 // Username
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Hello,",
//                       style: TextStyle(color: kTextSecondary, fontSize: 14),
//                     ),
//                     Text(
//                       currentUser['username'] ?? 'Username',
//                       style: const TextStyle(
//                         color: kTextPrimary,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//            IconButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => NotificationsPage(
//           userId: currentUser['id'],
//           role: widget.role,
//           tab: 'tasks', // 🔹 yaha 'tasks' ya 'messages' pass kar do
//         ),
//       ),
//     );
//   },
//   icon: const Icon(
//     Icons.notifications_none,
//     color: kTextPrimary,
//     size: 28,
//   ),
// ),

//             IconButton(
//               onPressed: () {},
//               icon: const Icon(Icons.search, color: kTextPrimary, size: 28),
//             ),
//             const SizedBox(width: 8),
//           ],
//         ),
//       ),

//       // ---------------------- Body ----------------------
//       body: Consumer<TaskProvider>(
//         builder: (context, taskProvider, _) {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [

//                 // --- Task Cards ---
//                 const SizedBox(height: 10),
//                 TaskCardsWidget(
//                   toDo: toDo,
//                   inProgress: inProgress,
//                   inReview: inReview,
//                   completed: completed,
//                 ),

//                 const SizedBox(height: 6),

//                 // const SizedBox(height: 3), // compact spacing
//                 // --- Clock & Day Box ---
//                 SizedBox(
//                   height: screenHeight * 0.18,
//                   child: const ClockAndDayBox(),
//                 ),

//                 const SizedBox(height: 10), // before Tabs
//                 // --- Tabs Section ---
//                 // --- Tabs Section ---
//                 DefaultTabController(
//                   length: 4, // Only 4 tabs now
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       TabBar(
//                         isScrollable: true,
//                         labelColor: kTextPrimary,
//                         unselectedLabelColor: kTextSecondary,
//                         indicatorColor: kPrimaryColor,
//                         labelStyle: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                         tabs: const [
//                           Tab(text: "Confirmed"),
//                           Tab(text: "Pending"),
//                           Tab(text: "Rejected"),
//                           Tab(text: "Completed"),
//                         ],
//                       ),

//                       const SizedBox(height: 12),

//                       // Tab Views
//                       SizedBox(
//                         height: screenHeight * 0.52,
//                         child: TabBarView(
//                           children: [
//                             _buildFilteredTasks(
//                               taskProvider,
//                               status: "confirmed",
//                             ),
//                             _buildFilteredTasks(
//                               taskProvider,
//                               status: "pending",
//                             ),
//                             _buildFilteredTasks(
//                               taskProvider,
//                               status: "rejected",
//                             ),
//                             _buildFilteredTasks(
//                               taskProvider,
//                               status: "completed",
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'task_detail_screen.dart';
import '../helpers/backend.dart';
import 'MyProfileScreen.dart';
import '../helpers/coolors.dart';
import 'sp_user_payment.dart';
import '../providers/task_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/tasksWidget.dart';
import 'package:lottie/lottie.dart';
import 'notifications_page.dart';
import '../widgets/fourCardsTask.dart';

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

int toDo = 0;
int inProgress = 0;
int inReview = 0;
int completed = 0;

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

  // hold_pay
  static Future<void> holdPayment(int taskId, double holdAmount) async {
    final uri = Uri.parse("${Backend.baseUrl}/tasks/$taskId/hold_payment");
    final response = await http.patch(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"hold_amount": holdAmount}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to hold payment for task $taskId");
    }
  }
}

class MyTasksScreen extends StatefulWidget {
  final String role; // "user" or "provider"
  final int currentUserId;
  final Map<String, dynamic> currentUser;

  const MyTasksScreen({
    super.key,
    required this.role,
    required this.currentUserId,
    required this.currentUser,
  });

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen>
    with SingleTickerProviderStateMixin {
  late Map<String, dynamic> currentUser;
  @override
  void initState() {
    super.initState();

    // ✅ Use widget.currentUser directly
    currentUser = widget.currentUser;
    print("Profile Image URL: ${currentUser['profile_image']}");
    fetchTaskSummary();
    // Load tasks via Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadTasks(widget.currentUserId, role: widget.role);
    });
  }

  void _payNow(Task task) async {
    print("💡 _payNow called for Task ID: ${task.id}");

    // ✅ Step 0: Prevent payment if task is not accepted yet
    if (task.status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "⚠️ You cannot pay now. Task is not yet accepted by the provider.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return; // stop payment flow
    }

    // ✅ Step 1: Validate user and provider IDs
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

    // Step 2: Ask user to enter the amount dynamically
    double enteredAmount = task.amount; // default value
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Amount to Pay"),
        content: TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(hintText: task.amount.toStringAsFixed(2)),
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

    // Step 3: Show loading while creating payment
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
            onPaymentSuccess: () async {
              // 1️⃣ Refresh tasks silently
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).refreshTasks(widget.currentUserId, role: widget.role);

              // 2️⃣ Close payment WebView
              Navigator.pop(context);

              // 3️⃣ Go to the provider profile (whose task was paid)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyProfileScreen(
                    userData: {
                      'id': task.providerId,
                      'name': task.providerName,
                      'role': 'provider',
                    },
                    currentUserId: widget.currentUserId,
                    readOnly: true, // user viewing someone else's profile
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context); // close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Payment failed: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> fetchTaskSummary() async {
    try {
      final uri = Uri.parse(
        '${Backend.baseUrl}/tasks/summary?user_id=${widget.currentUserId}',
      ); // changed provider_id → user_id
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          toDo = data['totalTasks'] ?? 0; // Total tasks
          inProgress = data['inProgressTasks'] ?? 0; // In progress (confirmed)
          inReview = data['rejectedTasks'] ?? 0; // Rejected
          completed = data['completedTasks'] ?? 0; // Completed
        });
      } else {
        throw Exception('Failed to fetch task summary');
      }
    } catch (e) {
      print("Error fetching task summary: $e");
    }
  }



  Future<void> _updateTask(Task task, String newStatus) async {
  bool confirm = true;

  // 🔹 Confirmation dialog only for completion
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
                child: Text('Cancel', style: TextStyle(color: kCardColor)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Yes, Completed',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  if (!confirm) return;

  try {
    // 🔴 IMPORTANT FIX: PAYMENT CHECK BEFORE COMPLETION
    if (newStatus == "completed" &&
        (task.payment_status == null || task.payment_status != "paid")) {
      // Hold partial amount
      double holdAmount = task.amount * 0.5;
      await TasksApi.holdPayment(task.id, holdAmount);

      // Notify client
      NotificationsApi.sendNotification(
        userId: task.userId,
        title: "Payment Pending 💰",
        body:
            "Your task '${task.serviceTitle}' is completed. Please complete the payment to release funds.",
        senderId: task.providerId,
      );

      // Show message to provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "❌ Payment is not completed yet",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );

      return; // ⛔ STOP — do NOT update status
    }

    // ✅ Status update happens ONLY when allowed
    await TasksApi.updateTaskStatus(task.id, newStatus);

    String message = '';
    Color snackColor = kPrimaryColor;

    if (newStatus == "confirmed") {
      message = "✅ Task accepted";
      snackColor = Colors.green.shade700;

      NotificationsApi.sendNotification(
        userId: task.userId,
        title: "Task Accepted ✅",
        body:
            "Your task '${task.serviceTitle}' has been accepted by the provider",
        senderId: task.providerId,
      );
    }

    if (newStatus == "rejected") {
      message = "❌ Task rejected";
      snackColor = Colors.red.shade600;

      NotificationsApi.sendNotification(
        userId: task.userId,
        title: "Task Rejected ❌",
        body:
            "Your task '${task.serviceTitle}' has been rejected by the provider",
        senderId: task.providerId,
      );
    }

    if (newStatus == "completed") {
      message = "🎉 Task completed";

      NotificationsApi.sendNotification(
        userId: task.userId,
        title: "Task Completed 🎉",
        body:
            "Your task '${task.serviceTitle}' has been marked as completed",
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
      ),
    );

    Provider.of<TaskProvider>(
      context,
      listen: false,
    ).refreshTasks(widget.currentUserId, role: widget.role);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "❌ Failed to update task: $e",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }
}








  // --- Status Badge ---
  Widget _statusBadge(String status) {
    final Color badgeColor;
    switch (status) {
      case "confirmed":
        badgeColor = Color(0xFF40916C); // Soft green
        break;
      case "completed":
        badgeColor = Color(0xFF1E6091); // Soft blue
        break;
      case "rejected":
        badgeColor = Color(0xFFB02A37); // Soft red
        break;
      default:
        badgeColor = Color(0xFF9D6B53); // Soft brown/orange for pending
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15), // Light tint
        border: Border.all(color: badgeColor.withOpacity(0.8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isNew = task.status == 'pending' && widget.role == "provider";

    // --- Status-based background color (Soft & Calm) ---
    Color cardBgColor;
    switch (task.status) {
      case "confirmed": // In Progress
        cardBgColor = Color(0xFFD1E7DD); // Soft green
        break;
      case "completed":
        cardBgColor = Color(0xFFCCE5FF); // Light blue
        break;
      case "rejected":
        cardBgColor = Color(0xFFF8D7DA); // Soft pink
        break;
      default: // pending
        cardBgColor = Color(0xFFFFF3CD); // Soft yellow
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
                  color: Colors.black.withOpacity(0.05), // Soft shadow
                  offset: const Offset(0, 1),
                  blurRadius: 3,
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
                            color: Colors.black87, // Soft text
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
                    color: Colors.grey[700]!,
                  ),
                  const SizedBox(height: 4),

                  // User / Provider Info
                  _infoChip(
                    icon: widget.role == "user" ? Icons.handyman : Icons.person,
                    text: widget.role == "user"
                        ? task.providerName
                        : task.userName,
                    color: Colors.grey[800]!,
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
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Task Status Message
                  if (task.status != "completed")
                    _statusMessage(
                      "⚠️ This task is not completed yet",
                      Colors.grey[700]!,
                    ),
                  if (task.status == "completed" && task.completedAt != null)
                    _statusMessage(
                      "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
                      Color(0xFF22C55E),
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
  // --- Info Chip ---
  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Soft background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[800]), // Soft dark gray
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
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

  // --- Action Buttons ---
  Widget _buildActionButtons(Task task) {
    if (widget.role == "user") {
      if (task.payment_status != "paid") {
        return ElevatedButton(
          onPressed: () => _payNow(task),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[300], // Soft blue
            foregroundColor: Colors.white,
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
                backgroundColor: Colors.green[300], // Soft green
                foregroundColor: Colors.white,
              ),
              child: const Text("Accept"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _updateTask(task, "rejected"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300], // Soft red
                foregroundColor: Colors.white,
              ),
              child: const Text("Reject"),
            ),
          ],
        );
      } else if (task.status == "confirmed") {
        return ElevatedButton(
          onPressed: () => _updateTask(task, "completed"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[300], // Soft teal
            foregroundColor: Colors.white,
          ),
          child: const Text("Mark Completed"),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildFilteredTasks(
    TaskProvider taskProvider, {
    String? status,
    String? filterByDate,
  }) {
    List<Task> tasks = [
      ...taskProvider.pendingTasks,
      ...taskProvider.completedTasks,
    ];

    // Status filter
    if (status != null) {
      tasks = tasks.where((t) => t.status == status).toList();
    }

    // Date filter
    if (filterByDate != null) {
      DateTime now = DateTime.now();
      tasks = tasks.where((t) {
        if (filterByDate == "week") {
          return t.scheduledDate.isAfter(now.subtract(const Duration(days: 7)));
        } else if (filterByDate == "month") {
          return t.scheduledDate.isAfter(
            DateTime(now.year, now.month - 1, now.day),
          );
        } else if (filterByDate == "older") {
          return t.scheduledDate.isBefore(
            DateTime(now.year, now.month - 1, now.day),
          );
        }
        return true;
      }).toList();
    }

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/No History.json',
                width: 200,
                height: 200,
                repeat: true,
              ),
              const SizedBox(height: 12),
              Text(
                "No tasks found",
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor,

      // ---------------------- AppBar ----------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: navbarColor,

          title: Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile
                Builder(
                  builder: (_) {
                    String profileImagePath =
                        currentUser['profile_image'] ?? '';
                    String fullImageUrl = profileImagePath.startsWith("http")
                        ? profileImagePath
                        : "${Backend.baseUrl}/$profileImagePath";

                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: fullImageUrl.isNotEmpty
                          ? NetworkImage(fullImageUrl)
                          : null,
                      child: fullImageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              color: Colors.grey.shade600,
                              size: 24,
                            )
                          : null,
                    );
                  },
                ),

                const SizedBox(width: 14),

                // Username
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Hello,",
                      style: TextStyle(color: kTextHint, fontSize: 14),
                    ),
                    Text(
                      currentUser['username'] ?? 'Username',
                      style: const TextStyle(
                        color: navbarTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsPage(
                      userId: currentUser['id'],
                      role: widget.role,
                      tab: 'tasks', // 🔹 yaha 'tasks' ya 'messages' pass kar do
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.notifications_none,
                color: navbarTextColor,
                size: 28,
              ),
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: navbarTextColor, size: 28),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),

      // ---------------------- Body ----------------------
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Task Cards ---
                const SizedBox(height: 10),
                TaskCardsWidget(
                  toDo: toDo,
                  inProgress: inProgress,
                  inReview: inReview,
                  completed: completed,
                ),

                const SizedBox(height: 6),

                // const SizedBox(height: 3), // compact spacing
                // --- Clock & Day Box ---
                SizedBox(
                  height: screenHeight * 0.18,
                  child: const ClockAndDayBox(),
                ),

                const SizedBox(height: 10), // before Tabs
                // --- Tabs Section ---
                // --- Tabs Section ---
                DefaultTabController(
                  length: 4, // Only 4 tabs now
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TabBar(
                        isScrollable: true,
                        labelColor: kTextPrimary,
                        unselectedLabelColor: kTextSecondary,
                        indicatorColor: kPrimaryColor,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: const [
                          Tab(text: "Confirmed"),
                          Tab(text: "Pending"),
                          Tab(text: "Rejected"),
                          Tab(text: "Completed"),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tab Views
                      SizedBox(
                        height: screenHeight * 0.52,
                        child: TabBarView(
                          children: [
                            _buildFilteredTasks(
                              taskProvider,
                              status: "confirmed",
                            ),
                            _buildFilteredTasks(
                              taskProvider,
                              status: "pending",
                            ),
                            _buildFilteredTasks(
                              taskProvider,
                              status: "rejected",
                            ),
                            _buildFilteredTasks(
                              taskProvider,
                              status: "completed",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
