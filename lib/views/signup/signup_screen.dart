import 'package:assignment_app/utils/string_ext.dart';
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
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final devicePadding = MediaQuery.of(context).viewInsets;
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            padding: devicePadding,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'First Name'),
                    onChanged: authVM.setFirstName,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter First Name'
                                : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    onChanged: authVM.setLastName,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter Last Name'
                                : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: authVM.setEmail,
                    validator:
                        (value) =>
                            value?.isValidEmail() == true
                                ? null
                                : 'Enter a valid email',
                  ),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter fieldState) {
                      return Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  fieldState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscure,
                            onChanged: authVM.setPassword,
                            validator:
                                (value) =>
                                    value?.isPassValid() == true
                                        ? 'Min 6 characters, mixed case, a number & a special'
                                        : null,
                          ),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                            ),
                            obscureText: _obscure,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm your password';
                              }
                              if (value != authVM.password) {
                                return 'Password not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      );
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
                                  context.go('/main');
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
        ),
      ),
    );
  }
}
