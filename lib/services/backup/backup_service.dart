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

  /// Creates an instant backup of the live SQLite database.
  /// Copies main file plus -wal/-shm so recent sales are not lost.
  Future<File> createBackup({String? customTargetDirectory}) async {
    final dbFile = await _getLiveDatabaseFile();
    if (!await dbFile.exists()) {
      throw Exception('Database file does not exist to back up.');
    }
    _validateSqliteHeader(await dbFile.openRead(0, 16).first);

    final targetDir = customTargetDirectory != null
        ? Directory(customTargetDirectory)
        : await getDefaultBackupDirectory();

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final backupFileName = 'khata_backup_$timestamp.sqlite';
    final destination = File(p.join(targetDir.path, backupFileName));

    final copied = await dbFile.copy(destination.path);
    // Copy WAL/SHM sidecars alongside so the backup is complete.
    for (final suffix in ['-wal', '-shm']) {
      final sidecar = File('${dbFile.path}$suffix');
      if (await sidecar.exists()) {
        await sidecar.copy('${destination.path}$suffix');
      }
    }

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
    try {
      final settings = await _settingsRepo.getSettings();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (settings.lastAutoBackupDate != todayStr) {
        await createBackup(customTargetDirectory: settings.backupDirectory);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void _validateSqliteHeader(List<int> header) {
    const magic = [83, 81, 76, 105, 116, 101, 32, 102, 111, 114, 109, 97, 116, 32, 51, 0];
    if (header.length < 16) throw const FormatException('Not a SQLite file');
    for (var i = 0; i < 16; i++) {
      if (header[i] != magic[i]) throw const FormatException('Not a SQLite file');
    }
  }

  /// Safely restores database from a selected backup file.
  /// Caller must close/invalidate the database before and after calling.
  Future<void> restoreBackup(File backupFile) async {
    if (!await backupFile.exists()) {
      throw Exception('Selected backup file does not exist.');
    }
    _validateSqliteHeader(await backupFile.openRead(0, 16).first);

    final dbFile = await _getLiveDatabaseFile();

    // 1. Create a safety snapshot of the live database prior to restoring
    if (await dbFile.exists()) {
      final defaultDir = await getDefaultBackupDirectory();
      final preRestoreName =
          'PreRestore_Safety_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.sqlite';
      await dbFile.copy(p.join(defaultDir.path, preRestoreName));
      await _cleanOldBackups(
        defaultDir,
        keepCount: 7,
        includePreRestore: true,
      );
    }

    // 2. Overwrite live database with the restored backup file
    await backupFile.copy(dbFile.path);
    // Remove stale WAL/SHM so the restored main file is used cleanly.
    for (final suffix in ['-wal', '-shm']) {
      final sidecar = File('${dbFile.path}$suffix');
      if (await sidecar.exists()) await sidecar.delete();
    }
  }

  Future<void> _cleanOldBackups(
    Directory backupDir, {
    int keepCount = 7,
    bool includePreRestore = false,
  }) async {
    try {
      final entities = await backupDir.list().toList();
      bool isBackup(File f) {
        final name = p.basename(f.path);
        final isMain = (name.startsWith('JewelryKhata_Backup_') &&
                f.path.endsWith('.db')) ||
            (name.startsWith('khata_backup_') &&
                (f.path.endsWith('.sqlite') || f.path.endsWith('.db')));
        if (isMain) return true;
        if (includePreRestore &&
            name.startsWith('PreRestore_Safety_') &&
            (f.path.endsWith('.db') || f.path.endsWith('.sqlite'))) {
          return true;
        }
        return false;
      }

      final backupFiles = entities.whereType<File>().where(isBackup).toList();

      if (backupFiles.length > keepCount) {
        final withTime = <({File file, DateTime modified})>[];
        for (final f in backupFiles) {
          withTime.add((file: f, modified: await f.lastModified()));
        }
        withTime.sort((a, b) => b.modified.compareTo(a.modified));
        for (var i = keepCount; i < withTime.length; i++) {
          await withTime[i].file.delete();
        }
      }
    } catch (_) {}
  }

  Future<List<File>> listRecentBackups() async {
    final backupDir = await getDefaultBackupDirectory();
    final entities = await backupDir.list().toList();
    final backupFiles = entities
        .whereType<File>()
        .where(
          (f) => f.path.endsWith('.db') || f.path.endsWith('.sqlite'),
        )
        .toList();
    final withTime = <({File file, DateTime modified})>[];
    for (final f in backupFiles) {
      try {
        withTime.add((file: f, modified: await f.lastModified()));
      } catch (_) {}
    }
    withTime.sort((a, b) => b.modified.compareTo(a.modified));
    return withTime.map((e) => e.file).toList();
  }
}
