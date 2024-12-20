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
    return Opacity(
      opacity: note.isDeleted ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    note.content,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(decoration: note.isDeleted ? TextDecoration.lineThrough : TextDecoration.none),
                  ),
                  Text(
                    DateFormat().format(note.createdAt),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(decoration: note.isDeleted ? TextDecoration.lineThrough : TextDecoration.none),
                  ),
                ],
              ),
            ),
            if (!note.isSync)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.sync_problem_outlined,
                  color: Theme.of(context).disabledColor,
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
            if (onDelete != null && !note.isDeleted)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
