import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../repositories/settings_repository.dart';

class BackupService {
  final SettingsRepository _settingsRepo;

  BackupService(this._settingsRepo);

  Future<File> _getLiveDatabaseFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'jewelry_khata.sqlite'));
  }

  Future<Directory> getDefaultBackupDirectory() async {
    final dir = await getApplicationSupportDirectory();
    final backupDir = Directory(p.join(dir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Creates an instant backup of the live SQLite database
  Future<File> createBackup({String? customTargetDirectory}) async {
    final dbFile = await _getLiveDatabaseFile();
    if (!await dbFile.exists()) {
      throw Exception('Database file does not exist to back up.');
    }

    final targetDir = customTargetDirectory != null
        ? Directory(customTargetDirectory)
        : await getDefaultBackupDirectory();

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final backupFileName = 'JewelryKhata_Backup_$timestamp.db';
    final destination = File(p.join(targetDir.path, backupFileName));

    final copied = await dbFile.copy(destination.path);

    // Update settings
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _settingsRepo.updateLastBackupDate(todayStr);

    // If using default backup directory, clean up older backups keeping the latest 7
    if (customTargetDirectory == null) {
      await _cleanOldBackups(targetDir, keepCount: 7);
    }

    return copied;
  }

  /// Checks if daily backup should run on app launch/close
  Future<bool> checkAndRunDailyBackup() async {
    final settings = await _settingsRepo.getSettings();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (settings.lastAutoBackupDate != todayStr) {
      await createBackup(customTargetDirectory: settings.backupDirectory);
      return true;
    }
    return false;
  }

  /// Safely restores database from a selected backup file
  Future<void> restoreBackup(File backupFile) async {
    if (!await backupFile.exists()) {
      throw Exception('Selected backup file does not exist.');
    }

    final dbFile = await _getLiveDatabaseFile();

    // 1. Create a safety snapshot of the live database prior to restoring
    if (await dbFile.exists()) {
      final defaultDir = await getDefaultBackupDirectory();
      final preRestoreName =
          'PreRestore_Safety_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db';
      await dbFile.copy(p.join(defaultDir.path, preRestoreName));
    }

    // 2. Overwrite live database with the restored backup file
    await backupFile.copy(dbFile.path);
  }

  Future<void> _cleanOldBackups(
    Directory backupDir, {
    int keepCount = 7,
  }) async {
    try {
      final entities = await backupDir.list().toList();
      final backupFiles = entities
          .whereType<File>()
          .where(
            (f) =>
                p.basename(f.path).startsWith('JewelryKhata_Backup_') &&
                f.path.endsWith('.db'),
          )
          .toList();

      if (backupFiles.length > keepCount) {
        backupFiles.sort(
          (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
        );
        for (int i = keepCount; i < backupFiles.length; i++) {
          await backupFiles[i].delete();
        }
      }
    } catch (_) {}
  }

  Future<List<File>> listRecentBackups() async {
    final backupDir = await getDefaultBackupDirectory();
    final entities = await backupDir.list().toList();
    final backupFiles = entities
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList();
    backupFiles.sort(
      (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
    );
    return backupFiles;
  }
}
