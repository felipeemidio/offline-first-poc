import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:offline_first_poc/datasources/api_datasource.dart';
import 'package:offline_first_poc/models/note.dart';
import 'package:offline_first_poc/repositories/note_repository.dart';
import 'package:offline_first_poc/services/local_storage_service.dart';
import 'package:offline_first_poc/services/syncronization_service.dart';
import 'package:offline_first_poc/views/widgets/editing_bottom_sheet.dart';
import 'package:offline_first_poc/views/widgets/note_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NoteRepository _noteRepository;
  late final SyncronizationService _syncronizationService;
  final _addFieldController = TextEditingController();
  bool hasContentToAdd = false;
  bool isLoading = false;
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    final datasource = ApiDatasource();
    _noteRepository = NoteRepository(datasource);
    _syncronizationService = SyncronizationService(LocalStorageService(), datasource);
    _addFieldController.addListener(_updateAddAction);
    _getNotes();
  }

  @override
  void dispose() {
    _addFieldController.removeListener(_updateAddAction);
    _addFieldController.dispose();
    super.dispose();
  }

  _showErroSnackbar(dynamic err) {
    String message = err.toString();
    if (err is DioException) {
      message = err.response == null ? 'No connection' : (err.message ?? err.type.toString());
    }

    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _getNotes() async {
    try {
      isLoading = true;
      setState(() {});
      final allNotes = await _noteRepository.getAllNotes();
      setState(() {
        notes = allNotes;
      });
    } catch (e) {
      _showErroSnackbar(e);
    } finally {
      isLoading = false;
      setState(() {});
    }
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
    try {
      isLoading = true;
      setState(() {});
      final newNote = Note.generate(_addFieldController.text.trim());
      _addFieldController.clear();
      await _noteRepository.createNote(newNote);
    } catch (e) {
      _showErroSnackbar(e);
    } finally {
      isLoading = false;
      setState(() {});
    }

    _getNotes();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _deleteNote(Note note) async {
    try {
      if (!notes.contains(note)) {
        return;
      }
      isLoading = true;
      setState(() {});
      _noteRepository.deleteNote(note);
    } catch (e) {
      _showErroSnackbar(e);
    } finally {
      isLoading = false;
      setState(() {});
    }
    _getNotes();
  }

  Future<void> _editNote(Note note) async {
    final newContent = await showEditingBottomSheet(context, initialValue: note.content);
    if (newContent != null) {
      isLoading = true;
      setState(() {});
      final itemIndex = notes.indexOf(note);
      if (itemIndex < 0) {
        return;
      }

      try {
        final editedNote = note.copyWith(content: newContent);
        await _noteRepository.editNote(editedNote);
      } catch (e) {
        _showErroSnackbar(e);
      }
      isLoading = false;
      setState(() {});
      _getNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : () async {
                    isLoading = true;
                    setState(() {});
                    try {
                      await LocalStorageService().clear();
                    } finally {
                      if (mounted) {
                        isLoading = false;
                        setState(() {});
                      }
                    }
                  },
            icon: const Icon(
              Icons.auto_delete_outlined,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: isLoading
                ? null
                : () async {
                    isLoading = true;
                    setState(() {});
                    try {
                      await _syncronizationService.sync();
                      await _getNotes();
                    } catch (e) {
                      if (mounted) {
                        isLoading = false;
                        setState(() {});
                      }
                    }
                  },
            icon: Icon(
              Icons.refresh,
              color: isLoading ? Colors.grey.withOpacity(0.5) : Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _addFieldController,
              decoration: InputDecoration(
                suffix: IconButton(
                  onPressed: (hasContentToAdd || isLoading) ? _addNote : null,
                  icon: Icon(
                    Icons.add,
                    color: (hasContentToAdd || isLoading)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(builder: (context) {
                if (isLoading) {
                  return const Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 16),
                        Text('loading...'),
                        SizedBox(height: 16),
                        CircularProgressIndicator(),
                      ],
                    ),
                  );
                }
                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('You don\'t have a note. Try to create one!'),
                        const SizedBox(height: 24),
                        IconButton(onPressed: _getNotes, icon: const Icon(Icons.refresh)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _getNotes,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
