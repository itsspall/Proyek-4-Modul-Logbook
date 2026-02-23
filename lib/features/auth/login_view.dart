import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';
import 'package:logbook_app_001/features/logbook/log_view.dart';

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
      appBar: AppBar(title: const Text("Login Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // TOMBOL LOGIN
            ElevatedButton(
              onPressed: _controller.isLocked ? null : _handleLogin, 
              child: const Text("Masuk")
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
    );
  }
}