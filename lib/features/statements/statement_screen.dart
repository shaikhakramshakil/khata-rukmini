import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../repositories/models/statement_models.dart';
import '../../repositories/statement_repository.dart';
import '../../services/pdf/pdf_generator_service.dart';
import '../../services/pdf/printing_service.dart';

class StatementScreen extends ConsumerStatefulWidget {
  final String? initialPartyId;

  const StatementScreen({super.key, this.initialPartyId});

  @override
  ConsumerState<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends ConsumerState<StatementScreen> {
  String? _selectedPartyId;
  late DateTime _fromDate;
  late DateTime _toDate;
  String _datePreset = 'thisMonth';
  bool _isGeneralLedger = false;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _selectedPartyId = widget.initialPartyId;
    final (from, to) = _calculateDatesForPreset('thisMonth');
    _fromDate = from;
    _toDate = to;
    _datePreset = 'thisMonth';
  }

  @override
  void didUpdateWidget(covariant StatementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPartyId != widget.initialPartyId) {
      setState(() {
        _selectedPartyId = widget.initialPartyId;
        if (widget.initialPartyId != null) {
          _isGeneralLedger = false;
        }
      });
    }
  }

  (DateTime, DateTime) _calculateDatesForPreset(String preset) {
    final now = DateTime.now();
    if (preset == 'thisMonth') {
      return (
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0),
      );
    } else if (preset == 'lastMonth') {
      return (
        DateTime(now.year, now.month - 1, 1),
        DateTime(now.year, now.month, 0),
      );
    } else if (preset == 'thisYear') {
      return (DateTime(now.year, 1, 1), DateTime(now.year, 12, 31));
    }
    return (
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    );
  }

  void _applyPreset(String preset) {
    final (from, to) = _calculateDatesForPreset(preset);
    setState(() {
      _datePreset = preset;
      _fromDate = from;
      _toDate = to;
    });
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesListProvider(null));
    final stmtRepo = ref.read(statementRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 16,
              spacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isGeneralLedger ? 'General Ledger' : 'Party Statement',
                      style: AppTypography.headingLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isGeneralLedger
                          ? 'Complete chronological book of all shop accounts'
                          : 'Comprehensive ledger statement with chronological running balance',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mute,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Party Statement'),
                      selected: !_isGeneralLedger,
                      showCheckmark: false,
                      onSelected: (v) =>
                          setState(() => _isGeneralLedger = false),
                    ),
                    ChoiceChip(
                      label: const Text('General Ledger'),
                      selected: _isGeneralLedger,
                      showCheckmark: false,
                      onSelected: (v) =>
                          setState(() => _isGeneralLedger = true),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Controls Bar (Party Picker + Date Range + Action buttons)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Party Dropdown (when not general ledger)
                  if (!_isGeneralLedger)
                    SizedBox(
                      width: 250,
                      child: partiesAsync.when(
                        data: (parties) {
                          if (_selectedPartyId == null && parties.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(
                                  () =>
                                      _selectedPartyId = parties.first.party.id,
                                );
                              }
                            });
                          }
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _selectedPartyId,
                            decoration: const InputDecoration(
                              labelText: 'Select Party',
                            ),
                            items: parties.map((p) {
                              return DropdownMenuItem(
                                value: p.party.id,
                                child: Text(
                                  '${p.party.name} (${p.party.type.toUpperCase()})',
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedPartyId = val),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ),

                  // Date Presets
                  ChoiceChip(
                    label: const Text('This Month'),
                    selected: _datePreset == 'thisMonth',
                    showCheckmark: false,
                    onSelected: (_) => _applyPreset('thisMonth'),
                  ),
                  ChoiceChip(
                    label: const Text('Last Month'),
                    selected: _datePreset == 'lastMonth',
                    showCheckmark: false,
                    onSelected: (_) => _applyPreset('lastMonth'),
                  ),
                  ChoiceChip(
                    label: const Text('This Year'),
                    selected: _datePreset == 'thisYear',
                    showCheckmark: false,
                    onSelected: (_) => _applyPreset('thisYear'),
                  ),

                  // Custom Date Range Pickers
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fromDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _fromDate = picked;
                          _datePreset = 'custom';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.hairline),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.mute,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppFormatters.formatInputDate(_fromDate),
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text('to', style: AppTypography.bodySmall),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _toDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _toDate = picked;
                          _datePreset = 'custom';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.hairline),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.mute,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppFormatters.formatInputDate(_toDate),
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Print and PDF buttons
                  AppButton(
                    label: 'Print',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.print_outlined,
                    isLoading: _isGeneratingPdf,
                    onPressed: () => _handlePrintOrSave(isPrint: true),
                  ),
                  AppButton(
                    label: 'Save PDF',
                    variant: AppButtonVariant.primary,
                    icon: Icons.download_outlined,
                    isLoading: _isGeneratingPdf,
                    onPressed: () => _handlePrintOrSave(isPrint: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statement View
            Expanded(
              child: _isGeneralLedger
                  ? _buildGeneralLedgerView(stmtRepo)
                  : _buildPartyStatementView(stmtRepo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyStatementView(StatementRepository stmtRepo) {
    if (_selectedPartyId == null) {
      return const Center(child: Text('Select a party to view statement'));
    }

    return FutureBuilder<PartyStatementData>(
      future: stmtRepo.getPartyStatement(
        partyId: _selectedPartyId!,
        fromDate: _fromDate,
        toDate: _toDate,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stmt = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                // Table Header
                Container(
                  color: AppColors.hairlineSoft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('DATE', style: AppTypography.monoEyebrow),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('TYPE', style: AppTypography.monoEyebrow),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'REFERENCE / NOTE',
                          style: AppTypography.monoEyebrow,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'DEBIT',
                            style: AppTypography.monoEyebrow,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'CREDIT',
                            style: AppTypography.monoEyebrow,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'RUNNING BALANCE',
                            style: AppTypography.monoEyebrow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.hairline),

                // Table Rows
                Expanded(
                  child: stmt.rows.isEmpty
                      ? const Center(
                          child: Text('No transactions in this date range'),
                        )
                      : ListView.separated(
                          itemCount: stmt.rows.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: AppColors.hairline,
                          ),
                          itemBuilder: (context, index) {
                            final row = stmt.rows[index];
                            final isBf = row.isBroughtForward;

                            return Container(
                              color: isBf
                                  ? AppColors.hairlineSoft.withValues(
                                      alpha: 0.3,
                                    )
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      isBf
                                          ? '-'
                                          : AppFormatters.formatDate(row.date),
                                      style: isBf
                                          ? AppTypography.label.copyWith(
                                              fontStyle: FontStyle.italic,
                                            )
                                          : AppTypography.bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      row.typeLabel,
                                      style: isBf
                                          ? AppTypography.label
                                          : AppTypography.bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      row.referenceNo ??
                                          (row.description ?? '-'),
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.mute,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        row.debit > 0
                                            ? AppFormatters.formatCurrency(
                                                row.debit,
                                              )
                                            : '-',
                                        style: AppTypography.codeMono,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        row.credit > 0
                                            ? AppFormatters.formatCurrency(
                                                row.credit,
                                              )
                                            : '-',
                                        style: AppTypography.codeMono,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: BalanceBadge(
                                        balance: row.runningBalance,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const Divider(height: 1, color: AppColors.hairline),
                // Summary Footer
                Container(
                  color: AppColors.hairlineSoft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Period Debits: ',
                            style: AppTypography.bodySmall,
                          ),
                          Text(
                            AppFormatters.formatCurrency(stmt.totalDebit),
                            style: AppTypography.label,
                          ),
                          const SizedBox(width: 24),
                          Text(
                            'Period Credits: ',
                            style: AppTypography.bodySmall,
                          ),
                          Text(
                            AppFormatters.formatCurrency(stmt.totalCredit),
                            style: AppTypography.label,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Closing Balance:  ',
                            style: AppTypography.label,
                          ),
                          BalanceBadge(
                            balance: stmt.closingBalance,
                            forceDecimals: true,
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
      },
    );
  }

  Widget _buildGeneralLedgerView(StatementRepository stmtRepo) {
    return FutureBuilder<GeneralLedgerData>(
      future: stmtRepo.getGeneralLedger(fromDate: _fromDate, toDate: _toDate),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final gl = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                // Header
                Container(
                  color: AppColors.hairlineSoft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('DATE', style: AppTypography.monoEyebrow),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('PARTY', style: AppTypography.monoEyebrow),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('TYPE', style: AppTypography.monoEyebrow),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('REF', style: AppTypography.monoEyebrow),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'DEBIT',
                            style: AppTypography.monoEyebrow,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'CREDIT',
                            style: AppTypography.monoEyebrow,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'BALANCE',
                            style: AppTypography.monoEyebrow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.hairline),

                // Data Rows
                Expanded(
                  child: gl.rows.isEmpty
                      ? const Center(
                          child: Text('No transactions in this period'),
                        )
                      : ListView.separated(
                          itemCount: gl.rows.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: AppColors.hairline,
                          ),
                          itemBuilder: (context, index) {
                            final row = gl.rows[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      AppFormatters.formatDate(row.date),
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      row.partyName,
                                      style: AppTypography.label,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      row.typeLabel,
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      row.referenceNo ?? '-',
                                      style: AppTypography.codeMono.copyWith(
                                        fontSize: 12,
                                        color: AppColors.mute,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        row.debit > 0
                                            ? AppFormatters.formatCurrency(
                                                row.debit,
                                              )
                                            : '-',
                                        style: AppTypography.codeMono,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        row.credit > 0
                                            ? AppFormatters.formatCurrency(
                                                row.credit,
                                              )
                                            : '-',
                                        style: AppTypography.codeMono,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: BalanceBadge(
                                        balance: row.runningBalance,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const Divider(height: 1, color: AppColors.hairline),
                // Footer
                Container(
                  color: AppColors.hairlineSoft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Debits: ',
                            style: AppTypography.bodySmall,
                          ),
                          Text(
                            AppFormatters.formatCurrency(gl.totalDebit),
                            style: AppTypography.label,
                          ),
                          const SizedBox(width: 24),
                          Text(
                            'Total Credits: ',
                            style: AppTypography.bodySmall,
                          ),
                          Text(
                            AppFormatters.formatCurrency(gl.totalCredit),
                            style: AppTypography.label,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Net Closing Balance:  ',
                            style: AppTypography.label,
                          ),
                          BalanceBadge(
                            balance: gl.closingBalance,
                            forceDecimals: true,
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
      },
    );
  }

  Future<void> _handlePrintOrSave({required bool isPrint}) async {
    if (_selectedPartyId == null && !_isGeneralLedger) return;

    setState(() => _isGeneratingPdf = true);
    final shop = await ref.read(settingsRepositoryProvider).getSettings();
    final stmtRepo = ref.read(statementRepositoryProvider);

    try {
      if (!_isGeneralLedger) {
        final statement = await stmtRepo.getPartyStatement(
          partyId: _selectedPartyId!,
          fromDate: _fromDate,
          toDate: _toDate,
        );

        final pdfBytes = await PdfGeneratorService.generateStatementPdf(
          shop: shop,
          statement: statement,
        );

        final docName =
            'Statement_${statement.partyName}_${AppFormatters.formatFileDate(_fromDate)}.pdf';
        if (isPrint) {
          await PrintingService.printPdfBytes(pdfBytes, docName: docName);
        } else {
          final savedPath = await PrintingService.savePdfToFile(
            pdfBytes,
            suggestedFileName: docName,
          );
          if (savedPath != null && mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Saved PDF to $savedPath')));
          }
        }
      } else {
        final gl = await stmtRepo.getGeneralLedger(
          fromDate: _fromDate,
          toDate: _toDate,
        );

        final pdfBytes = await PdfGeneratorService.generateGeneralLedgerPdf(
          shop: shop,
          ledger: gl,
        );

        final docName =
            'General_Ledger_${AppFormatters.formatFileDate(_fromDate)}.pdf';
        if (isPrint) {
          await PrintingService.printPdfBytes(pdfBytes, docName: docName);
        } else {
          final savedPath = await PrintingService.savePdfToFile(
            pdfBytes,
            suggestedFileName: docName,
          );
          if (savedPath != null && mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Saved PDF to $savedPath')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }
}
