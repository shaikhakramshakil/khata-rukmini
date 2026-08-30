import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/tables.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/status_badge.dart';
import '../parties/party_form_dialog.dart';
import '../transactions/transaction_detail_dialog.dart';
import '../transactions/transaction_form_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int tabIndex) onNavigateTab;
  final Function(String partyId) onSelectParty;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
    required this.onSelectParty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Welcome Row with Quick Actions
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard', style: AppTypography.headingLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Overview of your shop ledger and outstanding balances',
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
                    AppButton(
                      label: 'Add Customer',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.person_add_outlined,
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (ctx) =>
                              const PartyFormDialog(defaultType: 'customer'),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      label: 'Receive Payment',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.arrow_downward,
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (ctx) => const TransactionFormDialog(
                            preselectedType: TransactionType.paymentReceived,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      label: 'Record Sale',
                      variant: AppButtonVariant.primary,
                      icon: Icons.add,
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (ctx) => const TransactionFormDialog(
                            preselectedType: TransactionType.sale,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            statsAsync.when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Outstanding Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'CUSTOMER OUTSTANDING',
                          value:
                              '${AppFormatters.formatCurrency(stats.customerOutstanding)} Dr',
                          subtitle: '${stats.customerCount} Active Customers',
                          badgeColor: AppColors.badgeDrText,
                          onTap: () => onNavigateTab(1), // Customers tab
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'SUPPLIER OUTSTANDING',
                          value:
                              '${AppFormatters.formatCurrency(stats.supplierOutstanding)} Cr',
                          subtitle: '${stats.supplierCount} Active Suppliers',
                          badgeColor: AppColors.badgeCrText,
                          onTap: () => onNavigateTab(2), // Suppliers tab
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'TODAY\'S ACTIVITY',
                          value: '${stats.todayTxnCount} Transactions',
                          subtitle:
                              'Received: ${AppFormatters.formatCurrency(stats.todayPaymentsReceived)}',
                          badgeColor: AppColors.ink,
                          onTap: () => onNavigateTab(3), // Transactions tab
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: AppTypography.headingMedium,
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab(3),
                        child: const Text('View All Transactions →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Recent Transactions Table
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: stats.recentTransactions.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(36.0),
                              child: Center(
                                child: Text(
                                  'No transactions recorded yet. Click "+ Record Sale" to start.',
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: stats.recentTransactions.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                color: AppColors.hairline,
                              ),
                              itemBuilder: (context, index) {
                                final txnWithParty =
                                    stats.recentTransactions[index];
                                final txn = txnWithParty.transaction;
                                final isDebit = txn.debit > 0;

                                final partyName = txnWithParty.party.name;

                                return InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => TransactionDetailDialog(
                                        transactionId: txn.id,
                                      ),
                                    );
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
                                                (txn.paymentMode != null
                                                    ? 'Mode: ${txn.paymentMode}'
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
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.monoEyebrow),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTypography.headingLarge.copyWith(
                fontSize: 26,
                color: badgeColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}
