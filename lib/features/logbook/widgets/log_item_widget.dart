import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';

class LogItemWidget extends StatelessWidget {
  final LogModel log;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LogItemWidget({
    super.key,
    required this.log,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Expanded(child: Text(log.title)),
            Chip(
              label: Text(
                log.category,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: log.category.toLowerCase() == 'Pribadi'
                  ? Colors.blue.shade300
                  : log.category.toLowerCase() == 'Tugas Kuliah'
                      ? Colors.green.shade300
                      : log.category.toLowerCase() == 'Pekerjaan'
                          ? Colors.orange.shade300
                          : const Color.fromARGB(255, 255, 0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(log.description),
            const SizedBox(height: 6),
            Text(
              log.date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
