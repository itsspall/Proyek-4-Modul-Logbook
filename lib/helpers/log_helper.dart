import 'dart:io';
import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    if (level > configLevel) return;
    if (muteList.split(',').contains(source)) return;

    try {
      String timeOnly = DateFormat('HH:mm:ss').format(DateTime.now());
      String dateOnly = DateFormat('dd-MM-yyyy').format(DateTime.now()); // Format nama file
      String label = _getLabel(level);
      String color = _getColor(level);

      dev.log(message, name: source, time: DateTime.now(), level: level * 100);

      String logText = '[$timeOnly][$label][$source] -> $message';
      print('$color$logText\x1B[0m');

      // 3. (HOTS Task) PENULISAN KE FILE FISIK .log
      await _writeToFile(dateOnly, logText);
      
    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  // Fungsi privat pembuat file .log
  static Future<void> _writeToFile(String date, String logText) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final file = File('${logDir.path}/$date.log');
      
      await file.writeAsString('$logText\n', mode: FileMode.append);
    } catch (e) {
      print("Gagal menulis ke file log fisik: $e");
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1: return "ERROR";
      case 2: return "INFO";
      case 3: return "VERBOSE";
      default: return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1: return '\x1B[31m'; // Merah
      case 2: return '\x1B[32m'; // Hijau
      case 3: return '\x1B[34m'; // Biru
      default: return '\x1B[0m';
    }
  }
}