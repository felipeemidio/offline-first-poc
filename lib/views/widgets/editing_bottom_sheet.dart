import 'package:flutter/material.dart';

Future<String?> showEditingBottomSheet(BuildContext context, {String? initialValue}) {
  return showModalBottomSheet<String>(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => EditingBottomSheet(initialValue: initialValue ?? ''),
  );
}

class EditingBottomSheet extends StatefulWidget {
  final String initialValue;
  const EditingBottomSheet({super.key, this.initialValue = ''});

  @override
  State<EditingBottomSheet> createState() => _EditingBottomSheetState();
}

class _EditingBottomSheetState extends State<EditingBottomSheet> {
  final _fieldController = TextEditingController();
  bool hasContent = false;

  @override
  void initState() {
    super.initState();
    _fieldController.text = widget.initialValue;
    _fieldController.addListener(_listenField);
  }

  @override
  void dispose() {
    _fieldController.removeListener(_listenField);
    _fieldController.dispose();
    super.dispose();
  }

  _listenField() {
    setState(() {
      hasContent = _fieldController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 32, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Change the note content!', style: Theme.of(context).textTheme.headlineSmall),
          TextField(
            controller: _fieldController,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: hasContent
                ? () {
                    Navigator.of(context).pop(_fieldController.text.trim());
                  }
                : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
