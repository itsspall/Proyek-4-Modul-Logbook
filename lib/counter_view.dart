import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: SR1 - Modul 1")),
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
                ElevatedButton(onPressed: () => setState(() => _controller.increment()), child: const Text("+")),
                ElevatedButton(onPressed: () => setState(() => _controller.decrement()), child: const Text("-")),
                ElevatedButton(onPressed: _showResetDialog, child: const Text("Reset")),
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