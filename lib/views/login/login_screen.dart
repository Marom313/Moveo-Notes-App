import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_vm.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    bool _obscurePassword = true;

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: authVM.setEmail,
            ),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  onChanged: authVM.setPassword,
                );
              },
            ),
            SizedBox(height: height * 0.08),
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
            SizedBox(height: height * 0.02),
            TextButton(
              onPressed: () {
                context.push('/signup');
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
