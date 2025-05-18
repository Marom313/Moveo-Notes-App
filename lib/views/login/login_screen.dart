import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_vm.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: authVM.setEmail,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: authVM.setPassword,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  authVM.isLoading
                      ? null
                      : () async {
                        final user = await authVM.login();
                        if (user != null) {
                          context.go('/main');
                        }
                      },
              child:
                  authVM.isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Login"),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.go('/signup');
              },
              child: const Text("Don't have an account? Sign up"),
            ),
            if (authVM.errorMessage != null)
              Text(
                authVM.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
