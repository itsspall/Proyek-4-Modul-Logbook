import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late final CounterController _controller;
  final TextEditingController _stepInput = TextEditingController(text: "1");

  // Konfirmasi reset
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Reset"),
          content: const Text("Apakah Anda yakin ingin menghqpus semua hitungan dan riwayat?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                setState(() => _controller.reset());
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data telah dibersihkan!")),
                );
              },
              child: const Text("Ya", style: TextStyle(color: Colors.red)),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Konfirmasi Logout"),
                      content: const Text("Apakah Anda yakin? Data yang belum disimpan mungkin akan hilang."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); 
                            
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const OnboardingView()),
                              (route) => false,
                            );
                          },
                          child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = CounterController(username: widget.username);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _controller.loadCounter();
    setState(() {}); // Untuk refresh tampilan setelah data dimuat
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        // Gunakan widget.username untuk menampilkan data dari kelas utama
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Kita siapkan tombol logout di sini untuk Fase 3 nanti
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logika logout nanti di Fase 3
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Total Hitungan:", style: const TextStyle(fontSize: 18)),
            Text('${_controller.value}', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
            
            TextField(
              controller: _stepInput,
              decoration: const InputDecoration(labelText: "Masukkan Nilai Step"),
              keyboardType: TextInputType.number,
              onChanged: (val) => _controller.setStep(val),
            ),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() => _controller.increment());
                    await _controller.saveCounter();
                  },
                  child: const Text("+"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => _controller.decrement());
                    await _controller.saveCounter();
                  },
                  child: const Text("-"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _showResetDialog();
                    await _controller.saveCounter();
                  },
                  child: const Text("Reset"),
                ),
              ],
            ),
            
            const Divider(height: 40),
            const Text("5 Aktivitas Terakhir:", style: TextStyle(fontWeight: FontWeight.bold)),
            
            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  final log = _controller.history[index];
                  Color itemColor = Colors.black87;
                  if (log.contains("Tambah")) itemColor = Colors.green; // Untuk log tambah
                  if (log.contains("Kurang")) itemColor = Colors.red; // Untuk log kurang

                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.history, size: 16, color: itemColor),
                      title: Text(log, style: TextStyle(fontSize: 12, color: itemColor)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}