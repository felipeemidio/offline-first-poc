import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offline_first_poc/models/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  const NoteTile({
    super.key,
    required this.note,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(note.content),
                const SizedBox(height: 8),
                Text(DateFormat().format(note.createdAt)),
              ],
            ),
          ),
          if (onEdit != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          if (onDelete != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
