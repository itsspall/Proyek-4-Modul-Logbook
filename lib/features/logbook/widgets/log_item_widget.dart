import 'package:flutter/material.dart';
import 'package:logbook_app_053/features/logbook/models/log_model.dart';
import 'package:intl/intl.dart';

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

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      // Formatnya 04 Mar 2026, 21:00
      return DateFormat('dd MMM yyyy, HH:mm').format(date); 
    } catch (e) {
      return dateString; // Jaga-jaga kalau format salah
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.cloud_done, color: Colors.blue.shade700, size: 30),
        title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    log.category,
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(log.date),
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
          ],
        ),
      ),
    );
  }
}