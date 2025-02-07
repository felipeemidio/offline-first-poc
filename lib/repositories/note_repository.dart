import 'package:offline_first_poc/cache/notes_cache.dart';
import 'package:offline_first_poc/datasources/api_datasource.dart';
import 'package:offline_first_poc/models/note.dart';
import 'package:offline_first_poc/repositories/repository.dart';

class NoteRepository extends Repository {
  final ApiDatasource _datasource;
  final NotesCache _cache;

  const NoteRepository(this._datasource, this._cache);

  Future<List<Note>> getAllNotes() async {
    try {
      final response = await _datasource.httpClient.get('/notes');
      final notes = (response.data as List).map((e) => Note.fromMap(e, isSync: true)).toList();
      await _cache.saveNotes(notes);
      return notes;
    } catch (e) {
      if (isNoConnetionError(e)) {
        return _cache.getNotes();
      }
      rethrow;
    }
  }

  Future<Note> getById(String id) async {
    try {
      final response = await _datasource.httpClient.get('/notes/$id');
      return Note.fromMap(response.data);
    } catch (e) {
      if (isNoConnetionError(e)) {
        final note = await _cache.getById(id);
        if (note != null) {
          return note;
        }
      }
      rethrow;
    }
  }

  Future<Note> createNote(Note note) async {
    await _cache.saveNote(note.copyWith(isSync: false));
    final response = await _datasource.httpClient.post('/notes', data: {'content': note.content});
    await _cache.editNote(note.copyWith(isSync: true));
    return Note.fromMap(response.data);
  }

  Future<void> editNote(Note note) async {
    await _cache.editNote(note.copyWith(isSync: false));
    await _datasource.httpClient.put('/notes/${note.id}', data: {"content": note.content});
    await _cache.editNote(note.copyWith(isSync: true));
  }

  Future<void> deleteNote(Note note) async {
    await _cache.editNote(note.copyWith(isSync: false, isDeleted: true));
    await _datasource.httpClient.delete('/notes/${note.id}');
    await _cache.deleteNote(note);
  }

  @override
  Future<void> sync() async {
    final allNotes = [...(await _cache.getNotes())];
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
