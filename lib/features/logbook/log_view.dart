import 'package:flutter/material.dart';
import 'package:logbook_app_053/features/logbook/log_controller.dart';
import 'package:logbook_app_053/features/logbook/models/log_model.dart';
import 'package:logbook_app_053/features/logbook/widgets/log_item_widget.dart';
import 'package:logbook_app_053/features/onboarding/onboarding_view.dart';
// TAMBAHAN IMPORT UNTUK KONEKSI CLOUD
import 'package:logbook_app_053/services/mongo_service.dart';
import 'package:logbook_app_053/helpers/log_helper.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final LogController _controller;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  final List<String> _categories = ['Pribadi', 'Tugas Kuliah', 'Pekerjaan', 'Urgent'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = LogController(username: widget.username);
    
    Future.microtask(() => _initDatabase());
  }

  Future<void> _initDatabase() async {
    setState(() => _isLoading = true);
    try {
      await LogHelper.writeLog("UI: Memulai inisialisasi database...", source: "log_view.dart");
      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Koneksi Cloud Timeout. Periksa sinyal atau IP Whitelist."),
      );
      
      await LogHelper.writeLog("UI: Koneksi MongoService BERHASIL.", source: "log_view.dart");
      
      // Ambil data dari internet
      await _controller.loadFromDisk(); 
    } catch (e) {
      await LogHelper.writeLog("UI: Error - $e", source: "log_view.dart", level: 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Masalah: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showAddLogDialog() {
    String selectedCategory = _categories.first; 

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
            title: Text("Tambah Catatan Baru", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "Judul Catatan",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: "Isi Deskripsi",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (newValue) {
                    setStateDialog(() {
                      selectedCategory = newValue!;
                    });
                  },
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
                child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    _controller.addLog(
                      _titleController.text,
                      _contentController.text,
                      selectedCategory, 
                    );

                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    
    String selectedCategory = _categories.contains(log.category) ? log.category : _categories.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
            title: Text("Edit Catatan", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "Judul Catatan",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: "Isi Deskripsi",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (newValue) {
                    setStateDialog(() {
                      selectedCategory = newValue!;
                    });
                  },
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
                child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    _controller.updateLog(
                      index,
                      _titleController.text,
                      _contentController.text,
                      selectedCategory, 
                    );

                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Update"),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800, 
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.filteredLogsNotifier,
              builder: (context, logs, _) {
                
                if (_isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.blue.shade700),
                        const SizedBox(height: 16),
                        Text("Menghubungkan ke MongoDB Atlas...", style: TextStyle(color: Colors.blue.shade700)),
                      ],
                    ),
                  );
                }

                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 80, color: Colors.blue.shade200),
                        const SizedBox(height: 16),
                        Text("Belum ada catatan di Cloud.", style: TextStyle(color: Colors.blue.shade700, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: logs.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    return Dismissible(
                      key: Key(log.date),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _controller.removeLog(index); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Catatan dihapus dari Cloud")),
                        );
                      },
                      child: LogItemWidget(
                        log: log,
                        index: index,
                        onEdit: () => _showEditLogDialog(index, log),
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text("Konfirmasi Hapus"),
                                content: const Text("Hapus permanen dari Cloud?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text("Batal"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _controller.removeLog(index);
                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text("Ya, Hapus", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            }  
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }
}