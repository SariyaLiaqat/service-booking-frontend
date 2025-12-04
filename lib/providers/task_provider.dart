import 'package:flutter/material.dart';
import '../screens/my_tasks_screen.dart'; // only for Task & TasksApi

class TaskProvider with ChangeNotifier {
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];
  bool _isLoading = false;

  List<Task> get pendingTasks => _pendingTasks;
  List<Task> get completedTasks => _completedTasks;
  bool get isLoading => _isLoading;

  // Load tasks from API
  Future<void> loadTasks(int userId, {String role = "provider"}) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Task> tasks;
      if (role == "provider") {
        tasks = await TasksApi.fetchTasks(providerId: userId);
      } else {
        tasks = await TasksApi.fetchTasks(userId: userId);
      }

      _pendingTasks = tasks.where((t) => t.status != "completed").toList();
      _completedTasks = tasks.where((t) => t.status == "completed").toList();
    } catch (e) {
      // Optionally handle error
      _pendingTasks = [];
      _completedTasks = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh tasks
  Future<void> refreshTasks(int userId, {String role = "provider"}) async {
    await loadTasks(userId, role: role);
  }
}
