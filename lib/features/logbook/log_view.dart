import 'package:flutter/material.dart';
import 'package:logbook_app_053/features/logbook/log_controller.dart';
import 'package:logbook_app_053/features/logbook/models/log_model.dart';
import 'package:logbook_app_053/features/logbook/widgets/log_item_widget.dart';
import 'package:logbook_app_053/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_053/services/access_control_service.dart';
import 'package:logbook_app_053/features/logbook/log_editor_page.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;
  late final Map<String, dynamic> currentUser;

  @override
  void initState() {
    super.initState();
    
    currentUser = {
      'uid': 'user_001',
      'username': widget.username,
      'teamId': 'KELOMPOK_1', 
      'role': 'Anggota',      
    };
    _controller = LogController(username: widget.username);
    
    _controller.loadFromDisk(currentUser['teamId'], currentUser['uid']);
  }

  // Untuk navigasi ke halaman editor
  void _goToEditor({LogModel? log, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Tim: ${currentUser['teamId']} | ${currentUser['role']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const OnboardingView()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => _controller.searchLog(value),
              decoration: InputDecoration(
                labelText: "Cari Catatan...",
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogsNotifier,
              builder: (context, logs, _) {
                if (logs.isEmpty) {
                  return const Center(child: Text("Belum ada catatan. Klik + untuk membuat.", style: TextStyle(color: Colors.grey)));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: logs.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    
                    // PENGECEKAN KEPEMILIKAN DATA
                    final bool isOwner = log.authorId == currentUser['uid'];

                    // Boleh Hapus? Boleh Edit?
                    final bool canDelete = AccessControlService.canPerform(
                      currentUser['role'], 
                      AccessControlService.actionDelete, 
                      isOwner: isOwner
                    );
                    
                    final bool canEdit = AccessControlService.canPerform(
                      currentUser['role'], 
                      AccessControlService.actionUpdate, 
                      isOwner: isOwner
                    );

                    return LogItemWidget(
                      log: log,
                      index: index,
                      // Jika boleh, jalankan fungsi. Jika tidak, munculkan peringatan Ditolak!
                      onEdit: canEdit ? () => _goToEditor(log: log, index: index) : () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akses Ditolak: Anda bukan pemilik catatan ini."), backgroundColor: Colors.red));
                      },
                      onDelete: canDelete ? () => _controller.removeLog(index) : () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akses Ditolak: Anda tidak punya wewenang menghapus."), backgroundColor: Colors.red));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToEditor(),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}