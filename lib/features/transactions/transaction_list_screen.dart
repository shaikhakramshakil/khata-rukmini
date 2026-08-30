import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_badge.dart';
import 'transaction_detail_dialog.dart';
import 'transaction_form_dialog.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _searchController = TextEditingController();
  String _filterQuery = '';
  String _typeFilter = 'all';
  bool _showRecycleBin = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txnRepo = ref.read(transactionRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showRecycleBin
                          ? 'Recycle Bin (Deleted)'
                          : 'Transactions',
                      style: AppTypography.headingLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _showRecycleBin
                          ? 'Review or restore deleted transaction entries'
                          : 'Complete chronological history of all debit and credit entries',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mute,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Recycle Bin Toggle
                    AppButton(
                      label: _showRecycleBin
                          ? 'View Active Transactions'
                          : 'Recycle Bin',
                      variant: AppButtonVariant.secondary,
                      icon: _showRecycleBin ? Icons.list : Icons.delete_outline,
                      onPressed: () =>
                          setState(() => _showRecycleBin = !_showRecycleBin),
                    ),
                    const SizedBox(width: 12),
                    if (!_showRecycleBin)
                      AppButton(
                        label: 'New Transaction',
                        icon: Icons.add,
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) => const TransactionFormDialog(),
                          );
                          if (mounted) setState(() {});
                        },
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Bar
            if (!_showRecycleBin) ...[
              Row(
                children: [
                  SizedBox(
                    width: 320,
                    height: 38,
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Filter by Txn #, description, ref...',
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.mute,
                        ),
                        suffixIcon: _filterQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _filterQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) => setState(
                        () => _filterQuery = val.trim().toLowerCase(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _typeFilter,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Types')),
                      DropdownMenuItem(value: 'sale', child: Text('Sales')),
                      DropdownMenuItem(
                        value: 'paymentReceived',
                        child: Text('Payments Received'),
                      ),
                      DropdownMenuItem(
                        value: 'purchase',
                        child: Text('Purchases'),
                      ),
                      DropdownMenuItem(
                        value: 'paymentMade',
                        child: Text('Payments Made'),
                      ),
                      DropdownMenuItem(
                        value: 'debitAdjustment',
                        child: Text('Debit Adjustments'),
                      ),
                      DropdownMenuItem(
                        value: 'creditAdjustment',
                        child: Text('Credit Adjustments'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _typeFilter = v ?? 'all'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Content Table
            Expanded(
              child: FutureBuilder<List<TransactionWithParty>>(
                future: _showRecycleBin
                    ? txnRepo.getDeletedTransactionsWithParty()
                    : txnRepo.getAllActiveTransactionsWithParty(
                        typeFilter: _typeFilter,
                      ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final txns = snapshot.data!;
                  final filtered = txns.where((t) {
                    if (_filterQuery.isEmpty) return true;
                    final tTxn = t.transaction;
                    final txnNo = tTxn.transactionNo.toLowerCase();
                    final desc = tTxn.description?.toLowerCase() ?? '';
                    final ref = tTxn.referenceNo?.toLowerCase() ?? '';
                    return txnNo.contains(_filterQuery) ||
                        desc.contains(_filterQuery) ||
                        ref.contains(_filterQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                      title: _showRecycleBin
                          ? 'Recycle bin is empty'
                          : 'No transactions recorded',
                      description: _showRecycleBin
                          ? 'Deleted transactions will appear here for recovery.'
                          : 'Click "+ New Transaction" to create your first ledger entry.',
                      actionLabel: !_showRecycleBin ? 'New Transaction' : null,
                      onAction: () async {
                        await showDialog(
                          context: context,
                          builder: (ctx) => const TransactionFormDialog(),
                        );
                        if (mounted) setState(() {});
                      },
                    );
                  }

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
                                  child: Text(
                                    'DATE',
                                    style: AppTypography.monoEyebrow,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'TXN #',
                                    style: AppTypography.monoEyebrow,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'PARTY',
                                    style: AppTypography.monoEyebrow,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'TYPE',
                                    style: AppTypography.monoEyebrow,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'DESCRIPTION',
                                    style: AppTypography.monoEyebrow,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'AMOUNT',
                                      style: AppTypography.monoEyebrow,
                                    ),
                                  ),
                                ),
                                if (_showRecycleBin) const SizedBox(width: 90),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.hairline),

                          // Rows
                          Expanded(
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                color: AppColors.hairline,
                              ),
                              itemBuilder: (context, index) {
                                final txnWithParty = filtered[index];
                                final txn = txnWithParty.transaction;
                                final isDebit = txn.debit > 0;

                                final partyName = txnWithParty.party.name;

                                return InkWell(
                                  onTap: _showRecycleBin
                                      ? null
                                      : () async {
                                          await showDialog(
                                            context: context,
                                            builder: (ctx) =>
                                                TransactionDetailDialog(
                                                  transactionId: txn.id,
                                                ),
                                          );
                                          if (mounted) setState(() {});
                                        },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            AppFormatters.formatDate(txn.date),
                                            style: AppTypography.bodyMedium,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            txn.transactionNo,
                                            style: AppTypography.codeMono
                                                .copyWith(
                                                  fontSize: 12,
                                                  color: AppColors.mute,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            partyName,
                                            style: AppTypography.label,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              TypeBadge(label: txn.type),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            txn.description ??
                                                (txn.referenceNo != null
                                                    ? 'Ref: ${txn.referenceNo}'
                                                    : '-'),
                                            style: AppTypography.bodySmall
                                                .copyWith(
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
                                              '${isDebit ? '+' : '-'}${AppFormatters.formatCurrency(txn.amount)}',
                                              style: AppTypography.codeMono
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: isDebit
                                                        ? AppColors.badgeDrText
                                                        : AppColors.badgeCrText,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        if (_showRecycleBin)
                                          SizedBox(
                                            width: 90,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: AppButton(
                                                label: 'Restore',
                                                variant:
                                                    AppButtonVariant.secondary,
                                                onPressed: () async {
                                                  await txnRepo
                                                      .restoreTransaction(
                                                        txn.id,
                                                      );
                                                  if (mounted) setState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
