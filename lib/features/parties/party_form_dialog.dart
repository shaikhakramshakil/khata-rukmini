import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class PartyFormDialog extends ConsumerStatefulWidget {
  final String defaultType; // 'customer' or 'supplier'
  final Party? editingParty;

  const PartyFormDialog({
    super.key,
    this.defaultType = 'customer',
    this.editingParty,
  });

  @override
  ConsumerState<PartyFormDialog> createState() => _PartyFormDialogState();
}

class _PartyFormDialogState extends ConsumerState<PartyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late TextEditingController _openingBalController;
  late TextEditingController _interestRateController;

  late String _selectedType;
  bool _isOpeningDebit = true; // Dr (party owes shop) vs Cr (shop owes party)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.editingParty;
    _nameController = TextEditingController(text: p?.name ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
    _openingBalController = TextEditingController();
    _interestRateController = TextEditingController(
      text: p?.interestRate != null ? p!.interestRate.toString() : '',
    );
    _selectedType = p?.type ?? widget.defaultType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _openingBalController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final repo = ref.read(partyRepositoryProvider);
    final interestRate = double.tryParse(_interestRateController.text.trim());

    try {
      if (widget.editingParty != null) {
        await repo.updatePartyDetails(
          id: widget.editingParty!.id,
          name: _nameController.text,
          type: _selectedType,
          phone: _phoneController.text,
          address: _addressController.text,
          notes: _notesController.text,
          interestRate: interestRate,
        );
      } else {
        double? openingBal;
        final rawBal = double.tryParse(_openingBalController.text.trim());
        if (rawBal != null && rawBal > 0) {
          openingBal = _isOpeningDebit ? rawBal : -rawBal;
        }

        await repo.createParty(
          name: _nameController.text,
          type: _selectedType,
          phone: _phoneController.text,
          address: _addressController.text,
          notes: _notesController.text,
          interestRate: interestRate,
          openingBalance: openingBal,
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving party: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingParty != null;
    final isCustomer = _selectedType == 'customer';

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing
                          ? 'Edit ${isCustomer ? 'Customer' : 'Supplier'}'
                          : 'New Party Entry',
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

                // Party Type Selector
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Customer')),
                        selected: _selectedType == 'customer',
                        showCheckmark: false,
                        onSelected: isEditing
                            ? null
                            : (_) => setState(() => _selectedType = 'customer'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Supplier')),
                        selected: _selectedType == 'supplier',
                        showCheckmark: false,
                        onSelected: isEditing
                            ? null
                            : (_) => setState(() => _selectedType = 'supplier'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Both')),
                        selected: _selectedType == 'both',
                        onSelected: isEditing
                            ? null
                            : (_) => setState(() => _selectedType = 'both'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name / Business Name *',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone / Mobile Number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.length < 10) {
                        return 'Enter a valid phone number (min 10 digits)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address / City',
                  ),
                ),
                const SizedBox(height: 12),

                if (!isEditing) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _openingBalController,
                          decoration: const InputDecoration(
                            labelText: 'Opening Balance (optional)',
                            prefixText: 'Rs ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final num = double.tryParse(v.trim());
                              if (num == null) {
                                return 'Enter a valid number';
                              }
                              if (num < 0) {
                                return 'Cannot be negative';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<bool>(
                          initialValue: _isOpeningDebit,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Dr (Due)'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Cr (Advance)'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _isOpeningDebit = v ?? true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                TextFormField(
                  controller: _interestRateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Default Interest Rate (% / month) (optional)',
                    hintText: 'e.g. 2.0 (% per month)',
                    suffixText: '% / mo',
                  ),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final num = double.tryParse(v.trim());
                      if (num == null) {
                        return 'Enter a valid number';
                      }
                      if (num < 0) {
                        return 'Cannot be negative';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Remarks',
                  ),
                  maxLines: 2,
                ),
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
                      label: isEditing ? 'Save Changes' : 'Create Party',
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
