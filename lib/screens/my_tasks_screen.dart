// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'task_detail_screen.dart';
// import '../helpers/backend.dart';
// import '../helpers/colors.dart';
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
//   });

//  factory Task.fromJson(Map<String, dynamic> json) => Task(
//       id: json['id'],
//       userId: json['user_id'],
//       providerId: json['provider_id'],
//       serviceId: json['service_id'],
//       status: json['status'],
//       scheduledDate: DateTime.parse(json['scheduled_date']),
//       address: json['address'], // new
//       latitude: json['latitude'] != null
//           ? double.tryParse(json['latitude'].toString())
//           : null, // new
//       longitude: json['longitude'] != null
//           ? double.tryParse(json['longitude'].toString())
//           : null, // new
//       notes: json['notes'] ?? "",
//       serviceTitle: json['service_title'] ?? "Service",
//       userName: json['user_name'] ?? "User",
//       providerName: json['provider_name'] ?? "Provider",
//       attachmentDetails: json['attachment_details'],
//       completedAt: json['completed_at'] != null
//           ? DateTime.parse(json['completed_at'])
//           : null,
//       attachments: json['attachments'] != null
//           ? List<Map<String, dynamic>>.from(
//               (json['attachments'] as List).map(
//                 (a) => Map<String, dynamic>.from(a),
//               ),
//             )
//           : [],
//     );

// }

// class TasksApi {
//   static Future<List<Task>> fetchTasks({int? userId, int? providerId}) async {
//     final Map<String, String> queryParams = {};
//     if (userId != null) queryParams['user_id'] = userId.toString();
//     if (providerId != null) queryParams['provider_id'] = providerId.toString();

//     final uri = Uri.parse("${Backend.baseUrl}/tasks")
//         .replace(queryParameters: queryParams);

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
//         pendingTasks = allTasks
//             .where((t) => t.status != "completed")
//             .toList()
//           ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
//         completedTasks = allTasks
//             .where((t) => t.status == "completed")
//             .toList()
//           ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("❌ Failed to load tasks: $e")));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

// Future<void> _updateTask(Task task, String newStatus) async {
//   bool confirm = true;

//   if (newStatus == "completed") {
//     confirm = await showDialog(
//           context: context,
//           builder: (ctx) => AlertDialog(
//             backgroundColor: AppColors.backgroundWhite,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title: Text(
//               'Complete Task',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//                 color: AppColors.darkBlue,
//               ),
//             ),
//             content: Text(
//               'Are you sure you have completed this task carefully?',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: AppColors.textDark,
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx, false),
//                 style: TextButton.styleFrom(
//                   backgroundColor: AppColors.lightGrey.withOpacity(0.3),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(
//                     color: AppColors.textDark,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx, true),
//                 style: TextButton.styleFrom(
//                   backgroundColor: AppColors.darkBlue,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: const Text(
//                   'Yes, Completed',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   if (!confirm) return;

//   try {

//     await TasksApi.updateTaskStatus(task.id, newStatus);

//     String message = '';
//     Color snackColor = AppColors.darkBlue;

//    if (newStatus == "confirmed") {
//   message = "✅ Task accepted";
//   snackColor = Colors.green.shade700;

//   // 🔹 Send notification to user
//   NotificationsApi.sendNotification(
//     userId: task.userId,
//     title: "Task Accepted ✅",
//     body: "Your task '${task.serviceTitle}' has been accepted✅ by the provider",
//     senderId: task.providerId,
//   );
// }

//    if (newStatus == "rejected") {
//   message = "❌ Task rejected";
//   snackColor = Colors.red.shade600;

//   // 🔹 Send notification to user
//   NotificationsApi.sendNotification(
//     userId: task.userId,
//     title: "Task Rejected ❌",
//     body: "Your task '${task.serviceTitle}' has been rejected❌ by the provider",
//     senderId: task.providerId,
//   );
// }

//     if (newStatus == "completed") {
//   message = "🎉 Task completed";
//   snackColor = AppColors.darkBlue;

//   // 🔹 Send notification to user
//   NotificationsApi.sendNotification(
//     userId: task.userId,
//     title: "Task Completed 🎉",
//     body: "Your task '${task.serviceTitle}' has been marked as completed🎉 by the provider",
//     senderId: task.providerId,
//   );
// }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: snackColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         duration: const Duration(seconds: 2),
//       ),
//     );

