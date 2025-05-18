import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/auth_vm.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: authVM.setEmail,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter an email'
                            : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: authVM.setPassword,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter a password'
                            : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your password';
                  }
                  if (value != authVM.password) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    authVM.isLoading
                        ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            final user = await authVM.signup(
                              _confirmPasswordController.text,
                            );
                            if (user != null) {
                              context.go('/login');
                            } else {
                              debugPrint(
                                " Signup failed: ${authVM.errorMessage}",
                              );
                            }
                          }
                        },
                child:
                    authVM.isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Sign Up"),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text("Already have an account? Log in"),
              ),
              if (authVM.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    authVM.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
