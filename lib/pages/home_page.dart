import 'package:flutter/material.dart';
import 'package:offline_first_poc/datasources/firestore_datasource.dart';
import 'package:offline_first_poc/models/note.dart';
import 'package:offline_first_poc/widgets/editing_bottom_sheet.dart';
import 'package:offline_first_poc/widgets/note_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestoreDatasource = FirestoreDatasource();
  final _addFieldController = TextEditingController();
  bool hasContentToAdd = false;
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _addFieldController.addListener(_updateAddAction);
    _getNotes();
  }

  @override
  void dispose() {
    _addFieldController.removeListener(_updateAddAction);
    _addFieldController.dispose();
    super.dispose();
  }

  Future<void> _getNotes() async {
    final allNotes = await _firestoreDatasource.getAllNotes();
    setState(() {
      notes = allNotes;
    });
  }

  void _updateAddAction() {
    setState(() {
      hasContentToAdd = _addFieldController.text.trim().isNotEmpty;
    });
  }

  Future<void> _addNote() async {
    if (!hasContentToAdd) {
      return;
    }
    final currentDate = DateTime.now();
    final newNote = Note(
      content: _addFieldController.text.trim(),
      createdAt: currentDate,
    );
    notes.add(newNote);
    _addFieldController.clear();
    _firestoreDatasource.saveNote(newNote).then((value) => _getNotes());

    setState(() {});
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _deleteNote(Note note) {
    if (!notes.contains(note)) {
      return;
    }
    if (note.id != null) {
      _firestoreDatasource.deleteNote(note);
      _getNotes();
    } else {
      notes.remove(note);
      setState(() {});
    }
  }

  Future<void> _editNote(Note note) async {
    final newContent = await showEditingBottomSheet(context, initialValue: note.content);
    if (newContent != null) {
      final itemIndex = notes.indexOf(note);
      if (itemIndex < 0) {
        return;
      }

      final editedNote = Note(content: newContent, id: note.id, createdAt: note.createdAt);
      if (note.id != null) {
        _firestoreDatasource.editNote(editedNote);
        _getNotes();
      } else {
        notes[itemIndex] = editedNote;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _addFieldController,
              decoration: InputDecoration(
                suffix: IconButton(
                  onPressed: hasContentToAdd ? _addNote : null,
                  icon: Icon(
                    Icons.add,
                    color: hasContentToAdd ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(builder: (context) {
                if (notes.isEmpty) {
                  return const Center(
                    child: Text('You don\'t have a note. Try to create one!'),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: notes.reversed
                        .map(
                          (note) => NoteTile(
                            note: note,
                            onDelete: () => _deleteNote(note),
                            onEdit: () => _editNote(note),
                          ),
                        )
                        .toList(),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
