import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

class IsarService {
  static late Isar isar;
  static bool _isDbOpened = false;

  static Future<void> openDB() async {
    if (_isDbOpened) {
      return;
    }

    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open(
        [NoteSchema],
        inspector: kDebugMode,
        directory: dir.path,
      );
      _isDbOpened = true;
    } else {
      isar = Isar.getInstance()!;
      _isDbOpened = true;
    }
  }

  static Future<void> cleanDb() async {
    await isar.writeTxn(() => isar.clear());
  }

  static Future<void> addNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }

  static Future<void> deleteNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.delete(note.id);
    });
  }

  static Future<void> editNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }

  static Future<List<Note>> fetchNotes() async {
    return await isar.notes.where().findAll();
  }

  static Stream<List<Note>> watchAllNotes() {
    return isar.notes.where().watch(fireImmediately: true);
  }

  static Future<List<Note>> getNotesByUser(String userId) async {
    return await isar.notes.filter().userIdEqualTo(userId).findAll();
  }
}
