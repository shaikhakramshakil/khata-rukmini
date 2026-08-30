import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/whatsapp_icon.dart';
import 'party_form_dialog.dart';
import 'whatsapp_reminder_dialog.dart';

class PartyListScreen extends ConsumerStatefulWidget {
  final String partyType; // 'customer' or 'supplier'
  final Function(String partyId) onSelectParty;
  final Function(String partyId)? onOpenStatement;

  const PartyListScreen({
    super.key,
    required this.partyType,
    required this.onSelectParty,
    this.onOpenStatement,
  });

  @override
  ConsumerState<PartyListScreen> createState() => _PartyListScreenState();
}

class _PartyListScreenState extends ConsumerState<PartyListScreen> {
  final _searchController = TextEditingController();
  String _filterQuery = '';
  bool _filterPendingOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesListProvider(widget.partyType));
    final isCustomer = widget.partyType == 'customer';
    final title = isCustomer ? 'Customers' : 'Suppliers';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.headingLarge),
                    const SizedBox(height: 4),
                    Text(
                      isCustomer
                          ? 'Manage customer ledger and receivables'
                          : 'Manage suppliers and payables',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mute,
                      ),
                    ),
                  ],
                ),
                AppButton(
                  label: 'Add ${isCustomer ? 'Customer' : 'Supplier'}',
                  icon: Icons.add,
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (ctx) =>
                          PartyFormDialog(defaultType: widget.partyType),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search & Filter Wrap
            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 360,
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Filter by name, phone, or address...',
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
                    onChanged: (val) =>
                        setState(() => _filterQuery = val.trim().toLowerCase()),
                  ),
                ),
                if (isCustomer) ...[
                  partiesAsync.maybeWhen(
                    data: (parties) {
                      final pendingCount = parties
                          .where((p) => p.currentBalance > 0.0001)
                          .length;
                      return FilterChip(
                        label: Text('Pending Dues ($pendingCount)'),
                        selected: _filterPendingOnly,
                        showCheckmark: false,
                        avatar: const WhatsAppIcon(size: 14),
                        onSelected: (val) =>
                            setState(() => _filterPendingOnly = val),
                        backgroundColor: AppColors.hairlineSoft,
                        selectedColor: AppColors.badgeDrBg,
                        labelStyle: AppTypography.label.copyWith(
                          color: _filterPendingOnly
                              ? AppColors.badgeDrText
                              : AppColors.mute,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color: _filterPendingOnly
                                ? AppColors.badgeDrText.withValues(alpha: 0.3)
                                : AppColors.hairline,
                          ),
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Table Content
            Expanded(
              child: partiesAsync.when(
                data: (parties) {
                  final filtered = parties.where((p) {
                    if (_filterPendingOnly && p.currentBalance <= 0.0001) {
                      return false;
                    }
                    if (_filterQuery.isEmpty) return true;
                    final name = p.party.name.toLowerCase();
                    final phone = p.party.phone?.toLowerCase() ?? '';
                    final address = p.party.address?.toLowerCase() ?? '';
                    return name.contains(_filterQuery) ||
                        phone.contains(_filterQuery) ||
                        address.contains(_filterQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                      title: _filterPendingOnly
                          ? 'No pending dues'
                          : 'No ${title.toLowerCase()} found',
                      description: _filterPendingOnly
                          ? 'All customers have cleared their balances!'
                          : (_filterQuery.isNotEmpty
                                ? 'No matching results for "$_filterQuery".'
                                : 'You haven\'t added any ${title.toLowerCase()} yet.'),
                      actionLabel: _filterQuery.isEmpty && !_filterPendingOnly
                          ? '+ Add ${isCustomer ? 'Customer' : 'Supplier'}'
                          : null,
                      onAction: () async {
                        await showDialog(
                          context: context,
                          builder: (ctx) =>
                              PartyFormDialog(defaultType: widget.partyType),
                        );
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
                                  flex: 3,
                                  child: Text(
                                    'NAME',
                                    style: AppTypography.monoEyebrow,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'PHONE',
                                    style: AppTypography.monoEyebrow,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'ADDRESS',
                                    style: AppTypography.monoEyebrow,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'LAST ACTIVITY',
                                    style: AppTypography.monoEyebrow,
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
                                const SizedBox(
                                  width: 116,
                                ), // Action column spacer
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.hairline),

                          // Table Rows
                          Expanded(
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                color: AppColors.hairline,
                              ),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final p = item.party;

                                return InkWell(
                                  onTap: () => widget.onSelectParty(p.id),
                                  hoverColor: AppColors.hairlineSoft.withValues(
                                    alpha: 0.5,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  p.name,
                                                  style: AppTypography.label,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              if (p.type == 'both') ...[
                                                const SizedBox(width: 6),
                                                const TypeBadge(label: 'Both'),
                                              ],
                                              if (p.interestRate != null) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 1.5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.hairlineSoft,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.hairline,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${p.interestRate}%/mo',
                                                    style: AppTypography
                                                        .codeMono
                                                        .copyWith(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColors.ink,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            p.phone ?? '-',
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                                  color: AppColors.mute,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            p.address ?? '-',
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                                  color: AppColors.mute,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item.lastTransactionDate != null
                                                ? AppFormatters.formatShortDate(
                                                    item.lastTransactionDate!,
                                                  )
                                                : '-',
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                                  color: AppColors.mute,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: BalanceBadge(
                                              balance: item.currentBalance,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 116,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              if (isCustomer)
                                                IconButton(
                                                  icon: WhatsAppIcon(
                                                    size: 18,
                                                    color:
                                                        item.currentBalance >
                                                            0.0001
                                                        ? const Color(
                                                            0xFF25D366,
                                                          )
                                                        : AppColors.mute,
                                                  ),
                                                  tooltip:
                                                      item.currentBalance >
                                                          0.0001
                                                      ? 'WhatsApp Reminder (Pending: ${AppFormatters.formatCurrency(item.currentBalance)})'
                                                      : 'Send WhatsApp Message',
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) =>
                                                          WhatsAppReminderDialog(
                                                            party: p,
                                                            balance: item
                                                                .currentBalance,
                                                          ),
                                                    );
                                                  },
                                                ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.receipt_outlined,
                                                  size: 18,
                                                  color: AppColors.mute,
                                                ),
                                                tooltip: 'Statement',
                                                onPressed: () => widget
                                                    .onOpenStatement
                                                    ?.call(p.id),
                                              ),
                                              const Icon(
                                                Icons.chevron_right,
                                                size: 18,
                                                color: AppColors.mute,
                                              ),
                                            ],
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
