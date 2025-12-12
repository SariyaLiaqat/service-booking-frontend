import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  int unseenCount = 0;
  List<dynamic> notifications = [];
 bool isLoading = true;
  void addNotification(dynamic notif) {
    notifications.insert(0, notif);
    unseenCount += 1;
    notifyListeners();
  }

  void markAllSeen() {
    unseenCount = 0;
    for (var notif in notifications) {
      notif['is_seen'] = true;
    }
    notifyListeners();
  }

  void setNotifications(List<dynamic> notifs, int count) {
    notifications = notifs;
    unseenCount = count;
    notifyListeners();
  }

  void deleteNotification(int id) {
    notifications.removeWhere((n) => n['id'] == id);
    notifyListeners();
  }

  void clearAll() {
    notifications.clear();
    unseenCount = 0;
    notifyListeners();
  }
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
