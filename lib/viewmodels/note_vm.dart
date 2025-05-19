import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NoteViewModel extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList('notes') ?? [];
      _notes =
          notesJson
              .map((noteStr) => Note.fromJson(json.decode(noteStr)))
              .toList();
    } catch (e) {
      _notes = []; // fallback if corrupted data
    }
    notifyListeners();
    debugPrint(
      "✅ Loaded notes: ${_notes.map((n) => n.toJson()).toList()}",
    ); //////??????
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _notes.map((note) => json.encode(note.toJson())).toList();
    await prefs.setStringList('notes', notesJson);
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _saveToPrefs();
    notifyListeners();
    debugPrint(
      "✅ New note created: ${this._notes}",
    ); //Priniting notes list after creating new one
  }

  Future<void> updateNote(int index, Note note) async {
    _notes[index] = note;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteNote(int index) async {
    _notes.removeAt(index);
    await _saveToPrefs();
    notifyListeners();
  }
}
