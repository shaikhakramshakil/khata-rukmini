import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class FirstRunSetupDialog extends ConsumerStatefulWidget {
  const FirstRunSetupDialog({super.key});

  @override
  ConsumerState<FirstRunSetupDialog> createState() =>
      _FirstRunSetupDialogState();
}

class _FirstRunSetupDialogState extends ConsumerState<FirstRunSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Rukmini Jewellers');
  final _phoneController = TextEditingController(text: '+91 ');
  final _addressController = TextEditingController(text: 'Main Market');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool skip) async {
    setState(() => _isLoading = true);
    final repo = ref.read(settingsRepositoryProvider);

    if (!skip && _formKey.currentState?.validate() == true) {
      await repo.updateSettings(
        shopName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
      );
    }

    await repo.markFirstRunCompleted();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.hairlineSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 22,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Welcome to Jewelry Khata',
                      style: AppTypography.headingMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Set up your shop details so printed statements and invoices carry your business branding. You can change these anytime in Settings.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mute,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Shop / Business Name *',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter shop name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Contact / Phone *',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter phone'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Shop Address'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton(
                      label: 'Set Up Later',
                      variant: AppButtonVariant.secondary,
                      onPressed: _isLoading ? null : () => _submit(true),
                    ),
                    const Spacer(),
                    AppButton(
                      label: 'Save & Get Started',
                      isLoading: _isLoading,
                      onPressed: () => _submit(false),
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
