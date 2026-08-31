import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/tables.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/pdf/pdf_generator_service.dart';
import '../../services/pdf/printing_service.dart';
import '../parties/party_form_dialog.dart';

class TransactionFormDialog extends ConsumerStatefulWidget {
  final String? preselectedPartyId;
  final TransactionType? preselectedType;
  final TransactionEntry? editingTransaction;

  const TransactionFormDialog({
    super.key,
    this.preselectedPartyId,
    this.preselectedType,
    this.editingTransaction,
  });

  @override
  ConsumerState<TransactionFormDialog> createState() =>
      _TransactionFormDialogState();
}

class _TransactionFormDialogState extends ConsumerState<TransactionFormDialog> {
  static const List<String> _jewelryProducts = [
    'Mini Pot',
    'Long Pot',
    'Jhumar',
    'Necklace',
    'Sankal Tops',
    'Huzur',
    'Kudka',
    'Vel',
    'V Bali',
    'J Tops',
    'Ladies Ring',
    'Gents Ring',
    'Sui Dhaga',
    'Earring',
    'Thushi',
    'Ekdani',
    'Dorla',
    'Sankal',
    'Paddle',
    'Mani',
    'Pohe Haar',
    'Mohan Maal',
    'Bracelet',
    'Fancy Tops',
    'Mini Dorla',
    'Bachkani Ring',
    'Om Paddle',
    'Bugadi',
    'Heart Paddle',
    'Machine Mani',
  ];

  final _formKey = GlobalKey<FormState>();

  String? _selectedPartyId;
  late TransactionType _selectedType;
  late DateTime _selectedDate;
  late TextEditingController _amountController;
  late TextEditingController _refController;
  late TextEditingController _descController;
  final _interestRateController = TextEditingController();
  String _selectedPaymentMode = 'Cash';

  // Optional Payment Details
  final _utrController = TextEditingController();
  final _bankController = TextEditingController();
  final _chequeController = TextEditingController();

  // Integrated Upfront Payment on Sale
  bool _hasUpfrontPayment = false;
  final _upfrontAmountController = TextEditingController();
  String _upfrontPaymentMode = 'Cash';
  final _upfrontRefController = TextEditingController();

  // Line items (Mandatory visible)
  final List<Map<String, dynamic>> _lineItems = [
    {'description': '', 'quantity': 1, 'unit': 'PCS', 'rate': 0, 'amount': 0},
  ];

  bool _isLoading = false;

  final List<String> _paymentModes = [
    'Cash',
    'UPI',
    'Bank Transfer',
    'Cheque',
    'Card',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final txn = widget.editingTransaction;
    _selectedPartyId = widget.preselectedPartyId ?? txn?.partyId;
    _selectedType =
        widget.preselectedType ??
        (txn != null
            ? TransactionType.values.firstWhere(
                (t) => t.name == txn.type,
                orElse: () => TransactionType.sale,
              )
            : TransactionType.sale);
    _selectedDate = txn?.date ?? DateTime.now();
    _amountController = TextEditingController(
      text: txn != null ? txn.amount.toString() : '',
    );
    _refController = TextEditingController(text: txn?.referenceNo ?? '');
    _descController = TextEditingController(text: txn?.description ?? '');
    if (txn?.interestRate != null) {
      _interestRateController.text = txn!.interestRate.toString();
    }
    if (txn?.paymentMode != null && _paymentModes.contains(txn!.paymentMode)) {
      _selectedPaymentMode = txn.paymentMode!;
    }

    // Load existing payment details and line items when editing
    if (txn != null) {
      _loadExistingDetails(txn.id);
    }
  }

