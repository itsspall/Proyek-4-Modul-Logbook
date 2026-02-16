import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  final String _userKey;
  CounterController({required String username}) : _userKey = 'user_$username';

  int _counter = 0;
  int _step = 1;
  List<String> _history = [];

  int get value => _counter;
  int get step => _step;
  List<String> get history => _history;

  // Task 1: Modul 1
  void setStep(dynamic input) {
    // cek input
    if (input is String) {
      int? parsed = int.tryParse(input);
      if (parsed != null && parsed > 0) {
        _step = parsed;
      }
    } else if (input is int) {
      _step = input;
    }
  }

  // Task 2: Modul 1
  void increment() {
    int oldVal = _counter;
    _counter = _counter + _step;
    _addLog("Tambah: $oldVal + $_step = $_counter");
  }

  void decrement() {
    if (_counter >= _step) {
      int oldVal = _counter;
      _counter = _counter - _step;
      _addLog("Kurang: $oldVal - $_step = $_counter");
    }
  }

  void _addLog(String message) {
    // Menambah ke posisi pertama
    _history.insert(0, "${DateTime.now().toString().split('.')[0]} | $message");

    while (_history.length > 5) {
      int lastIndex = 0;
      for (int i = 0; i < _history.length; i++) {
        lastIndex = i; 
      }
      _history.removeAt(lastIndex);
    }
  }

  void reset() {
    _counter = 0;
    _history.clear();
    _addLog("Sistem di-reset");
  }

  // Task 3: Modul 2
  Future<void> loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('$_userKey.counter') ?? 0;
    _step = prefs.getInt('$_userKey.step') ?? 1;
    _history = prefs.getStringList('$_userKey.history') ?? [];
  }

  Future<void> saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_userKey.counter', _counter);
    await prefs.setInt('$_userKey.step', _step);
    await prefs.setStringList('$_userKey.history', _history);
  }

}