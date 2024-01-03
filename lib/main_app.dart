import 'package:flutter/material.dart';
import 'package:offline_first_poc/models/note.dart';
import 'package:offline_first_poc/widgets/editing_bottom_sheet.dart';
import 'package:offline_first_poc/widgets/note_tile.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline First App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Offline First App Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _addFieldController = TextEditingController();
  bool hasContentToAdd = false;
  List<Note> notes = [];

  @override
  void initState() {
    _addFieldController.addListener(_updateAddAction);
    super.initState();
  }

  @override
  void dispose() {
    _addFieldController.removeListener(_updateAddAction);
    _addFieldController.dispose();
    super.dispose();
  }

  void _updateAddAction() {
    print('_updating');
    setState(() {
      hasContentToAdd = _addFieldController.text.trim().isNotEmpty;
    });
  }

  void _addNote() {
    print('_addNote');
    if (!hasContentToAdd) {
      return;
    }
    final currentDate = DateTime.now();
    final newNote = Note(
      id: currentDate.microsecondsSinceEpoch.toString(),
      content: _addFieldController.text.trim(),
      createdAt: currentDate,
    );
    notes.add(newNote);
    _addFieldController.clear();
    setState(() {});
    FocusManager.instance.primaryFocus?.unfocus();
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
                            onDelete: () {
                              setState(() {
                                notes.removeWhere((el) => el.id == note.id);
                              });
                            },
                            onEdit: () async {
                              final newContent = await showEditingBottomSheet(context, initialValue: note.content);
                              if (newContent != null) {
                                notes = notes.map<Note>((e) {
                                  if (e.id == note.id) {
                                    return Note(content: newContent, id: e.id, createdAt: e.createdAt);
                                  }
                                  return e;
                                }).toList();
                                setState(() {});
                              }
                            },
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
