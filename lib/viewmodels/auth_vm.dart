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

  Future<User?> login() async {
    try {
      isLoading = true;
      notifyListeners();
      final user = await _authService.login(email, password);
      errorMessage = null;
      currentUser = user;
      return currentUser;
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
      if (user != null) {
        final fullName = '$firstName';

        await user.updateDisplayName(fullName);
        await user.reload();
        currentUser = FirebaseAuth.instance.currentUser;
      }
      errorMessage = null;
      currentUser = user;
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

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      print('sadsasda');
    } finally {
      currentUser = null;
      notifyListeners();
    }
  }

  void setEmail(String val) {
    email = val;
    notifyListeners();
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
