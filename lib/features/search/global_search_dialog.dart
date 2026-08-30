import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/status_badge.dart';

class GlobalSearchDialog extends ConsumerStatefulWidget {
  final Function(Party party)? onSelectParty;
  final Function(TransactionEntry txn)? onSelectTransaction;

  const GlobalSearchDialog({
    super.key,
    this.onSelectParty,
    this.onSelectTransaction,
  });

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<Party> _partyResults = [];
  List<TransactionEntry> _txnResults = [];
  List<PaymentDetail> _paymentResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        if (mounted) {
          setState(() {
            _partyResults = [];
            _txnResults = [];
            _paymentResults = [];
            _isSearching = false;
          });
        }
        return;
      }

      if (mounted) setState(() => _isSearching = true);
      final db = ref.read(databaseProvider);

      final parties = await db.searchParties(query);
      final txns = await db.searchTransactions(query);
      final payments = await db.searchPaymentDetails(query);

      if (mounted) {
        setState(() {
          _partyResults = parties;
          _txnResults = txns;
          _paymentResults = payments;
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasResults =
        _partyResults.isNotEmpty ||
        _txnResults.isNotEmpty ||
        _paymentResults.isNotEmpty;

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(
        top: 80,
        left: 24,
        right: 24,
        bottom: 40,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 580),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Input Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.hairline)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: AppColors.mute),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Search people, phone, transaction #, UTR, cheque...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.faint,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_isSearching)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.hairlineSoft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ESC',
                        style: AppTypography.codeMono.copyWith(
                          fontSize: 10,
                          color: AppColors.mute,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Search Results Body
            Expanded(
              child: _searchController.text.trim().isEmpty
                  ? Center(
                      child: Text(
                        'Type to search across parties, amounts, and payment references',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.faint,
                        ),
                      ),
                    )
                  : !hasResults && !_isSearching
                  ? Center(
                      child: Text(
                        'No results found for "${_searchController.text}"',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mute,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        if (_partyResults.isNotEmpty) ...[
                          _buildSectionHeader(
                            'PEOPLE / PARTIES (${_partyResults.length})',
                          ),
                          ..._partyResults.map((p) => _buildPartyRow(p)),
                        ],
                        if (_txnResults.isNotEmpty) ...[
                          _buildSectionHeader(
                            'TRANSACTIONS (${_txnResults.length})',
                          ),
                          ..._txnResults.map((t) => _buildTxnRow(t)),
                        ],
                        if (_paymentResults.isNotEmpty) ...[
                          _buildSectionHeader(
                            'PAYMENTS / REFERENCES (${_paymentResults.length})',
                          ),
                          ..._paymentResults.map((pm) => _buildPaymentRow(pm)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(title, style: AppTypography.monoEyebrow),
    );
  }

  Widget _buildPartyRow(Party party) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Row(
        children: [
          Text(party.name, style: AppTypography.label),
          const SizedBox(width: 8),
          TypeBadge(label: party.type),
        ],
      ),
      subtitle: party.phone != null
          ? Text(party.phone!, style: AppTypography.bodySmall)
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppColors.mute,
      ),
      onTap: () {
        Navigator.of(context).pop();
        widget.onSelectParty?.call(party);
      },
    );
  }

  Widget _buildTxnRow(TransactionEntry txn) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${txn.transactionNo} • ${txn.type}',
            style: AppTypography.label,
          ),
          Text(
            AppFormatters.formatCurrency(txn.amount),
            style: AppTypography.codeMono.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      subtitle: Text(
        '${AppFormatters.formatDate(txn.date)}${txn.description != null ? ' • ${txn.description}' : ''}',
        style: AppTypography.bodySmall,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppColors.mute,
      ),
      onTap: () {
        Navigator.of(context).pop();
        widget.onSelectTransaction?.call(txn);
      },
    );
  }

  Widget _buildPaymentRow(PaymentDetail payment) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        '${payment.paymentMode ?? 'Payment'}: ${payment.referenceNo ?? payment.utrNo ?? payment.chequeNo ?? '-'}',
        style: AppTypography.label,
      ),
      subtitle: Text(
        payment.bankName != null
            ? 'Bank: ${payment.bankName}'
            : 'Ref: ${payment.transactionId}',
        style: AppTypography.bodySmall,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 18,
        color: AppColors.mute,
      ),
      onTap: () async {
        Navigator.of(context).pop();
        final db = ref.read(databaseProvider);
        final txn = await db.getTransactionById(payment.transactionId);
        if (txn != null) {
          widget.onSelectTransaction?.call(txn);
        }
      },
    );
  }
}
