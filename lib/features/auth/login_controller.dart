class LoginController {
  // Database sederhana (Hardcoded)
  // final String _validUsername = "admin";
  // final String _validPassword = "123";

  // Database sederhana menggunakan map untuk menyimpan beberapa user
  // Tugas 2 Modul 2: Modifikasi LoginController agar mendukung sistem Multiple Users menggunakan tipe data Map<String, String>.
  final Map<String, String> _users = {
    'admin': 'admin123',
    'dosen': 'dosen2024',
    'mahasiswa': 'mhs123',
    'budi': 'kopi_hitam',
  };
  // Batas percobaan login. Jika salah 3 kali, tombol login menjadi tidak aktif selama 10 detik.
  // Tugas 2 Modul 2
  int failedAttempts = 0;
  bool isLocked = false;
  final int maxAttempts = 3;

  bool login(String username, String password) {
      if (isLocked) {
        return false; 
      }

      if (_users.containsKey(username) && _users[username] == password) {
        failedAttempts = 0; 
        return true;
      } else {
        failedAttempts++;
        // Jika percobaan gagal mencapai batas, kunci akun
        if (failedAttempts >= maxAttempts) {
          isLocked = true;
        }
        return false;
      }
    }

  void unlock() {
    isLocked = false;
    failedAttempts = 0;
  }

  void increment() {}
  Future<void> saveCounter() async {}
  void decrement() {}
}