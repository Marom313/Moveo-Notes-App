import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String email = '';
  String password = '';
  String? errorMessage;
  bool isLoading = false;

  Future<User?> login() async {
    try {
      isLoading = true;
      notifyListeners();
      final user = await _authService.login(email, password);
      errorMessage = null;
      return user;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<User?> signup(String confirmPassword) async {
    if (password != confirmPassword) {
      errorMessage = "Passwords do not match.";
      notifyListeners();
      return null;
    }

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      errorMessage = "All fields are required.";
      notifyListeners();
      return null;
    }

    try {
      isLoading = true;
      notifyListeners();

      final user = await _authService.signup(email.trim(), password);
      errorMessage = null;
      return user;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = "Unexpected error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return null;
  }

  void setEmail(String val) {
    email = val;
    notifyListeners();
  }

  void setPassword(String val) {
    password = val;
    notifyListeners();
  }
}
