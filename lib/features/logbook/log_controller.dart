import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:logbook_app_053/features/logbook/models/log_model.dart';
import 'package:logbook_app_053/services/mongo_service.dart';
import 'package:logbook_app_053/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  
  final Box<LogModel> _myBox = Hive.box<LogModel>('offline_logs');

  LogController({required String username}) {}

  // READ
  Future<void> loadFromDisk(String teamId, String currentUserId) async {
    List<LogModel> localData = _myBox.values.toList();
    localData = localData.where((log) => log.isPublic || log.authorId == currentUserId).toList();
    
    logsNotifier.value = localData;
    filteredLogsNotifier.value = localData;

    // Bagian try-catch untuk handle agar aplikasi tidak crash saat tidak ada internet.
    try {
      final cloudData = await MongoService().getLogs(teamId);
      final filteredCloudData = cloudData.where((log) => log.isPublic || log.authorId == currentUserId).toList();
      await _myBox.clear();
      await _myBox.addAll(cloudData);
      
      logsNotifier.value = filteredCloudData;
      filteredLogsNotifier.value = filteredCloudData;
      
      await LogHelper.writeLog("SYNC: Data berhasil diperbarui dari Atlas", level: 2);
    } catch (e) {
      await LogHelper.writeLog("OFFLINE: Menggunakan data cache lokal HP", level: 2);
    }
  }
  
  // CREATE
  Future<void> addLog(String title, String desc, String category, String authorId, String teamId) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title, 
      description: desc, 
      date: DateTime.now().toString(),
      category: category,
      authorId: authorId,
      teamId: teamId,
    );
    
    await _myBox.add(newLog);
    logsNotifier.value = [...logsNotifier.value, newLog];
    filteredLogsNotifier.value = logsNotifier.value;

    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog("SUCCESS: Data tersinkron ke Cloud", source: "log_controller.dart", level: 2);
    } catch (e) {
      await LogHelper.writeLog("WARNING: Data tersimpan lokal, akan sinkron saat online - $e", source: "log_controller.dart", level: 1);
    }
  }

  // UPDATE
  Future<void> updateLog(int index, String title, String desc, String category) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: title, 
      description: desc, 
      date: oldLog.date, 
      category: category,
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      isPublic: oldLog.isPublic,
    );
    
    await _myBox.putAt(index, updatedLog);
    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;
    filteredLogsNotifier.value = currentLogs;

    try {
      await MongoService().updateLog(updatedLog); 
      await LogHelper.writeLog("SUCCESS: Update '${oldLog.title}' Berhasil", source: "log_controller.dart", level: 2);
    } catch (e) {
      await LogHelper.writeLog("WARNING: Update disimpan lokal, Cloud gagal - $e", source: "log_controller.dart", level: 1);
    }
  }

  // DELETE
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    await _myBox.deleteAt(index);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    filteredLogsNotifier.value = currentLogs;

    try {
      if (targetLog.id == null) throw Exception("ID tidak ditemukan");
      await MongoService().deleteLog(targetLog.id!); 
      await LogHelper.writeLog("SUCCESS: Hapus '${targetLog.title}' Berhasil", source: "log_controller.dart", level: 2);
    } catch (e) {
      await LogHelper.writeLog("WARNING: Hapus di lokal berhasil, Cloud gagal - $e", source: "log_controller.dart", level: 1);
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