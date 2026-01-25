// import 'package:flutter/material.dart';

// class NotificationProvider extends ChangeNotifier {
//   int unseenCount = 0;
//   List<dynamic> notifications = [];
//  bool isLoading = true;
//   void addNotification(dynamic notif) {
//     notifications.insert(0, notif);
//     unseenCount += 1;
//     notifyListeners();
//   }

//   void markAllSeen() {
//     unseenCount = 0;
//     for (var notif in notifications) {
//       notif['is_seen'] = true;
//     }
//     notifyListeners();
//   }

//   void setNotifications(List<dynamic> notifs, int count) {
//     notifications = notifs;
//     unseenCount = count;
//     notifyListeners();
//   }

//   void deleteNotification(int id) {
//     notifications.removeWhere((n) => n['id'] == id);
//     notifyListeners();
//   }

//   void clearAll() {
//     notifications.clear();
//     unseenCount = 0;
//     notifyListeners();
//   }
//   void setLoading(bool value) {
//     isLoading = value;
//     notifyListeners();
//   }
// }
















import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  // 🔹 Global / combined notifications
  List<dynamic> notifications = [];
  bool isLoading = true;

  // 🔹 Separate lists & counts
  List<dynamic> messageNotifications = [];
  List<dynamic> taskNotifications = [];
  int unseenMessageCount = 0;
  int unseenTaskCount = 0;

  // ---------------- ADD NOTIFICATION ----------------
  void addNotification(dynamic notif) {
  notifications.insert(0, notif);

  if (notif['conversation_id'] != null) {
    messageNotifications.insert(0, notif);
    if (notif['is_seen'] != true) unseenMessageCount++;
  } 
  else if (notif['task_id'] != null || notif['title'] != null) {
    taskNotifications.insert(0, notif);
    if (notif['is_seen'] != true) unseenTaskCount++;
  }

  notifyListeners();
}


  // ---------------- MARK ALL SEEN ----------------
  void markAllSeen() {
    unseenMessageCount = 0;
    unseenTaskCount = 0;
    for (var notif in notifications) {
      notif['is_seen'] = true;
    }
    notifyListeners();
  }

  void markMessagesSeen() {
    unseenMessageCount = 0;
    for (var notif in messageNotifications) {
      notif['is_seen'] = true;
    }
    notifyListeners();
  }

  void markTasksSeen() {
    unseenTaskCount = 0;
    for (var notif in taskNotifications) {
      notif['is_seen'] = true;
    }
    notifyListeners();
  }

  // ---------------- SET NOTIFICATIONS ----------------
  void setNotifications(List<dynamic> notifs, int count) {
  notifications = notifs;

  messageNotifications.clear();
  taskNotifications.clear();
  unseenMessageCount = 0;
  unseenTaskCount = 0;

  for (var notif in notifs) {
    if (notif['conversation_id'] != null) {
      messageNotifications.add(notif);
      if (notif['is_seen'] != true) unseenMessageCount++;
    } 
    else if (notif['task_id'] != null || notif['title'] != null) {
      taskNotifications.add(notif);
      if (notif['is_seen'] != true) unseenTaskCount++;
    }
  }

  notifyListeners();
}

  // ---------------- DELETE ----------------
  void deleteNotification(int id) {
    notifications.removeWhere((n) => n['id'] == id);
    messageNotifications.removeWhere((n) => n['id'] == id);
    taskNotifications.removeWhere((n) => n['id'] == id);
    notifyListeners();
  }

  void clearAll() {
    notifications.clear();
    messageNotifications.clear();
    taskNotifications.clear();
    unseenMessageCount = 0;
    unseenTaskCount = 0;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Getter for compatibility with old code
  int get unseenCount => unseenMessageCount;
}
