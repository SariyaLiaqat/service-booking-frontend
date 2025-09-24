
// // ////////////////////////////////////
// // ///
// // ///

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'task_detail_screen.dart';
// import '../helpers/backend.dart';

// class Task {
//   final int id;
//   final int userId;
//   final int providerId;
//   final int serviceId;
//   final String status;
//   final DateTime scheduledDate;
//   final String notes;
//   final String serviceTitle;
//   final String userName;
//   final String providerName;
//   final DateTime? completedAt;

//   Task({
//     required this.id,
//     required this.userId,
//     required this.providerId,
//     required this.serviceId,
//     required this.status,
//     required this.scheduledDate,
//     required this.notes,
//     required this.serviceTitle,
//     required this.userName,
//     required this.providerName,
//     this.completedAt,
//   });

//   factory Task.fromJson(Map<String, dynamic> json) => Task(
//     id: json['id'],
//     userId: json['user_id'],
//     providerId: json['provider_id'],
//     serviceId: json['service_id'],
//     status: json['status'],
//     scheduledDate: DateTime.parse(json['scheduled_date']),
//     notes: json['notes'] ?? "",
//     serviceTitle: json['service_title'] ?? "Service",
//     userName: json['user_name'] ?? "User",
//     providerName: json['provider_name'] ?? "Provider",
//     completedAt: json['completed_at'] != null
//         ? DateTime.parse(json['completed_at'])
//         : null,
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
//               title: const Text('Complete Task'),
//               content: const Text(
//                 'Are you sure you have completed this task carefully?',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, false),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, true),
//                   child: const Text('Yes, Completed'),
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
//       if (newStatus == "confirmed") message = "✅ Task accepted";
//       if (newStatus == "rejected") message = "❌ Task rejected";
//       if (newStatus == "completed") message = "🎉 Task completed";

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));

//       await _loadTasks();
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("❌ Failed to update task: $e")));
//     }
//   }

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
//               serviceData: {
//                 'id': task.serviceId,
//                 'title': task.serviceTitle,
//                 'price': '', // optional
//                 'description': notesPreview,
//               },
//               readOnly: widget.role == "provider",
//             ),
//           ),
//         );
//       },
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         color: isNew ? Colors.blue.shade50: Color(0xFFD9E1F0),

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
//                   Text(
//                     task.serviceTitle,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Color(0xFF2A3A69)
//                     ),
//                   ),
//                   _statusBadge(task.status),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 "📅 Date: ${task.scheduledDate.toLocal().toString().split(' ')[0]}",style: TextStyle( color: Color(0xFF2A3A69)),
//               ),
//               Text(
//                 widget.role == "user"
//                     ? "👨‍🔧 Provider: ${task.providerName}"
//                     : "👤 User: ${task.userName}",style: TextStyle( color:Color(0xFF2A3A69)),
//               ),
//               if (notesPreview.isNotEmpty) Text("📝 Notes: $notesPreview",style: TextStyle( color: Color(0xFF2A3A69)),),
//               if (task.status != "completed")
//                 const Padding(
//                   padding: EdgeInsets.only(top: 6.0),
//                   child: Text(
//                     "⚠️ This task is not completed yet",
//                     style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF2A3A69)),
//                   ),
//                 ),
//               if (task.status == "completed" && task.completedAt != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 6.0),
//                   child: Text(
//                     "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
//                     style: const TextStyle(fontWeight: FontWeight.bold,color:Color(0xFF2A3A69)),
//                   ),
//                 ),
//               if (widget.role == "provider")
//                 if (task.status == "pending")
//                   Row(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => _updateTask(task, "confirmed"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                         ),
//                         child: const Text("Accept"),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: () => _updateTask(task, "rejected"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                         child: const Text("Reject"),
//                       ),
//                     ],
//                   )
//                 else if (task.status == "confirmed")
//                   ElevatedButton(
//                     onPressed: () => _updateTask(task, "completed",),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.white
//                     ),
//                     child: const Text("Mark Completed",),
//                   ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskList(List<Task> tasks) {
//     if (isLoading) return const Center(child: CircularProgressIndicator());
//     if (tasks.isEmpty) return const Center(child: Text("No tasks found"));

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
//       appBar: AppBar(
//         backgroundColor: Color(0xFF5C74B1),
//         title: const Text(
//           "📋 My Tasks",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             //  fontSize: 16,
//             color: Colors.white,
//           ),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(
//               child: Text(
//                 "⏳ Pending",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             Tab(
//               child: Text(
//                 "Completed",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
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









