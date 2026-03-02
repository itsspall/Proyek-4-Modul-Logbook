import 'package:flutter/material.dart';
import 'package:logbook_app_053/features/logbook/models/log_model.dart';
import 'package:logbook_app_053/services/mongo_service.dart';
import 'package:logbook_app_053/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  
  LogController({required String username}) { 
    // Data tidak lagi hardcoded, tapi diambil dari MongoDB Atlas berdasarkan username
  }

  // READ: Membaca dari MongoDB Atlas
  Future<void> loadFromDisk() async {
    final cloudData = await MongoService().getLogs();
    logsNotifier.value = cloudData;
    filteredLogsNotifier.value = cloudData;
  }

  // CREATE: Menambah data ke Cloud
  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      title: title, 
      description: desc, 
      date: DateTime.now().toString(),
      category: category
    );
    
    try {
      await MongoService().insertLog(newLog);
      await loadFromDisk();
      await LogHelper.writeLog("SUCCESS: Tambah data ke Cloud", source: "log_controller.dart", level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal Tambah - $e", source: "log_controller.dart", level: 1);
    }
  }

  // UPDATE: Mengedit data di Cloud
  Future<void> updateLog(int index, String title, String desc, String category) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: title, 
      description: desc, 
      date: oldLog.date, 
      category: category 
    );
    
    try {
      await MongoService().updateLog(updatedLog); // Update di Cloud
      await loadFromDisk();
      await LogHelper.writeLog("SUCCESS: Update '${oldLog.title}' Berhasil", source: "log_controller.dart", level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal Update - $e", source: "log_controller.dart", level: 1);
    }
  }

  // DELETE: Menghapus data di Cloud
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) throw Exception("ID tidak ditemukan");
      
      await MongoService().deleteLog(targetLog.id!); // Hapus di Cloud
      await loadFromDisk(); // Refresh UI
      await LogHelper.writeLog("SUCCESS: Hapus '${targetLog.title}' Berhasil", source: "log_controller.dart", level: 2);
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal Hapus - $e", source: "log_controller.dart", level: 1);
    }
  }

  // FITUR PENCARIAN
  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogsNotifier.value = logsNotifier.value;
    } else {
      filteredLogsNotifier.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}