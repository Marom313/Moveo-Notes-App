import 'package:assignment_app/views/splash_screen.dart';
import 'package:go_router/go_router.dart';
import '../models/note_model.dart';
import '../views/login/login_screen.dart';
import '../views/signup/signup_screen.dart';
import '../views/main/main_screen.dart';
import '../views/note/note_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/note_edit',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final note = extras?['note'] as Note?;
          final index = extras?['index'] as int?;

          return NoteScreen(note: note, noteIndex: index);
        },
      ),
    ],
  );
}
