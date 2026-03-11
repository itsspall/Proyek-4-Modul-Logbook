import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/empty_logs.svg',
              height: 180,
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada aktivitas hari ini?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai catat kemajuan proyek Anda agar tim bisa memantau progres dengan lebih rapi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _goToEditor(),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Tulis Aktivitas Pertama'),
            ),
          ],
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
                labelText: "Cari judul atau isi Markdown...",
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
              builder: (context, logs, _) => logs.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: logs.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final sourceIndex = _controller.logsNotifier.value.indexWhere((item) => item.id == log.id);
                        if (sourceIndex == -1) {
                          return const SizedBox.shrink();
                        }
                        
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
                          onEdit: canEdit ? () => _goToEditor(log: log, index: sourceIndex) : () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akses Ditolak: Anda bukan pemilik catatan ini."), backgroundColor: Colors.red));
                          },
                          onDelete: canDelete ? () => _controller.removeLog(sourceIndex) : () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akses Ditolak: Anda tidak punya wewenang menghapus."), backgroundColor: Colors.red));
                          },
                        );
                      },
                    ),
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