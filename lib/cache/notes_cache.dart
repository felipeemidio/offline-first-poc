import 'dart:convert';

import 'package:offline_first_poc/models/note.dart';
import 'package:offline_first_poc/services/local_storage_service.dart';

class NotesCache {
  static List<Note> _localNotes = [];
  static bool _isLoaded = false;
  static const String kNotesKey = 'notes';
  final LocalStorageService _localStorageService;
  const NotesCache(this._localStorageService);

  Future<void> _load() async {
    if (_isLoaded) {
      return;
    }

    final localNotesJson = await _localStorageService.find(kNotesKey);
    final localNotesObj = jsonDecode(localNotesJson ?? '[]') as List;
    _localNotes = localNotesObj.map((e) => Note.fromMap(e)).toList();
    _isLoaded = true;
  }

  Future<void> _save() async {
    final localNotesObj = _localNotes.map((e) => e.toMap()).toList();
    await _localStorageService.save(kNotesKey, jsonEncode(localNotesObj));
  }

  Future<List<Note>> getNotes() async {
    await _load();

    return _localNotes;
  }

  Future<void> saveNote(Note note) async {
    await _load();
    final localNote = await getById(note.id);
    if (localNote == null) {
      _localNotes.add(note);
    }
    await _save();
  }

  Future<void> saveNotes(List<Note> notes) async {
    await _load();
    _localNotes = notes;
    await _save();
  }

  Future<Note?> getById(String id) async {
    await _load();
    try {
      final note = _localNotes.firstWhere((e) => e.id == id);
      return note;
    } catch (e) {
      return null;
    }
  }

  Future<void> editNote(Note note) async {
    await _load();
    final noteIndex = _localNotes.indexWhere((e) => note.id == e.id);
    if (noteIndex >= 0) {
      _localNotes[noteIndex] = note;
      await _save();
    }
  }

  Future<void> deleteNote(Note note) async {
    await _load();

    _localNotes.removeWhere((e) => note.id == e.id);
    await _save();
  }

  Future<void> reset() async {
    await _localStorageService.remove(kNotesKey);
    _localNotes = [];
  }
}
