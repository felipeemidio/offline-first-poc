import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:offline_first_poc/models/note.dart';

const kNoteCollectionName = 'notes';

class FirestoreDatasource {
  static FirebaseFirestore? _instance;

  static void initialize() {
    _instance = FirebaseFirestore.instance;
  }

  Future<void> saveNote(Note note) async {
    final DocumentReference doc = await _instance!.collection(kNoteCollectionName).add(note.toMap());
    print('DocumentSnapshot added with ID: ${doc.id}');
  }

  Future<List<Note>> getAllNotes() async {
    try {
      final snapshot = await _instance!.collection(kNoteCollectionName).get();
      print("_debug all notes ===========");
      for (var doc in snapshot.docs) {
        print("${doc.id} => ${doc.data()}");
      }

      print("============================");

      return snapshot.docs.map((e) => Note.fromMap(e.data(), e.id)).toList();
    } catch (error, st) {
      log(error.toString());
      log(st.toString());
      return [];
    }
  }

  Future<void> editNote(Note note) async {
    if (note.id == null) {
      return;
    }
    await _instance!.collection(kNoteCollectionName).doc(note.id).set(note.toMap());
    print('Note edited with ID: ${note.id}');
  }

  Future<void> deleteNote(Note note) async {
    if (note.id == null) {
      return;
    }
    await _instance!.collection(kNoteCollectionName).doc(note.id).delete();
    print('Note deleted with ID: ${note.id}');
  }
}
