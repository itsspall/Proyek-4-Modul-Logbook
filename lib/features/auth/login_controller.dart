class LoginController {
  // Database sederhana (Hardcoded)
  // final String _validUsername = "admin";
  // final String _validPassword = "123";

  // Database sederhana menggunakan map untuk menyimpan beberapa user
  final Map<String, String> _users = {
    'admin': 'admin123',
    'dosen': 'dosen2024',
    'mahasiswa': 'mhs123',
    'budi': 'kopi_hitam',
  };
  // Fungsi pengecekan (Logic-Only)
  // Fungsi ini mengembalikan true jika cocok, false jika salah.
  bool login(String username, String password) {
    if (_users[username] == password) {
      return true;
    }
    return false;
  }

  void increment() {}

  Future<void> saveCounter() async {}

  void decrement() {}
}
