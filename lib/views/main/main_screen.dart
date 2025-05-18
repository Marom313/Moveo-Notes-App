import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Moveo Notes App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Welcome to the Main Screen!",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: width * 0.03, bottom: height * 0.02),
        child: FloatingActionButton(
          onPressed: () {
            // Later: navigate to "add note" or "map" page
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
