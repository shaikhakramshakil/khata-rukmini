import '../../core/providers.dart';
import 'csv_export.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isWorking = false;
  bool _includeDeleted = false;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _backupData() async {
    setState(() => _isWorking = true);
    try {
      final dbFolder = await getApplicationSupportDirectory();
      final dbFile = File(p.join(dbFolder.path, 'jewelry_khata.sqlite'));

      if (!await dbFile.exists()) {
        throw Exception('Database file not found!');
      }

      String? selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select Backup Location',
      );

      if (selectedDirectory == null) {
        return; // User canceled
      }

      final dateStr = DateFormat(
        'yyyy-MM-dd_HHmmss',
      ).format(DateTime.now());
      final backupFile = File(
        p.join(selectedDirectory, 'khata_backup_$dateStr.sqlite'),
      );

      await dbFile.copy(backupFile.path);
      // Copy WAL/SHM sidecars so recent sales are not lost.
      for (final suffix in ['-wal', '-shm']) {
        final sidecar = File('${dbFile.path}$suffix');
        if (await sidecar.exists()) {
          await sidecar.copy('${backupFile.path}$suffix');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup successful! Saved to: ${backupFile.path}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _restoreData() async {
    setState(() => _isWorking = true);
    var dbClosed = false;
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select Backup File to Restore',
        type: FileType.custom,
        allowedExtensions: ['sqlite', 'db'],
      );

      if (result.isEmpty || result.single.path == null) {
        return; // User canceled
      }

      final backupFile = File(result.single.path!);

      final dbFolder = await getApplicationSupportDirectory();
      final dbFile = File(p.join(dbFolder.path, 'jewelry_khata.sqlite'));

      // Close the active database connection before overwriting
      final db = ref.read(databaseProvider);
      await db.close();
      dbClosed = true;

      // Copy over the current database
      await backupFile.copy(dbFile.path);

      // Delete WAL and SHM journal files to prevent corruption
      final walFile = File('${dbFile.path}-wal');
      final shmFile = File('${dbFile.path}-shm');
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();

      // Invalidate databaseProvider to create a fresh active connection immediately
      ref.invalidate(databaseProvider);
      ref.invalidate(shopSettingsProvider);
      ref.invalidate(partiesListProvider);
      ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Restore Successful'),
            content: const Text(
              'The database has been successfully restored and reloaded. All party balances, transactions, and settings are now live.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore Failed: $e')));
      }
    } finally {
      // Always reopen even on failure so the app is not stuck with a closed DB.
      if (dbClosed) {
        ref.invalidate(databaseProvider);
        ref.invalidate(shopSettingsProvider);
        ref.invalidate(partiesListProvider);
        ref.invalidate(dashboardStatsProvider);
      }
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _isWorking = true);
    try {
      if (_startDate != null &&
          _endDate != null &&
          _startDate!.isAfter(_endDate!)) {
        throw Exception('From date must not be after To date.');
      }
      String? selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select Location for CSV Export',
      );

      if (selectedDirectory == null) {
        return; // User canceled
      }

      final db = ref.read(databaseProvider);
      final csvService = CsvExportService(db);
      final csvFile = await csvService.exportTransactionsToCsv(
        selectedDirectory,
        includeDeleted: _includeDeleted,
        startDate: _startDate,
        endDate: _endDate != null
            ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV Export successful! Saved to: ${csvFile.path}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('CSV Export Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backup & Restore', style: AppTypography.headingLarge),
            const SizedBox(height: 4),
            Text(
              'Keep your Khata data safe by creating manual backups.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.backup_outlined,
                        size: 32,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Export Database Backup',
                              style: AppTypography.headingMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Creates a complete snapshot of all your transactions and parties.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.mute,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                        label: 'Backup Now',
                        icon: Icons.download,
                        isLoading: _isWorking,
                        onPressed: _backupData,
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: AppColors.hairline),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.restore_outlined,
                        size: 32,
                        color: AppColors.badgeDrText,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Restore from Backup',
                              style: AppTypography.headingMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'WARNING: This will completely replace your current database.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.badgeDrText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                        label: 'Restore',
                        variant: AppButtonVariant.secondary,
                        icon: Icons.upload,
                        isLoading: _isWorking,
                        onPressed: _restoreData,
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: AppColors.hairline),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.table_chart_outlined,
                        size: 32,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Export as CSV',
                              style: AppTypography.headingMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Generate a spreadsheet of all transactions readable in Excel.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.mute,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: _includeDeleted,
                                  onChanged: (val) => setState(
                                    () => _includeDeleted = val ?? false,
                                  ),
                                  activeColor: AppColors.ink,
                                ),
                                const Text('Include deleted records'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text('Date Range:', style: AppTypography.bodySmall),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() => _startDate = picked);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.hairline),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _startDate != null ? AppFormatters.formatInputDate(_startDate!) : 'From Date',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ),
                                ),
                                if (_startDate != null)
                                  InkWell(
                                    onTap: () => setState(() => _startDate = null),
                                    child: const Icon(Icons.clear, size: 16, color: AppColors.mute),
                                  ),
                                const Text('to', style: AppTypography.bodySmall),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate ?? DateTime.now(),
                                      firstDate: _startDate ?? DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() => _endDate = picked);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.hairline),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _endDate != null ? AppFormatters.formatInputDate(_endDate!) : 'To Date',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ),
                                ),
                                if (_endDate != null)
                                  InkWell(
                                    onTap: () => setState(() => _endDate = null),
                                    child: const Icon(Icons.clear, size: 16, color: AppColors.mute),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                        label: 'Export CSV',
                        variant: AppButtonVariant.secondary,
                        icon: Icons.table_view_outlined,
                        isLoading: _isWorking,
                        onPressed: _exportCsv,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
