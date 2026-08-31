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
import '../transactions/transaction_detail_dialog.dart';
import '../transactions/transaction_form_dialog.dart';
import 'interest_calculator_dialog.dart';
import 'party_form_dialog.dart';
import 'whatsapp_reminder_dialog.dart';

class PartyProfileScreen extends ConsumerStatefulWidget {
  final String partyId;
  final VoidCallback onBack;
  final Function(String partyId)? onOpenStatement;

  const PartyProfileScreen({
    super.key,
    required this.partyId,
    required this.onBack,
    this.onOpenStatement,
  });

  @override
  ConsumerState<PartyProfileScreen> createState() => _PartyProfileScreenState();
}

class _PartyProfileScreenState extends ConsumerState<PartyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final partyId = widget.partyId;
    final onBack = widget.onBack;
    final onOpenStatement = widget.onOpenStatement;

    final profileAsync = ref.watch(partyProfileProvider(partyId));

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(child: Text('Error loading party: $err')),
      ),
      data: (data) {
        final (partyWithBalance, transactions) = data;

        if (partyWithBalance == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Party not found or archived'),
                const SizedBox(height: 12),
                AppButton(label: 'Go Back', onPressed: onBack),
              ],
            ),
          );
        }

        final party = partyWithBalance.party;
        final balance = partyWithBalance.currentBalance;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top navigation & actions
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppColors.ink,
                      ),
                      onPressed: onBack,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        party.name,
                        style: AppTypography.headingLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TypeBadge(label: party.type),
                    const Spacer(),
                    AppButton(
                      label: 'Edit Party',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.edit_outlined,
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (ctx) =>
                              PartyFormDialog(editingParty: party),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Party Info and Balance Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Contact info
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (party.phone != null) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    size: 16,
                                    color: AppColors.mute,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    party.phone!,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                            if (party.address != null) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.mute,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    party.address!,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                            if (party.interestRate != null) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.percent,
                                    size: 15,
                                    color: AppColors.ink,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Interest Rate: ${party.interestRate}% / month',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                            if (party.notes != null)
                              Text(
                                'Notes: ${party.notes}',
                                style: AppTypography.bodySmall,
                              ),
                          ],
                        ),
                      ),

                      // Balance Highlight Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.hairlineSoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'CURRENT BALANCE',
                              style: AppTypography.monoEyebrow,
                            ),
                            const SizedBox(height: 4),
                            BalanceBadge(balance: balance, forceDecimals: true),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Quick Action Buttons
                      Column(
                        children: [
                          AppButton(
                            label: 'Add Transaction',
                            icon: Icons.add,
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (ctx) => TransactionFormDialog(
                                  preselectedPartyId: party.id,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            label: 'Calculate Interest',
                            variant: AppButtonVariant.secondary,
                            icon: Icons.percent,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => InterestCalculatorDialog(
                                  party: party,
                                  currentBalance: balance,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            label: 'Full Statement',
                            variant: AppButtonVariant.secondary,
                            icon: Icons.receipt_long_outlined,
                            onPressed: () {
                              onOpenStatement?.call(party.id);
                            },
                          ),
                          if (party.type == 'customer' ||
                              party.type == 'both' ||
                              balance > 0.0001) ...[
                            const SizedBox(height: 8),
                            AppButton(
                              label: 'WhatsApp Reminder',
                              variant: AppButtonVariant.secondary,
                              customIcon: const WhatsAppIcon(size: 16),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => WhatsAppReminderDialog(
                                    party: party,
                                    balance: balance,
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: AppTypography.headingMedium,
                    ),
                    Text(
                      '${transactions.length} records',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Transactions List / Table
                Expanded(
                  child: transactions.isEmpty
                      ? EmptyState(
                          title: 'No transactions yet',
                          description:
                              'Record your first sale, payment, or purchase for ${party.name}.',
                          actionLabel: 'Add Transaction',
                          onAction: () async {
                            await showDialog(
                              context: context,
                              builder: (ctx) => TransactionFormDialog(
                                preselectedPartyId: party.id,
                              ),
                            );
                            if (mounted) setState(() {});
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ListView.separated(
                              itemCount: transactions.length,
                              separatorBuilder: (_, _) => const Divider(
                                color: AppColors.hairline,
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final txn = transactions[index];
                                final isDebit = txn.debit > 0;

                                return ListTile(
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (ctx) => TransactionDetailDialog(
                                        transactionId: txn.id,
                                      ),
                                    );
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        AppFormatters.formatDate(txn.date),
                                        style: AppTypography.bodyMedium,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        txn.transactionNo,
                                        style: AppTypography.codeMono.copyWith(
                                          fontSize: 12,
                                          color: AppColors.mute,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      TypeBadge(label: txn.type),
                                      if (txn.paymentMode != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${txn.paymentMode})',
                                          style: AppTypography.bodySmall,
                                        ),
                                      ],
                                      if (txn.description != null) ...[
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            txn.description!,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color: AppColors.body,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Text(
                                    '${isDebit ? '+' : '-'}${AppFormatters.formatCurrency(txn.amount)}',
                                    style: AppTypography.codeMono.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDebit
                                          ? AppColors.badgeDrText
                                          : AppColors.badgeCrText,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
