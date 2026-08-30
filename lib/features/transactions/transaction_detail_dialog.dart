import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/tables.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/pdf/pdf_generator_service.dart';
import '../../services/pdf/printing_service.dart';
import 'transaction_form_dialog.dart';

class TransactionDetailDialog extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailDialog({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnRepo = ref.read(transactionRepositoryProvider);

    return FutureBuilder<TransactionWithDetails?>(
      future: txnRepo.getTransactionDetails(transactionId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final details = snapshot.data;
        if (details == null) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Transaction not found or deleted'),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        }

        final txn = details.transaction;
        final party = details.party;
        final isSale = txn.type == TransactionType.sale.name;
        final isPayment =
            txn.type == TransactionType.paymentReceived.name ||
            txn.type == TransactionType.paymentMade.name;

        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction ${txn.transactionNo}',
                            style: AppTypography.headingMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppFormatters.formatDateTime(txn.date),
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.mute,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.hairline),
                  const SizedBox(height: 16),

                  _buildDetailRow('Party', party.name),
                  _buildDetailRow('Transaction Type', txn.type.toUpperCase()),
                  _buildDetailRow(
                    'Amount',
                    AppFormatters.formatCurrency(txn.amount),
                    isAmount: true,
                  ),
                  if (txn.interestRate != null)
                    _buildDetailRow(
                      'Interest Rate',
                      '${txn.interestRate}% / month',
                    ),
                  if (txn.paymentMode != null)
                    _buildDetailRow('Payment Mode', txn.paymentMode!),
                  if (txn.referenceNo != null)
                    _buildDetailRow('Reference / Receipt #', txn.referenceNo!),
                  if (details.paymentDetail?.utrNo != null)
                    _buildDetailRow(
                      'UTR Number',
                      details.paymentDetail!.utrNo!,
                    ),
                  if (details.paymentDetail?.bankName != null)
                    _buildDetailRow('Bank', details.paymentDetail!.bankName!),
                  if (txn.description != null)
                    _buildDetailRow('Description', txn.description!),

                  // Itemized list if any
                  if (details.lineItems.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'ITEMIZED BREAKDOWN',
                      style: AppTypography.monoEyebrow,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.hairline),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: details.lineItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.description} (${item.quantity} x ${AppFormatters.formatCurrency(item.rate)})',
                                  style: AppTypography.bodyMedium,
                                ),
                                Text(
                                  AppFormatters.formatCurrency(item.amount),
                                  style: AppTypography.codeMono,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Delete button
                      AppButton(
                        label: 'Delete',
                        variant: AppButtonVariant.danger,
                        icon: Icons.delete_outline,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Transaction?'),
                              content: const Text(
                                'This transaction will be moved to the Recycle Bin and removed from the party balance.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await txnRepo.deleteTransaction(txn.id);
                            if (context.mounted) Navigator.of(context).pop();
                          }
                        },
                      ),

                      Row(
                        children: [
                          if (isPayment || isSale) ...[
                            AppButton(
                              label: isSale ? 'Print Invoice' : 'Print Receipt',
                              variant: AppButtonVariant.secondary,
                              icon: Icons.print_outlined,
                              onPressed: () async {
                                final shop = await ref
                                    .read(settingsRepositoryProvider)
                                    .getSettings();
                                final partyBalance = await ref
                                    .read(databaseProvider)
                                    .getPartyCurrentBalance(party.id);

                                if (isSale) {
                                  final pdfBytes =
                                      await PdfGeneratorService.generateInvoicePdf(
                                        shop: shop,
                                        details: details,
                                        currentPartyBalance: partyBalance,
                                      );
                                  await PrintingService.printPdfBytes(
                                    pdfBytes,
                                    docName: 'Invoice_${txn.transactionNo}.pdf',
                                  );
                                } else {
                                  final prevBal = await txnRepo
                                      .getBalanceBeforeTransaction(
                                        party.id,
                                        txn.id,
                                      );
                                  final pdfBytes =
                                      await PdfGeneratorService.generateReceiptPdf(
                                        shop: shop,
                                        details: details,
                                        previousBalance: prevBal,
                                        newBalance: partyBalance,
                                      );
                                  await PrintingService.printPdfBytes(
                                    pdfBytes,
                                    docName: 'Receipt_${txn.transactionNo}.pdf',
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                          AppButton(
                            label: 'Edit',
                            variant: AppButtonVariant.secondary,
                            icon: Icons.edit_outlined,
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (ctx) => TransactionFormDialog(
                                  editingTransaction: txn,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
          ),
          Text(
            value,
            style: isAmount
                ? AppTypography.headingMedium.copyWith(color: AppColors.ink)
                : AppTypography.label.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
