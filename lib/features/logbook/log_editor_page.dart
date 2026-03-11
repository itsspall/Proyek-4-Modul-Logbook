import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_053/features/logbook/models/log_model.dart';
import 'package:logbook_app_053/features/logbook/log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final Map<String, dynamic> currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  late String _selectedCategory;
  final List<String> _categories = ['Pribadi', 'Tugas Kuliah', 'Pekerjaan', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(text: widget.log?.description ?? '');
    _selectedCategory = widget.log?.category ?? _categories.first;
    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (_titleController.text.isEmpty) return;

    if (widget.log == null) {
      widget.controller.addLog(
        _titleController.text,
        _descController.text,
        _selectedCategory,
        widget.currentUser['uid'], // authorId
        widget.currentUser['teamId'], // teamId
      );
    } else {
      widget.controller.updateLog(
        widget.index!,
        _titleController.text,
        _descController.text,
        _selectedCategory,
      );
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan", style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Editor"),
              Tab(text: "Pratinjau Markdown"),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _save)
          ],
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Judul",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Kategori",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _categories.map((String c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: "Tulis dengan format Markdown...\n\nContoh:\n# Header 1\n**Teks Tebal**\n- List 1\n- List 2",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Markdown Preview untuk menampilkan hasil format
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MarkdownBody(data: _descController.text),
            ),
          ],
        ),
      ),
    );
  }
}