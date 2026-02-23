import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/logbook/widgets/log_item_widget.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                _controller.addLog(
                  _titleController.text,
                  _contentController.text,
                );

                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Catatan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                _controller.updateLog(
                  index,
                  _titleController.text,
                  _contentController.text,
                );

                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin ingin keluar?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const OnboardingView()),
                            (route) => false,
                          );
                        },
                        child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                }  
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.logsNotifier,
        builder: (context, logs, _) {
          if (logs.isEmpty) {
            return const Center(child: Text("Belum ada catatan."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = logs[index];

              return LogItemWidget(
                log: log,
                index: index,
                onEdit: () => _showEditLogDialog(index, log),
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text("Konfirmasi Hapus"),
                        content: const Text("Apakah Anda yakin ingin menghapus catatan ini?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () {
                              final targetIndex = index;
                              _controller.deleteLog(targetIndex);
                              Navigator.pop(dialogContext);
                            },
                            child: const Text("Ya, Hapus", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    }  
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: Colors.deepPurple.shade100,
        child: const Icon(Icons.add, color: Colors.deepPurple),
      ),
    );
  }
}