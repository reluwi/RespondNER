import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Simulated users for demo purposes
  final Map<String, User> _users = {
    'responder@test.com': User(
      id: '1',
      name: 'Clyde Lopez',
      email: 'responder@test.com',
      role: UserRole.responder,
    ),
    'admin@test.com': User(
      id: '2',
      name: 'Admin User',
      email: 'admin@test.com',
      role: UserRole.admin,
    ),
  };

  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (_users.containsKey(email)) {
      _currentUser = _users[email];
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isResponder => _currentUser?.isResponder ?? false;
}