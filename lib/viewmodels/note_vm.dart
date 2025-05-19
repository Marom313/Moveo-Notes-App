import 'package:assignment_app/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import 'auth_vm.dart';

class NoteViewModel extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> loadNotesWithContext(BuildContext context) async {
    final userId =
        Provider.of<AuthViewModel>(context, listen: false).currentUser?.uid;
    if (userId == null) return;

    _notes = await IsarService.getNotesByUser(userId);
    notifyListeners();
  }

  Future<void> loadNotesForUser(String userId) async {
    _notes = await IsarService.getNotesByUser(userId);
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await IsarService.addNote(note);
    await loadNotesForUser(note.userId);
  }

  Future<void> updateNote(Note note) async {
    await IsarService.editNote(note);
    await loadNotesForUser(note.userId);
  }

  Future<void> deleteNote(Note note) async {
    await IsarService.deleteNote(note);
    await loadNotesForUser(note.userId);
  }

  Future<void> clearAllNotes() async {
    await IsarService.cleanDb();
  }
}
