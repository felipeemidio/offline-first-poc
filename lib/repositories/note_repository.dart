import 'package:offline_first_poc/datasources/api_datasource.dart';
import 'package:offline_first_poc/models/note.dart';

class NoteRepository {
  final ApiDatasource _datasource;

  const NoteRepository(this._datasource);

  Future<List<Note>> getAllNotes() async {
    final response = await _datasource.httpClient.get('/notes');
    final notes = (response.data as List).map((e) => Note.fromMap(e, isSync: true)).toList();
    return notes;
  }

  Future<Note> getById(String id) async {
    final response = await _datasource.httpClient.get('/notes/$id');
    return Note.fromMap(response.data);
  }

  Future<Note> createNote(Note note) async {
    final response = await _datasource.httpClient.post('/notes', data: {'content': note.content});
    return Note.fromMap(response.data);
  }

  Future<void> editNote(Note note) async {
    await _datasource.httpClient.put('/notes/${note.id}', data: {"content": note.content});
  }

  Future<void> deleteNote(Note note) async {
    await _datasource.httpClient.delete('/notes/${note.id}');
  }
}
