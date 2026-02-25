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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      backgroundColor: Colors.blue.shade50, // Latar belakang biru muda
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800, // Biru tua
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // CARD UNTUK ANGKA UTAMA
            Card(
              elevation: 6,
              shadowColor: Colors.blue.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Text("Total Hitungan:", style: TextStyle(fontSize: 18, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text(
                      '${_controller.value}', 
                      style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.blue.shade900)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // INPUT TEXTFIELD
            TextField(
              controller: _stepInput,
              decoration: InputDecoration(
                labelText: "Masukkan Nilai Step",
                prefixIcon: Icon(Icons.numbers, color: Colors.blue.shade700),
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
              keyboardType: TextInputType.number,
              onChanged: (val) => _controller.setStep(val),
            ),
            
            const SizedBox(height: 25),
            
            // BARIS TOMBOL (BUTTONS)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() => _controller.increment());
                    await _controller.saveCounter();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("+", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => _controller.decrement());
                    await _controller.saveCounter();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("-", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _showResetDialog();
                    await _controller.saveCounter();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Reset", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            const Divider(height: 40, thickness: 1.5),
            
            // JUDUL RIWAYAT
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "5 Aktivitas Terakhir:", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade900)
              ),
            ),
            const SizedBox(height: 10),
            
            // LIST RIWAYAT
            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  final log = _controller.history[index];
                  Color itemColor = Colors.black87;
                  Color iconBgColor = Colors.grey.shade200;

                  if (log.contains("Tambah")) {
                    itemColor = Colors.green.shade700; // Untuk log tambah
                    iconBgColor = Colors.green.shade50;
                  } 
                  if (log.contains("Kurang")) {
                    itemColor = Colors.red.shade700; // Untuk log kurang
                    iconBgColor = Colors.red.shade50;
                  }

                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconBgColor,
                        child: Icon(Icons.history, size: 20, color: itemColor),
                      ),
                      title: Text(log, style: TextStyle(fontSize: 14, color: itemColor, fontWeight: FontWeight.w500)),
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