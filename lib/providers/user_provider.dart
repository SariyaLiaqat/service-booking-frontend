import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _userId;
  String? _role;

  int? get userId => _userId;
  String? get role => _role;

  void setUser({required int userId, required String role}) {
    _userId = userId;
    _role = role;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _role = null;
    notifyListeners();
  }
}
