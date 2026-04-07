import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'db_helper.dart';

class BackupService {
  static const String _backupFolder = 'toko_rajawali_backups';
  static const String _latestBackupFile = 'latest_backup.json';

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
