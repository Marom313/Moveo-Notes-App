import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? currentUser;
  String email = '';
  String password = '';
  String firstName = '';
  String lastName = '';
  String? errorMessage;
  bool isLoading = false;

  User? checkCurrentUser() {
    currentUser = _authService.currentUser;
    return currentUser;
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<User?> login() async {
    try {
      _setLoading(true);
      notifyListeners();
      final user = await _authService.login(email, password);
      errorMessage = null;
      currentUser = user;
      return currentUser;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } finally {
      _setLoading(false);
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
      _setLoading(true);
      notifyListeners();

      final user = await _authService.signup(email.trim(), password);
      if (user != null) {
        final fullName = firstName;

        await user.updateDisplayName(fullName);
        await user.reload();
        currentUser = FirebaseAuth.instance.currentUser;
      }
      errorMessage = null;
      return currentUser;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = "Unexpected error: $e";
    } finally {
      _setLoading(false);
      notifyListeners();
    }

    return null;
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('$e');
    } finally {
      currentUser = null;
      notifyListeners();
    }
  }

  void setEmail(String val) {
    email = val;
    // notifyListeners();
  }

  void setPassword(String val) {
    password = val;
    notifyListeners();
  }

  void setFirstName(String val) {
    firstName = val;

    notifyListeners();
  }

  void setLastName(String val) {
    lastName = val;
    notifyListeners();
  }
}
