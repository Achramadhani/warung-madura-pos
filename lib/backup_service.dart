import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_helper.dart';

class BackupService {
  static const String _backupFolder = 'toko_rajawali_backups';
  static const String _latestBackupFile = 'latest_backup.json';
  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const String _autoBackupFrequencyKey = 'auto_backup_frequency';
  static const String _lastAutoBackupAtKey = 'last_auto_backup_at';

  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';

  Future<Directory> _getBackupDirectory() async {
    Directory baseDir;
    try {
      baseDir = Platform.isAndroid
          ? (await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory())
          : await getApplicationDocumentsDirectory();
    } catch (_) {
      baseDir = await getApplicationDocumentsDirectory();
    }

    final backupDir = Directory(p.join(baseDir.path, _backupFolder));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<String> backupData() async {
    final backupDir = await _getBackupDirectory();
    final backupData = await DbHelper.instance.exportDatabaseToJson();
    final jsonString = jsonEncode(backupData);
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.-]'), '');
    final backupFile = File(p.join(backupDir.path, 'backup_$timestamp.json'));
    await backupFile.writeAsString(jsonString);

    final latestFile = File(p.join(backupDir.path, _latestBackupFile));
    await latestFile.writeAsString(jsonString);

    return backupFile.path;
  }

  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoBackupEnabledKey) ?? false;
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupEnabledKey, enabled);
  }

  Future<String> getAutoBackupFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_autoBackupFrequencyKey) ?? frequencyDaily;
    if (value != frequencyDaily && value != frequencyWeekly) {
      return frequencyDaily;
    }
    return value;
  }

  Future<void> setAutoBackupFrequency(String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    final safeValue =
        (frequency == frequencyWeekly) ? frequencyWeekly : frequencyDaily;
    await prefs.setString(_autoBackupFrequencyKey, safeValue);
  }

  Future<DateTime?> getLastAutoBackupAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastAutoBackupAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> runAutoBackupIfDue() async {
    final enabled = await isAutoBackupEnabled();
    if (!enabled) return;

    final frequency = await getAutoBackupFrequency();
    final lastBackup = await getLastAutoBackupAt();
    final now = DateTime.now();

    final interval = frequency == frequencyWeekly
        ? const Duration(days: 7)
        : const Duration(days: 1);
    final isDue = lastBackup == null || now.difference(lastBackup) >= interval;

    if (!isDue) return;

    await backupData();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAutoBackupAtKey, now.toIso8601String());
  }

  Future<File> _getLatestBackupFile() async {
    final backupDir = await _getBackupDirectory();
    final latestFile = File(p.join(backupDir.path, _latestBackupFile));
    if (!await latestFile.exists()) {
      throw Exception(
          'Backup terbaru tidak ditemukan. Silakan lakukan backup terlebih dahulu.');
    }
    return latestFile;
  }

  Future<void> restoreLatestBackup() async {
    final latestFile = await _getLatestBackupFile();
    final content = await latestFile.readAsString();
    final jsonData = jsonDecode(content) as Map<String, dynamic>;
    await DbHelper.instance.restoreDatabaseFromJson(jsonData);
  }

  Future<String> getBackupFolderPath() async {
    final backupDir = await _getBackupDirectory();
    return backupDir.path;
  }
}
