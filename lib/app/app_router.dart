import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../views/login/login_screen.dart';
import '../views/signup/signup_screen.dart';
import '../views/main/main_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isGoingToLoginOrSignup =
          state.fullPath == '/login' || state.fullPath == '/signup';

      if (user == null && !isGoingToLoginOrSignup) {
        return '/login';
      }

      if (user != null && isGoingToLoginOrSignup) {
        return '/main';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/',
        builder:
            (context, state) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
      ),
    ],
  );
}
