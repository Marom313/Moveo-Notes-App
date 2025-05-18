import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NoteViewModel extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notes') ?? [];

    _notes =
        notesJson
            .map((noteString) => Note.fromJson(json.decode(noteString)))
            .toList();

    notifyListeners();
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _notes.map((note) => json.encode(note.toJson())).toList();
    await prefs.setStringList('notes', notesJson);
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(int index, Note note) async {
    _notes[index] = note;
    await saveNotes();
    notifyListeners();
  }

  Future<void> deleteNote(int index) async {
    _notes.removeAt(index);
    await saveNotes();
    notifyListeners();
  }
}