  Future<void> _loadExistingDetails(String transactionId) async {
    final db = ref.read(databaseProvider);

    // Load payment details
    final pd = await db.getPaymentDetailForTransaction(transactionId);
    if (pd != null && mounted) {
      setState(() {
        _utrController.text = pd.utrNo ?? '';
        _bankController.text = pd.bankName ?? '';
        _chequeController.text = pd.chequeNo ?? '';
      });
    }

    // Load line items
    final items = await db.getLineItemsForTransaction(transactionId);
    if (items.isNotEmpty && mounted) {
      setState(() {
        _lineItems.clear();
        for (final item in items) {
          _lineItems.add({
            'description': item.description,
            'quantity': item.quantity,
            'unit': item.unit ?? 'PCS',
            'rate': item.rate,
            'amount': item.amount,
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _descController.dispose();
    _interestRateController.dispose();
    _utrController.dispose();
    _bankController.dispose();
    _chequeController.dispose();
    _upfrontAmountController.dispose();
    _upfrontRefController.dispose();
    super.dispose();
  }

  void _recalculateAmountFromLineItems() {
    if (_lineItems.isNotEmpty) {
      double total = 0.0;
      for (final item in _lineItems) {
        total += (item['amount'] as num?)?.toDouble() ?? 0.0;
      }
      _amountController.text = total.toInt().toString();
    }
  }

  void _addLineItem() {
    setState(() {
      _lineItems.add({
        'description': '',
        'quantity': 1.0,
        'unit': 'PCS',
        'rate': 0.0,
        'amount': 0.0,
      });
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
      _recalculateAmountFromLineItems();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPartyId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a party')));
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(transactionRepositoryProvider);
    final interestRate = double.tryParse(_interestRateController.text.trim());

    try {
      TransactionWithDetails? resultTxn;

      if (widget.editingTransaction != null) {
        await repo.updateTransactionDetails(
          id: widget.editingTransaction!.id,
          date: _selectedDate,
          amount: amount,
          interestRate: interestRate,
          paymentMode: _selectedPaymentMode,
          referenceNo: _refController.text,
          description: _descController.text,
          lineItems: _lineItems.where((i) => i['description'] != '').toList(),
          paymentDetails: {
            'referenceNo': _refController.text.trim().isNotEmpty
                ? _refController.text.trim()
                : null,
            'utrNo': _utrController.text.trim().isNotEmpty
                ? _utrController.text.trim()
                : null,
            'bankName': _bankController.text.trim().isNotEmpty
                ? _bankController.text.trim()
                : null,
            'chequeNo': _chequeController.text.trim().isNotEmpty
                ? _chequeController.text.trim()
                : null,
          },
        );
        resultTxn = await repo.getTransactionDetails(
          widget.editingTransaction!.id,
        );
      } else {
        double? upfrontPaid;
        if (_hasUpfrontPayment && _selectedType == TransactionType.sale) {
          upfrontPaid = double.tryParse(_upfrontAmountController.text.trim());
          if (upfrontPaid != null && upfrontPaid > amount) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Upfront payment cannot exceed the sale amount'),
              ),
            );
            setState(() => _isLoading = false);
            return;
          }
        }

        resultTxn = await repo.createTransaction(
          partyId: _selectedPartyId!,
          type: _selectedType,
          date: _selectedDate,
          amount: amount,
          interestRate: interestRate,
          paymentMode: _selectedPaymentMode,
          referenceNo: _refController.text,
          description: _descController.text,
          lineItems: _lineItems.where((i) => i['description'] != '').toList(),
          paymentDetails: {
            'referenceNo': _refController.text.trim().isNotEmpty
                ? _refController.text.trim()
                : null,
            'utrNo': _utrController.text.trim().isNotEmpty
                ? _utrController.text.trim()
                : null,
            'bankName': _bankController.text.trim().isNotEmpty
                ? _bankController.text.trim()
                : null,
            'chequeNo': _chequeController.text.trim().isNotEmpty
                ? _chequeController.text.trim()
                : null,
          },
          upfrontPaidAmount: upfrontPaid,
          upfrontPaymentMode: _upfrontPaymentMode,
          upfrontReferenceNo: _upfrontRefController.text.trim().isNotEmpty
              ? _upfrontRefController.text.trim()
              : null,
        );
      }

      if (!mounted) return;

      if (resultTxn != null) {
        final printChoice = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Transaction Saved'),
            content: const Text(
              'Would you like to print or save the voucher for this transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'close'),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'save'),
                child: const Text('Save as PDF'),
              ),
              AppButton(
                label: 'Print Now',
                icon: Icons.print_outlined,
                onPressed: () => Navigator.pop(ctx, 'print'),
              ),
            ],
          ),
        );

        if (printChoice == 'print' || printChoice == 'save') {
          setState(() => _isLoading = true);
          final shop = await ref.read(settingsRepositoryProvider).getSettings();
          final partyBalance = await ref
              .read(databaseProvider)
              .getPartyCurrentBalance(resultTxn.party.id);

          Uint8List pdfBytes;
          if (resultTxn.transaction.type == 'sale') {
            pdfBytes = await PdfGeneratorService.generateInvoicePdf(
              shop: shop,
              details: resultTxn,
              currentPartyBalance: partyBalance,
            );
          } else {
            final prevBal = await repo.getBalanceBeforeTransaction(
              resultTxn.party.id,
              resultTxn.transaction.id,
            );
            pdfBytes = await PdfGeneratorService.generateReceiptPdf(
              shop: shop,
              details: resultTxn,
              previousBalance: prevBal,
              newBalance: partyBalance,
            );
          }

          final fileName = '${resultTxn.transaction.transactionNo}.pdf';
          if (printChoice == 'print') {
            await PrintingService.printPdfBytes(pdfBytes, docName: fileName);
          } else if (printChoice == 'save') {
            await PrintingService.savePdfToFile(
              pdfBytes,
              suggestedFileName: fileName,
            );
          }
        }
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesListProvider(null));
    final isEditing = widget.editingTransaction != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Transaction' : 'Record Transaction',
                      style: AppTypography.headingMedium,
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

                // Party Selector
                partiesAsync.when(
                  data: (parties) => Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedPartyId,
                          decoration: const InputDecoration(
                            labelText: 'Party *',
                          ),
                          items: parties.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.party.id,
                              child: Text(
                                '${p.party.name} (${p.party.type.toUpperCase()})',
                              ),
                            );
                          }).toList(),
                          onChanged:
                              isEditing || widget.preselectedPartyId != null
                              ? null
                              : (val) => setState(() => _selectedPartyId = val),
                          validator: (v) =>
                              v == null ? 'Please select a party' : null,
                        ),
                      ),
                      if (!isEditing && widget.preselectedPartyId == null) ...[
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.person_add_alt_1, size: 20),
                          tooltip: 'Add New Customer / Supplier',
                          onPressed: () async {
                            final res = await showDialog(
                              context: context,
                              builder: (ctx) => const PartyFormDialog(
                                defaultType: 'customer',
                              ),
                            );
                            if (res == true) {}
                          },
                        ),
                      ],
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading parties: $e'),
                ),
                const SizedBox(height: 14),

                // Type & Date Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<TransactionType>(
                        isExpanded: true,
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Transaction Type *',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: TransactionType.sale,
                            child: Text('Sale (Debit)'),
                          ),
                          const DropdownMenuItem(
                            value: TransactionType.paymentReceived,
                            child: Text('Payment Received (Credit)'),
                          ),
                          const DropdownMenuItem(
                            value: TransactionType.purchase,
                            child: Text('Purchase (Credit)'),
                          ),
                          const DropdownMenuItem(
                            value: TransactionType.paymentMade,
                            child: Text('Payment Made (Debit)'),
                          ),
                          const DropdownMenuItem(
                            value: TransactionType.loanGiven,
                            child: Text('Loan Given (Debit)'),
                          ),
                          const DropdownMenuItem(
                            value: TransactionType.interestCharged,
                            child: Text('Interest Charged (Debit)'),
                          ),
                          const DropdownMenuItem(
                            value: TransactionType.interestReceived,
                            child: Text('Interest Received (Credit)'),
                          ),
                          const DropdownMenuItem(
                            value: TransactionType.loanRepayment,
                            child: Text('Loan Repayment (Credit)'),
                          ),
                          const DropdownMenuItem(
                            value: TransactionType.debitAdjustment,
                            child: Text('Debit Adjustment (+)'),
                          ),
                          const DropdownMenuItem(
                            value: TransactionType.creditAdjustment,
                            child: Text('Credit Adjustment (-)'),
                          ),
                          if (_selectedType == TransactionType.openingBalance)
                            const DropdownMenuItem(
                              value: TransactionType.openingBalance,
                              child: Text('Opening Balance'),
                            ),
                        ],
                        onChanged: isEditing
                            ? null
                            : (v) => setState(() => _selectedType = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && mounted) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date *',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppFormatters.formatInputDate(_selectedDate),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.mute,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Amount & Payment Mode Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount *',
                          prefixText: 'Rs ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Amount is required';
                          }
                          if (double.tryParse(v.trim()) == null) {
                            return 'Enter a valid number';
                          }
                          if (double.parse(v.trim()) <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedPaymentMode,
                        decoration: const InputDecoration(
                          labelText: 'Payment Mode',
                        ),
                        items: _paymentModes
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedPaymentMode = v!),
                      ),
                    ),
                  ],
                ),

                // Interest Rate Field (for Loan Given or Interest Charged)
                if (_selectedType == TransactionType.loanGiven ||
                    _selectedType == TransactionType.interestCharged) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _interestRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate (% / month)',
                      hintText: 'e.g. 2.0 (% per month)',
                      suffixText: '% / mo',
                    ),
                    validator: (v) {
                      if (v != null && v.trim().isNotEmpty) {
                        final num = double.tryParse(v.trim());
                        if (num == null) return 'Enter a valid number';
                        if (num < 0) return 'Cannot be negative';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 14),

                // Reference No & Description
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _refController,
                        decoration: const InputDecoration(
                          labelText: 'Reference # / Receipt # (optional)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description / Notes (optional)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Expandable Payment Details (Bank/UTR) for Non-Cash
                if (_selectedPaymentMode != 'Cash') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _utrController,
                          decoration: const InputDecoration(
                            labelText: 'UTR / Txn Ref',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _bankController,
                          decoration: const InputDecoration(
                            labelText: 'Bank Name',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _chequeController,
                          decoration: const InputDecoration(
                            labelText: 'Cheque #',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                if (isEditing &&
                    widget.editingTransaction?.linkedTransactionId != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.badgeCrBg.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.badgeCrText),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.badgeCrText,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'This transaction has a linked payment record. If you need to change the upfront payment amount, please edit the linked payment directly from the ledger.',
                            style: AppTypography.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Integrated Upfront Payment option for Sales (PRD question 5)
                if (_selectedType == TransactionType.sale && !isEditing) ...[
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Received Upfront / Advance Payment with this sale?',
                      style: AppTypography.label,
                    ),
                    value: _hasUpfrontPayment,
                    onChanged: (v) =>
                        setState(() => _hasUpfrontPayment = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_hasUpfrontPayment) ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _upfrontAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Paid Upfront Amount',
                              prefixText: 'Rs ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return null;
                              }
                              final num = double.tryParse(v.trim());
                              if (num == null) return 'Enter a valid amount';
                              if (num < 0) return 'Cannot be negative';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _upfrontPaymentMode,
                            decoration: const InputDecoration(
                              labelText: 'Paid Mode',
                            ),
                            items: _paymentModes
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _upfrontPaymentMode = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _upfrontRefController,
                            decoration: const InputDecoration(
                              labelText: 'Receipt / UTR',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ],

                // Optional Line Items section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Itemized Breakdown',
                      style: AppTypography.label.copyWith(
                        color: AppColors.mute,
                      ),
                    ),
                    AppButton(
                      label: 'Add Item',
                      icon: Icons.add,
                      variant: AppButtonVariant.secondary,
                      onPressed: _addLineItem,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._lineItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue:
                                    _jewelryProducts.contains(
                                      item['description'],
                                    )
                                    ? item['description']
                                    : (item['description'] == ''
                                          ? null
                                          : 'Custom...'),
                                decoration: const InputDecoration(
                                  labelText: 'Select Product',
                                ),
                                items: [
                                  ..._jewelryProducts.map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        p,
                                        style: AppTypography.bodyMedium
                                            .copyWith(color: AppColors.ink),
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Custom...',
                                    child: Text(
                                      'Custom (Type manually)',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    if (val != 'Custom...') {
                                      item['description'] = val;
                                    } else {
                                      item['description'] = '';
                                    }
                                  });
                                },
                              ),
                              if (!_jewelryProducts.contains(
                                item['description'],
                              )) ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: item['description'],
                                  decoration: const InputDecoration(
                                    labelText: 'Custom Item Name',
                                  ),
                                  onChanged: (val) => item['description'] = val,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: (item['quantity'] as num)
                                .toInt()
                                .toString(),
                            decoration: const InputDecoration(labelText: 'Qty'),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              final parsed = double.tryParse(val) ?? 1.0;
                              final qty = parsed < 0 ? parsed.abs() : parsed;
                              item['quantity'] = qty;
                              item['amount'] = qty * (item['rate'] as num);
                              _recalculateAmountFromLineItems();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: item['unit'] as String? ?? 'PCS',
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'PCS',
                                child: Text('PCS'),
                              ),
                              DropdownMenuItem(
                                value: 'KGS',
                                child: Text('KGS'),
                              ),
                              DropdownMenuItem(
                                value: 'LTR',
                                child: Text('LTR'),
                              ),
                              DropdownMenuItem(
                                value: 'MTR',
                                child: Text('MTR'),
                              ),
                              DropdownMenuItem(
                                value: 'PKT',
                                child: Text('PKT'),
                              ),
                              DropdownMenuItem(
                                value: 'BOX',
                                child: Text('BOX'),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                item['unit'] = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: (item['rate'] as num)
                                .toInt()
                                .toString(),
                            decoration: const InputDecoration(
                              labelText: 'Rate',
                              prefixText: 'Rs ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              final parsed = double.tryParse(val) ?? 0.0;
                              final rate = parsed < 0 ? parsed.abs() : parsed;
                              item['rate'] = rate;
                              item['amount'] = (item['quantity'] as num) * rate;
                              _recalculateAmountFromLineItems();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                          onPressed: () => _removeLineItem(idx),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      label: 'Cancel',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      label: isEditing ? 'Save Changes' : 'Save Transaction',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
