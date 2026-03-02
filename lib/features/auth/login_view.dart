import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbook_app_053/features/auth/login_controller.dart';
import 'package:logbook_app_053/features/logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  bool _obscurePassword = true;
  int _countdown = 0;

  void _handleLogin() {
    String user = _userController.text;
    String pass = _passController.text;

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LogView(username: user),
        ),
      );
    } else {
      // kalau gagal dan statusnya terkunci, jalankan Timer
      if (_controller.isLocked && _countdown == 0) {
        _startLockoutTimer();
        _showSnackBar("Akses diblokir sementara. Tunggu $_countdown detik!", Colors.red);
      } 
      // kalau gagal tapi belum terkunci, beri tahu sisa percobaan
      else if (!_controller.isLocked) {
        int sisa = _controller.maxAttempts - _controller.failedAttempts;
        _showSnackBar("Login Gagal! Sisa percobaan: $sisa kali", Colors.orange);
      }
    }
  }

  // Fungsi untuk menjalankan hitung mundur
  void _startLockoutTimer() {
    setState(() {
      _countdown = 10;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else { // ini jika waktu habis, maka timer akan dimatikan
          _countdown = 0;
          _controller.unlock();
          timer.cancel();
        }
      });
    });
  }

  // fungsi pembantu agar kode SnackBar tidak panjang
  void _showSnackBar(String message, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: warna),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Latar belakang biru sangat muda
      appBar: AppBar(
        title: const Text("Login Page", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800, // Biru tua untuk AppBar
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView( // Mencegah error layout saat keyboard muncul
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shadowColor: Colors.blue.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon besar di atas form
                  Icon(
                    Icons.lock_person_rounded, 
                    size: 80, 
                    color: Colors.blue.shade700
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _passController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.blue.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // TOMBOL LOGIN
                  SizedBox(
                    width: double.infinity, // Tombol memenuhi lebar Card
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _controller.isLocked ? null : _handleLogin, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    ),
                  ),

                  const SizedBox(height: 15),

                  // TEKS COUNTDOWN
                  if (_controller.isLocked)
                    Text(
                      "Coba lagi dalam $_countdown detik",
                      style: const TextStyle(
                        color: Colors.red, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}