//     await _loadTasks();
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           "❌ Failed to update task: $e",
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.red.shade600,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
// }

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'confirmed':
//         return Colors.green;
//       case 'completed':
//         return Colors.blue;
//       case 'rejected':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _statusBadge(String status) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _statusColor(status).withOpacity(0.2),
//         border: Border.all(color: _statusColor(status)),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           color: _statusColor(status),
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskCard(Task task) {
//     final isNew = task.status == 'pending' && widget.role == "provider";

//     String notesPreview = task.notes;
//     if (notesPreview.length > 50) {
//       notesPreview = notesPreview.substring(0, 50) + "...";
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
// 'latitude': task.latitude,
// 'longitude': task.longitude,

//                     }
//                   : null,
//               serviceData: widget.role == "user"
//                   ? {
//                       'id': task.serviceId,
//                       'title': task.serviceTitle,
//                       'price': '',
//                       'description': notesPreview,
//                     }
//                   : null,
//             ),
//           ),
//         );
//       },
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         color: isNew ? const Color(0xFFE6F0FA) : AppColors.backgroundWhite,
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(14.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                  Text(
//   task.serviceTitle,
//   style: TextStyle(
//     fontWeight: FontWeight.bold,
//     fontSize: 18,
//     color: AppColors.textDark,
//     shadows: [
//       Shadow(
//         color: Colors.black.withOpacity(0.1),
//         offset: const Offset(0, 1),
//         blurRadius: 2,
//       ),
//     ],
//   ),
// ),

//                   _statusBadge(task.status),
//                 ],
//               ),
//               const SizedBox(height: 6),
//              Container(
//   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//   decoration: BoxDecoration(
//     color: AppColors.lightTeal.withOpacity(0.2),
//     borderRadius: BorderRadius.circular(8),
//   ),
//   child: Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       const Icon(Icons.calendar_today, size: 14, color: AppColors.darkBlue),
//       const SizedBox(width: 4),
//       Text(
//         task.scheduledDate.toLocal().toString().split(' ')[0],
//         style: const TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 14,
//           color: AppColors.darkBlue,
//         ),
//       ),
//     ],
//   ),
// ),

//              Container(
//   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//   decoration: BoxDecoration(
//     color: AppColors.lightGrey.withOpacity(0.2),
//     borderRadius: BorderRadius.circular(8),
//   ),
//   child: Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Icon(
//         widget.role == "user" ? Icons.handyman : Icons.person,
//         size: 14,
//         color: AppColors.darkBlue,
//       ),
//       const SizedBox(width: 4),
//       Text(
//         widget.role == "user"
//             ? task.providerName
//             : task.userName,
//         style: const TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 14,
//           color: AppColors.darkBlue,
//         ),
//       ),
//     ],
//   ),
// ),

//              if (notesPreview.isNotEmpty)
//   Padding(
//     padding: const EdgeInsets.only(top: 4.0),
//     child: Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: AppColors.lightGrey.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         "📝 Notes: $notesPreview",
//         style: TextStyle(
//           color: AppColors.textDark,
//           fontSize: 13,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//     ),
//   ),

//              if (task.status != "completed")
//   Padding(
//     padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
//     child: Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: AppColors.lightTeal.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         "⚠️ This task is not completed yet",
//         style: TextStyle(
//           fontWeight: FontWeight.w600,
//           color: AppColors.textDark,
//           fontSize: 13,
//         ),
//       ),
//     ),
//   ),

//              if (task.status == "completed" && task.completedAt != null)
//   Padding(
//     padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
//     child: Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: AppColors.lightTeal.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: AppColors.darkBlue,
//           fontSize: 13,
//         ),
//       ),
//     ),
//   ),

//               if (widget.role == "provider")
//                 if (task.status == "pending")
//                   Row(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => _updateTask(task, "confirmed"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                         ),
//                         child: const Text("Accept",style: TextStyle(color: AppColors.textLight),),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: () => _updateTask(task, "rejected"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                         child: const Text("Reject",style: TextStyle(color: AppColors.textLight),),
//                       ),
//                     ],
//                   )
//                 else if (task.status == "confirmed")
//                   ElevatedButton(
//                     onPressed: () => _updateTask(task, "completed"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.darkBlue,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text("Mark Completed"),
//                   ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskList(List<Task> tasks) {
//     if (isLoading) return const Center(child: CircularProgressIndicator());
//     if (tasks.isEmpty) return const Center(child: Text("No tasks found",style: TextStyle(color: AppColors.darkBlue,),));

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
//    appBar: AppBar(
//   title: Text(
//     "📋 My Tasks",
//     style: const TextStyle(
//       fontWeight: FontWeight.bold,
//       fontSize: 20,
//       color: Colors.white,
//     ),
//   ),
//   backgroundColor: AppColors.darkBlue, // your premium blue
//   elevation: 4,
//   centerTitle: true,
//   shape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.vertical(
//       bottom: Radius.circular(16),
//     ),
//   ),
//   bottom: PreferredSize(
//     preferredSize: const Size.fromHeight(50),
//     child: Align(
//       alignment: Alignment.center,
//       child: TabBar(
//         controller: _tabController,
//         indicatorSize: TabBarIndicatorSize.label,
//         indicatorColor: AppColors.textLight, // underline highlight
//         labelColor: AppColors.lightGrey,
//         unselectedLabelColor: const Color.fromARGB(136, 213, 211, 211),
//         labelStyle: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 16,
//         ),
//         unselectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 16,
//         ),
//         tabs: const [
//           Tab(text: "⏳ Pending"),
//           Tab(text: "✅ Completed"),
//         ],
//       ),
//     ),
//   ),
// ),

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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'task_detail_screen.dart';
import '../helpers/backend.dart';
import '../helpers/colors.dart';
import '../helpers/my_colors.dart';

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
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    userId: json['user_id'],
    providerId: json['provider_id'],
    serviceId: json['service_id'],
    status: json['status'],
    scheduledDate: DateTime.parse(json['scheduled_date']),
    address: json['address'], // new
    latitude: json['latitude'] != null
        ? double.tryParse(json['latitude'].toString())
        : null, // new
    longitude: json['longitude'] != null
        ? double.tryParse(json['longitude'].toString())
        : null, // new
    notes: json['notes'] ?? "",
    serviceTitle: json['service_title'] ?? "Service",
    userName: json['user_name'] ?? "User",
    providerName: json['provider_name'] ?? "Provider",
    attachmentDetails: json['attachment_details'],
    completedAt: json['completed_at'] != null
        ? DateTime.parse(json['completed_at'])
        : null,
    attachments: json['attachments'] != null
        ? List<Map<String, dynamic>>.from(
            (json['attachments'] as List).map(
              (a) => Map<String, dynamic>.from(a),
            ),
          )
        : [],
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
  List<Task> pendingTasks = [];
  List<Task> completedTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => isLoading = true);
    try {
      List<Task> allTasks;
      if (widget.role == "user") {
        allTasks = await TasksApi.fetchTasks(userId: widget.currentUserId);
      } else {
        allTasks = await TasksApi.fetchTasks(providerId: widget.currentUserId);
      }

      setState(() {
        pendingTasks = allTasks.where((t) => t.status != "completed").toList()
          ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
        completedTasks = allTasks.where((t) => t.status == "completed").toList()
          ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to load tasks: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateTask(Task task, String newStatus) async {
    bool confirm = true;

    if (newStatus == "completed") {
      confirm =
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.backgroundWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Complete Task',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.darkBlue,
                ),
              ),
              content: Text(
                'Are you sure you have completed this task carefully?',
                style: TextStyle(fontSize: 16, color: AppColors.textDark),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Yes, Completed',
                    style: TextStyle(
                      color: Colors.white,
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
      Color snackColor = AppColors.darkBlue;

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
        snackColor = AppColors.darkBlue;

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

      await _loadTasks();
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
        return const Color(0xFFFACC15);
      case 'confirmed':
        return const Color(0xFF4F46E5);
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

    String notesPreview = task.notes;
    if (notesPreview.length > 50) {
      notesPreview = notesPreview.substring(0, 50) + "...";
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
                      'description': notesPreview,
                    }
                  : null,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isNew ? MyColors.divider : MyColors.divider,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNew ? MyColors.primary : MyColors.surface,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task.serviceTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 0.4,
                      shadows: [
                        Shadow(
                          color: MyColors.primary,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),

                  _statusBadge(task.status),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A40),

                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: MyColors.secondary, // gold text
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.scheduledDate.toLocal().toString().split(' ')[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: MyColors.secondary, // gold text
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A40),

                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.role == "user" ? Icons.handyman : Icons.person,
                      size: 14,
                      color: MyColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.role == "user" ? task.providerName : task.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: MyColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              if (notesPreview.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B2E),

                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "📝 Notes: $notesPreview",
                      style: TextStyle(
                        color: Color(0xFFA1A1A1),

                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

              if (task.status != "completed")
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A40),

                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "⚠️ This task is not completed yet",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: MyColors.secondary,

                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              if (task.status == "completed" && task.completedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),

                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B2E),

                      borderRadius: BorderRadius.circular(6),
                    ),

                    child: Text(
                      "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22C55E),

                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              if (widget.role == "provider")
                if (task.status == "pending")
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateTask(task, "confirmed"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF22C55E),
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(color: MyColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateTask(task, "rejected"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFEF4444),
                        ),
                        child: const Text(
                          "Reject",
                          style: TextStyle(color: MyColors.textPrimary),
                        ),
                      ),
                    ],
                  )
                else if (task.status == "confirmed")
                  ElevatedButton(
                    onPressed: () => _updateTask(task, "completed"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4F46E5),
                      foregroundColor: MyColors.textPrimary,
                    ),
                    child: const Text("Mark Completed"),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (tasks.isEmpty)
      return const Center(
        child: Text(
          "No tasks found",
          style: TextStyle(color: MyColors.textSecondary),
        ),
      );

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        title: const Text(
          "📋 My Tasks",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Align(
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFFFACC15), // soft gold underline
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Color(0xFFA1A1A1),
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
          _buildTaskList(pendingTasks),
          _buildTaskList(completedTasks),
        ],
      ),
    );
  }
}
