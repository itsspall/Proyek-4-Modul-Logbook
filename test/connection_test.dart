import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_053/services/mongo_service.dart';
import 'package:logbook_app_053/helpers/log_helper.dart';

void main() {
  const String sourceFile = "connection_test.dart";

  setUpAll(() async {
    // Memuat env sekali di awal untuk semua test
    await dotenv.load(fileName: ".env");
  });

  test(
    'Memastikan koneksi ke MongoDB Atlas berhasil via MongoService',
    () async {
      final mongoService = MongoService();

      // Memanfaatkan LogHelper baru yang sudah pakai dev.log dan print berwarna
      await LogHelper.writeLog(
        "--- START CONNECTION TEST ---",
        source: sourceFile,
      );

      try {
        await mongoService.connect();
        expect(dotenv.env['MONGODB_URI'], isNotNull);

        await LogHelper.writeLog(
          "SUCCESS: Koneksi Atlas Terverifikasi",
          source: sourceFile,
          level: 2, // INFO (Hijau)
        );
      } catch (e) {
        await LogHelper.writeLog(
          "ERROR: Kegagalan koneksi - $e",
          source: sourceFile,
          level: 1, // ERROR (Merah)
        );
        fail("Koneksi gagal: $e");
      } finally {
        await mongoService.close();
        await LogHelper.writeLog("--- END TEST ---", source: sourceFile);
      }
    },
  );
}
