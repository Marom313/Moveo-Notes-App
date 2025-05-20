import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/note_model.dart';
import '../viewmodels/auth_vm.dart';

class MainTab extends StatelessWidget {
  const MainTab({super.key, required this.notes});

  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final user = Provider.of<AuthViewModel>(context).currentUser;
    final firstName = user?.displayName ?? '👤';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Welcome $firstName !',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (notes.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: height * 0.2),
                Center(
                  child: Text(
                    'No notes yet  👀,\n '
                    'press the plus sign and make a new one !\n ',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textColor, fontSize: 20),
                  ),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                itemCount: notes.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 2,
                ),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return GestureDetector(
                    onTap: () {
                      context.go(
                        '/note_edit',
                        extra: {'note': note, 'index': index},
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              note.body ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