// ////////////////////////////////////
// ///
// ///

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'task_detail_screen.dart';
// import '../helpers/backend.dart';

// class Task {
//   final int id;
//   final int userId;
//   final int providerId;
//   final int serviceId;
//   final String status;
//   final DateTime scheduledDate;
//   final String notes;
//   final String serviceTitle;
//   final String userName;
//   final String providerName;
//   final DateTime? completedAt;

//   Task({
//     required this.id,
//     required this.userId,
//     required this.providerId,
//     required this.serviceId,
//     required this.status,
//     required this.scheduledDate,
//     required this.notes,
//     required this.serviceTitle,
//     required this.userName,
//     required this.providerName,
//     this.completedAt,
//   });

//   factory Task.fromJson(Map<String, dynamic> json) => Task(
//     id: json['id'],
//     userId: json['user_id'],
//     providerId: json['provider_id'],
//     serviceId: json['service_id'],
//     status: json['status'],
//     scheduledDate: DateTime.parse(json['scheduled_date']),
//     notes: json['notes'] ?? "",
//     serviceTitle: json['service_title'] ?? "Service",
//     userName: json['user_name'] ?? "User",
//     providerName: json['provider_name'] ?? "Provider",
//     completedAt: json['completed_at'] != null
//         ? DateTime.parse(json['completed_at'])
//         : null,
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
//               title: const Text('Complete Task'),
//               content: const Text(
//                 'Are you sure you have completed this task carefully?',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, false),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, true),
//                   child: const Text('Yes, Completed'),
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
//       if (newStatus == "confirmed") message = "✅ Task accepted";
//       if (newStatus == "rejected") message = "❌ Task rejected";
//       if (newStatus == "completed") message = "🎉 Task completed";

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));

//       await _loadTasks();
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("❌ Failed to update task: $e")));
//     }
//   }

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
//               serviceData: {
//                 'id': task.serviceId,
//                 'title': task.serviceTitle,
//                 'price': '', // optional
//                 'description': notesPreview,
//               },
//               readOnly: widget.role == "provider",
//             ),
//           ),
//         );
//       },


      
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         color: isNew ? Colors.blue.shade50: Color(0xFFD9E1F0),

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
//                   Text(
//                     task.serviceTitle,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Color(0xFF2A3A69)
//                     ),
//                   ),
//                   _statusBadge(task.status),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 "📅 Date: ${task.scheduledDate.toLocal().toString().split(' ')[0]}",style: TextStyle( color: Color(0xFF2A3A69)),
//               ),
//               Text(
//                 widget.role == "user"
//                     ? "👨‍🔧 Provider: ${task.providerName}"
//                     : "👤 User: ${task.userName}",style: TextStyle( color:Color(0xFF2A3A69)),
//               ),
//               if (notesPreview.isNotEmpty) Text("📝 Notes: $notesPreview",style: TextStyle( color: Color(0xFF2A3A69)),),
//               if (task.status != "completed")
//                 const Padding(
//                   padding: EdgeInsets.only(top: 6.0),
//                   child: Text(
//                     "⚠️ This task is not completed yet",
//                     style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF2A3A69)),
//                   ),
//                 ),
//               if (task.status == "completed" && task.completedAt != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 6.0),
//                   child: Text(
//                     "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
//                     style: const TextStyle(fontWeight: FontWeight.bold,color:Color(0xFF2A3A69)),
//                   ),
//                 ),
//               if (widget.role == "provider")
//                 if (task.status == "pending")
//                   Row(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => _updateTask(task, "confirmed"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                         ),
//                         child: const Text("Accept"),
//                       ),
//                       const SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: () => _updateTask(task, "rejected"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                         child: const Text("Reject"),
//                       ),
//                     ],
//                   )
//                 else if (task.status == "confirmed")
//                   ElevatedButton(
//                     onPressed: () => _updateTask(task, "completed",),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.white
//                     ),
//                     child: const Text("Mark Completed",),
//                   ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskList(List<Task> tasks) {
//     if (isLoading) return const Center(child: CircularProgressIndicator());
//     if (tasks.isEmpty) return const Center(child: Text("No tasks found"));

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
//       appBar: AppBar(
//         backgroundColor: Color(0xFF5C74B1),
//         title: const Text(
//           "📋 My Tasks",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             //  fontSize: 16,
//             color: Colors.white,
//           ),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(
//               child: Text(
//                 "⏳ Pending",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             Tab(
//               child: Text(
//                 "Completed",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
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


