import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/database/database.dart';
import '../../core/database/tables.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../services/interest/interest_calculator_service.dart';

class InterestCalculatorDialog extends ConsumerStatefulWidget {
  final Party? party;
  final double? currentBalance;

  const InterestCalculatorDialog({super.key, this.party, this.currentBalance});

  @override
  ConsumerState<InterestCalculatorDialog> createState() =>
      _InterestCalculatorDialogState();
}

class _InterestCalculatorDialogState
    extends ConsumerState<InterestCalculatorDialog> {
  Party? _selectedParty;
  double? _selectedBalance;
  late TextEditingController _principalController;
  late TextEditingController _rateController;
  late DateTime _fromDate;
  late DateTime _toDate;
  InterestRateType _rateType = InterestRateType.monthly;
  InterestCalculationMethod _method = InterestCalculationMethod.simple;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _selectedParty = widget.party;
    _selectedBalance = widget.currentBalance;

    final initialPrincipal = (_selectedBalance != null && _selectedBalance! > 0)
        ? _selectedBalance!
        : 10000.0;
    _principalController = TextEditingController(
      text: initialPrincipal.toStringAsFixed(0),
    );

    final initialRate = _selectedParty?.interestRate ?? 2.0;
    _rateController = TextEditingController(
      text: initialRate.toStringAsFixed(
        initialRate.truncateToDouble() == initialRate ? 0 : 2,
      ),
    );

    _toDate = DateTime.now();
    _fromDate = DateTime(_toDate.year, _toDate.month - 1, _toDate.day);
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  InterestCalculationResult get _calculatedResult {
    final principal = (double.tryParse(_principalController.text.trim()) ?? 0.0)
        .clamp(0.0, double.infinity);
    final rate = (double.tryParse(_rateController.text.trim()) ?? 0.0).clamp(
      0.0,
      double.infinity,
    );

    return InterestCalculatorService.calculate(
      principal: principal.toDouble(),
      rate: rate.toDouble(),
      fromDate: _fromDate,
      toDate: _toDate,
      rateType: _rateType,
      method: _method,
    );
  }

  Future<void> _postInterestToLedger() async {
    final res = _calculatedResult;
    if (res.interestAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Calculated interest amount must be greater than 0 to post to ledger.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a customer to post interest to their ledger.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final rate = double.tryParse(_rateController.text.trim());

      await repo.createTransaction(
        partyId: _selectedParty!.id,
        type: TransactionType.interestCharged,
        date: _toDate,
        amount: res.interestAmount,
        interestRate: rate,
        description: res.ledgerNote,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully posted interest of ${AppFormatters.formatCurrency(res.interestAmount)} to ${_selectedParty!.name}\'s ledger.',
            ),
            backgroundColor: AppColors.ink,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting interest: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = _calculatedResult;
    final partiesAsync = ref.watch(partiesListProvider(null));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.percent,
                          size: 22,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Interest Calculator',
                            style: AppTypography.headingMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Calculate & post accrued interest to ledger',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.mute,
                            ),
                          ),
                        ],
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

              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.hairline),
              const SizedBox(height: 18),

              // Party Details Summary Box or Party Selector
              if (_selectedParty != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.hairlineSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CUSTOMER', style: AppTypography.monoEyebrow),
                            const SizedBox(height: 3),
                            Text(
                              _selectedParty!.name,
                              style: AppTypography.label.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'CURRENT BALANCE',
                            style: AppTypography.monoEyebrow,
                          ),
                          const SizedBox(height: 3),
                          BalanceBadge(
                            balance: _selectedBalance ?? 0.0,
                            forceDecimals: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                partiesAsync.maybeWhen(
                  data: (parties) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText:
                          'Select Customer (to link calculation & post to ledger)',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                    items: parties.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.party.id,
                        child: Text(
                          '${p.party.name} (${AppFormatters.formatBalance(p.currentBalance)})',
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      final selected = parties.firstWhere(
                        (p) => p.party.id == val,
                        orElse: () => parties.first,
                      );
                      setState(() {
                        _selectedParty = selected.party;
                        _selectedBalance = selected.currentBalance;
                        if (selected.currentBalance > 0) {
                          _principalController.text = selected.currentBalance
                              .toStringAsFixed(0);
                        }
                        if (selected.party.interestRate != null) {
                          _rateController.text = selected.party.interestRate!
                              .toString();
                        }
                      });
                    },
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),

              const SizedBox(height: 18),

              // Principal & Rate Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Principal Amount *', style: AppTypography.label),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _principalController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final num = double.tryParse(v.trim());
                              if (num == null) return 'Invalid number';
                              if (num < 0) return 'Cannot be negative';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            prefixText: 'Rs ',
                            hintText: '50000',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rate (%) *', style: AppTypography.label),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _rateController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final num = double.tryParse(v.trim());
                              if (num == null) return 'Invalid number';
                              if (num < 0) return 'Cannot be negative';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixText: _rateType == InterestRateType.monthly
                                ? '% / mo'
                                : '% / yr',
                            hintText: '2.0',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Rate Frequency & Method Selector
              Wrap(
                spacing: 8,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Rate Period:',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mute,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Monthly (%/mo)'),
                    selected: _rateType == InterestRateType.monthly,
                    showCheckmark: false,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _rateType = InterestRateType.monthly);
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Annual (%/yr)'),
                    selected: _rateType == InterestRateType.annual,
                    showCheckmark: false,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _rateType = InterestRateType.annual);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Type:',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mute,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Simple'),
                    selected: _method == InterestCalculationMethod.simple,
                    showCheckmark: false,
                    onSelected: (val) {
                      if (val) {
                        setState(
                          () => _method = InterestCalculationMethod.simple,
                        );
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Compound'),
                    selected:
                        _method == InterestCalculationMethod.compoundMonthly,
                    showCheckmark: false,
                    onSelected: (val) {
                      if (val) {
                        setState(
                          () => _method =
                              InterestCalculationMethod.compoundMonthly,
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Dates Row (From & To)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From Date', style: AppTypography.label),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _fromDate,
                              firstDate: DateTime(2000),
                              lastDate: _toDate,
                            );
                            if (picked != null && mounted) {
                              setState(() => _fromDate = picked);
                            }
                          },
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.elevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.hairline),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: AppColors.mute,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd MMM yyyy').format(_fromDate),
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('To Date', style: AppTypography.label),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _toDate,
                              firstDate: _fromDate,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null && mounted) {
                              setState(() => _toDate = picked);
                            }
                          },
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.elevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.hairline),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: AppColors.mute,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd MMM yyyy').format(_toDate),
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Live Calculation Result Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.hairlineSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CALCULATION SUMMARY',
                          style: AppTypography.monoEyebrow,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: Text(
                            res.durationDescription,
                            style: AppTypography.codeMono.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Principal',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppFormatters.formatCurrency(res.principal),
                                style: AppTypography.label.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Rate Applied',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                res.rateDescription,
                                style: AppTypography.label.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Interest',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppFormatters.formatCurrency(
                                  res.interestAmount,
                                ),
                                style: AppTypography.label.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.badgeDrText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: AppColors.hairline),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Settlement Amount:',
                          style: AppTypography.label,
                        ),
                        Text(
                          AppFormatters.formatCurrency(res.totalAmount),
                          style: AppTypography.headingMedium.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isPosting ? null : _postInterestToLedger,
                    icon: _isPosting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_chart_outlined, size: 18),
                    label: Text(
                      _isPosting ? 'Posting...' : 'Post Interest to Ledger',
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
