import 'package:offline_first_poc/cache/notes_cache.dart';
import 'package:offline_first_poc/datasources/api_datasource.dart';
import 'package:offline_first_poc/models/note.dart';
import 'package:offline_first_poc/repositories/repository.dart';

class NoteRepository extends Repository {
  final ApiDatasource _datasource;
  final NotesCache _cache;

  const NoteRepository(this._datasource, this._cache);

  Future<List<Note>> getAllNotes() async {
    // Try to sync
    try {
      final response = await _datasource.httpClient.get('/notes');
      final notes = (response.data as List).map((e) => Note.fromMap(e, isSync: true)).toList();
      await _cache.saveNotes(notes);
    } catch (e) {
      // handle the error
    }

    // retrieve the local data
    return _cache.getNotes();
  }

  Future<Note> getById(String id) async {
    // Try to sync
    try {
      final response = await _datasource.httpClient.get('/notes/$id');
      final note = Note.fromMap(response.data);
      final existingNote = await _cache.getById(id);
      if (existingNote != null) {
        await _cache.editNote(note);
      } else {
        await _cache.saveNote(note);
      }
    } catch (e) {
      // handle the error
    }

    // retrieve the local data
    final note = await _cache.getById(id);
    if (note != null) {
      return note;
    } else {
      throw Exception('Note not found');
    }
  }

  Future<Note> createNote(Note note) async {
    // Save locally first
    Note currentNote = note.copyWith(isSync: false);
    await _cache.saveNote(currentNote);

    // Try to sync
    try {
      final response = await _datasource.httpClient.post('/notes', data: {'content': note.content});
      currentNote = Note.fromMap(response.data, isSync: true);
      await _cache.editNote(currentNote);
    } catch (e) {
      // handle the error
    }

    // retrieve the local data
    return currentNote;
  }

  Future<void> editNote(Note note) async {
    // Save locally first
    await _cache.editNote(note.copyWith(isSync: false));

    // Try to sync
    try {
      await _datasource.httpClient.put('/notes/${note.id}', data: {"content": note.content});
      await _cache.editNote(note.copyWith(isSync: true));
    } catch (e) {
      // handle the error
    }

    // has nothing to retrieve
  }

  Future<void> deleteNote(Note note) async {
    // Save locally first
    await _cache.editNote(note.copyWith(isSync: false, isDeleted: true));

    // Try to sync
    try {
      await _datasource.httpClient.delete('/notes/${note.id}');
      await _cache.deleteNote(note);
    } catch (e) {
      // handle the error
    }

    // has nothing to retrieve
  }

  @override
  Future<void> sync() async {
    // Create a copy of the list
    final allNotes = List<Note>.from(await _cache.getNotes());

    // Iterate to sync every unsync model
    for (Note note in allNotes) {
      if (note.isSync) {
        continue;
      }
      try {
        if (note.isDeleted) {
          if (note.hasTempId) {
            _cache.deleteNote(note);
          } else {
            await deleteNote(note);
          }
        } else if (note.hasTempId) {
          await createNote(note);
        } else {
          await editNote(note);
        }
      } catch (e) {
        continue;
      }
    }
  }

  Future<void> clear() async {
    await _cache.clear();
  }
}