//////////////////
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'task_detail_screen.dart';
import '../helpers/backend.dart';

class Task {
  final int id;
  final int userId;
  final int providerId;
  final int serviceId;
  final String status;
  final DateTime scheduledDate;
  final String notes;
  final String serviceTitle;
  final String userName;
  final String providerName;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.scheduledDate,
    required this.notes,
    required this.serviceTitle,
    required this.userName,
    required this.providerName,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        userId: json['user_id'],
        providerId: json['provider_id'],
        serviceId: json['service_id'],
        status: json['status'],
        scheduledDate: DateTime.parse(json['scheduled_date']),
        notes: json['notes'] ?? "",
        serviceTitle: json['service_title'] ?? "Service",
        userName: json['user_name'] ?? "User",
        providerName: json['provider_name'] ?? "Provider",
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'])
            : null,
      );
}

class TasksApi {
  static Future<List<Task>> fetchTasks({int? userId, int? providerId}) async {
    final Map<String, String> queryParams = {};
    if (userId != null) queryParams['user_id'] = userId.toString();
    if (providerId != null) queryParams['provider_id'] = providerId.toString();

    final uri = Uri.parse("${Backend.baseUrl}/tasks")
        .replace(queryParameters: queryParams);

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
        pendingTasks = allTasks
            .where((t) => t.status != "completed")
            .toList()
          ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
        completedTasks = allTasks
            .where((t) => t.status == "completed")
            .toList()
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
                  title: const Text('Complete Task'),
                  content: const Text(
                    'Are you sure you have completed this task carefully?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Yes, Completed'),
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
      if (newStatus == "confirmed") message = "✅ Task accepted";
      if (newStatus == "rejected") message = "❌ Task rejected";
      if (newStatus == "completed") message = "🎉 Task completed";

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      await _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to update task: $e")));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.2),
        border: Border.all(color: _statusColor(status)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.bold,
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
              // ✅ Provide taskData for provider
              taskData: widget.role == "provider"
                  ? {
                      'id': task.id,
                      'notes': task.notes,
                      'scheduled_date': task.scheduledDate.toIso8601String(),
                      'title': task.serviceTitle,
                      'service_title': task.serviceTitle,
                      'price': '',
                      'description': task.notes,
                      'attachments': [], // add attachments if any
                    }
                  : null,
              // ✅ Provide serviceData for user
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
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isNew ? Colors.blue.shade50 : const Color(0xFFD9E1F0),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        fontSize: 16,
                        color: Color(0xFF2A3A69)),
                  ),
                  _statusBadge(task.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "📅 Date: ${task.scheduledDate.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(color: Color(0xFF2A3A69)),
              ),
              Text(
                widget.role == "user"
                    ? "👨‍🔧 Provider: ${task.providerName}"
                    : "👤 User: ${task.userName}",
                style: const TextStyle(color: Color(0xFF2A3A69)),
              ),
              if (notesPreview.isNotEmpty)
                Text(
                  "📝 Notes: $notesPreview",
                  style: const TextStyle(color: Color(0xFF2A3A69)),
                ),
              if (task.status != "completed")
                const Padding(
                  padding: EdgeInsets.only(top: 6.0),
                  child: Text(
                    "⚠️ This task is not completed yet",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
                  ),
                ),
              if (task.status == "completed" && task.completedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    "✅ Completed on: ${task.completedAt!.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF2A3A69)),
                  ),
                ),
              if (widget.role == "provider")
                if (task.status == "pending")
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _updateTask(task, "confirmed"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text("Accept"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _updateTask(task, "rejected"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Reject"),
                      ),
                    ],
                  )
                else if (task.status == "confirmed")
                  ElevatedButton(
                    onPressed: () => _updateTask(
                      task,
                      "completed",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A3A69),
                      foregroundColor: Colors.white,
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
    if (tasks.isEmpty) return const Center(child: Text("No tasks found"));

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
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C74B1),
        title: const Text(
          "📋 My Tasks",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              child: Text(
                "⏳ Pending",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Completed",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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
