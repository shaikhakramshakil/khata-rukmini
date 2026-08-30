import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/security_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/services/update_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _invPrefixController = TextEditingController();
  final _recPrefixController = TextEditingController();
  final _txnPrefixController = TextEditingController();
  final _termsController = TextEditingController();
  String? _backupDirectory;
  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isCheckingUpdate = false;
  final UpdateService _updateService = UpdateService();
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _invPrefixController.dispose();
    _recPrefixController.dispose();
    _txnPrefixController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  void _initFields(ShopSetting settings) {
    if (_isInitialized) return;
    _nameController.text = settings.shopName;
    _phoneController.text = settings.phone;
    _addressController.text = settings.address;
    _emailController.text = settings.email ?? '';
    _invPrefixController.text = settings.invoicePrefix;
    _recPrefixController.text = settings.receiptPrefix;
    _txnPrefixController.text = settings.txnPrefix;
    _termsController.text = settings.terms;
    _backupDirectory = settings.backupDirectory;
    _isInitialized = true;
  }

  Future<void> _checkForUpdatesManually() async {
    if (_isCheckingUpdate) return;
    setState(() => _isCheckingUpdate = true);
    
    try {
      final updateInfo = await _updateService.checkForUpdate();
      if (!mounted) return;
      
      setState(() => _isCheckingUpdate = false);

      if (updateInfo != null) {
        _showUpdateDialog(updateInfo);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are already on the latest version.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingUpdate = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking for updates: $e')),
      );
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo.isMandatory,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Update Available'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Version ${updateInfo.version} is available!'),
                  const SizedBox(height: 12),
                  Text('Release Notes:', style: AppTypography.label),
                  const SizedBox(height: 4),
                  Text(updateInfo.releaseNotes),
                  if (_isDownloading) ...[
                    const SizedBox(height: 24),
                    LinearProgressIndicator(value: _downloadProgress),
                    const SizedBox(height: 8),
                    Text('${(_downloadProgress * 100).toStringAsFixed(1)}% downloaded'),
                  ]
                ],
              ),
            ),
            actions: [
              if (!updateInfo.isMandatory && !_isDownloading)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              if (!_isDownloading)
                AppButton(
                  label: 'Update Now',
                  onPressed: () async {
                    setDialogState(() {
                      _isDownloading = true;
                      _downloadProgress = 0.0;
                    });
                    final file = await _updateService.downloadUpdate(
                      updateInfo.downloadUrl, 
                      (count, total) {
                        if (total > 0) {
                          setDialogState(() => _downloadProgress = count / total);
                        }
                      }
                    );
                    if (file != null) {
                      _updateService.installUpdateAndRestart(file);
                    } else {
                      if (!mounted) return;
                      setDialogState(() => _isDownloading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to download update.')),
                      );
                    }
                  },
                ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final repo = ref.read(settingsRepositoryProvider);

    try {
      await repo.updateSettings(
        shopName: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        invoicePrefix: _invPrefixController.text,
        receiptPrefix: _recPrefixController.text,
        txnPrefix: _txnPrefixController.text,
        terms: _termsController.text,
        backupDirectory: _backupDirectory,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop settings updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showPinDialog({required bool isChanging}) async {
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;

    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) => AlertDialog(
          title: Text(isChanging ? 'Change App PIN' : 'Set App PIN'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter a 4-digit numeric PIN to protect app launch.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mute,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: pinController,
                  obscureText: obscure,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '4-Digit PIN',
                    counterText: '',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () => setModalState(() => obscure = !obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null ||
                        v.trim().length != 4 ||
                        int.tryParse(v.trim()) == null) {
                      return 'PIN must be exactly 4 numeric digits';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.elevated,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogCtx).pop(true);
                }
              },
              child: Text(isChanging ? 'Update PIN' : 'Save PIN'),
            ),
          ],
        ),
      ),
    );

    if (success == true) {
      final pin = pinController.text.trim();
      final hashed = SecurityService.hashSecret(pin);
      await ref.read(settingsRepositoryProvider).updateSettings(appPin: hashed);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isChanging
                  ? 'PIN updated successfully.'
                  : 'PIN set successfully.',
            ),
          ),
        );
      }
    }
    pinController.dispose();
  }

  Future<void> _removePin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove App PIN?'),
        content: const Text(
          'Disabling PIN protection will allow direct access to the app without a lock screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove PIN'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(settingsRepositoryProvider).updateSettings(appPin: '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN removed. Lock screen disabled.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(shopSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTypography.headingLarge),
              const SizedBox(height: 4),
              Text(
                'Configure shop identity and document printing settings',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.mute),
              ),
              const SizedBox(height: 24),

              settingsAsync.when(
                data: (settings) {
                  _initFields(settings);
                  final hasPin =
                      settings.appPin != null && settings.appPin!.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop Details Card
                      _buildSectionCard(
                        title: 'SHOP DETAILS',
                        subtitle:
                            'Appears on printed statements, receipts, and invoices',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Shop / Firm Name *',
                                  ),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Name required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Contact Phone Number *',
                                  ),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? 'Phone required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Shop Address / Market Location',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address (optional)',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Document Sequences & Prefixes Card
                      _buildSectionCard(
                        title: 'DOCUMENT PREFIXES & NUMBERING',
                        subtitle:
                            'Prefixes for generated vouchers and invoices',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _invPrefixController,
                                  decoration: const InputDecoration(
                                    labelText: 'Invoice Prefix (e.g. INV-)',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _recPrefixController,
                                  decoration: const InputDecoration(
                                    labelText: 'Receipt Prefix (e.g. REC-)',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _txnPrefixController,
                                  decoration: const InputDecoration(
                                    labelText: 'Txn Prefix (e.g. TXN-)',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _termsController,
                            decoration: const InputDecoration(
                              labelText:
                                  'Standard Terms & Conditions on Invoices',
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Auto Backup Location Card
                      _buildSectionCard(
                        title: 'AUTOMATED BACKUP LOCATION',
                        subtitle:
                            'Directory where daily database backups will be saved',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _backupDirectory ?? 'Not set',
                                  style: AppTypography.codeMono,
                                ),
                              ),
                              AppButton(
                                label: 'Change Location',
                                variant: AppButtonVariant.secondary,
                                onPressed: () async {
                                  final result =
                                      await file_picker
                                          .FilePicker.getDirectoryPath(
                                        dialogTitle:
                                            'Select Auto Backup Directory',
                                      );
                                  if (result != null) {
                                    setState(() => _backupDirectory = result);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Security & Access Control Card
                      _buildSectionCard(
                        title: 'SECURITY & ACCESS CONTROL',
                        subtitle:
                            'Protect application sessions with a 4-digit numeric PIN.',
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: hasPin
                                      ? AppColors.badgeCrBg
                                      : AppColors.hairline.withValues(
                                          alpha: 0.3,
                                        ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: hasPin
                                        ? AppColors.badgeCrText.withValues(
                                            alpha: 0.3,
                                          )
                                        : AppColors.hairline,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      hasPin
                                          ? Icons.shield_outlined
                                          : Icons.lock_open_outlined,
                                      size: 18,
                                      color: hasPin
                                          ? AppColors.badgeCrText
                                          : AppColors.mute,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      hasPin
                                          ? 'PIN Protection Active'
                                          : 'No PIN Configured',
                                      style: AppTypography.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: hasPin
                                            ? AppColors.badgeCrText
                                            : AppColors.mute,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (hasPin) ...[
                                AppButton(
                                  label: 'Change PIN',
                                  variant: AppButtonVariant.secondary,
                                  icon: Icons.edit_outlined,
                                  onPressed: () =>
                                      _showPinDialog(isChanging: true),
                                ),
                                const SizedBox(width: 12),
                                AppButton(
                                  label: 'Remove PIN',
                                  variant: AppButtonVariant.danger,
                                  icon: Icons.delete_outline,
                                  onPressed: () => _removePin(),
                                ),
                              ] else ...[
                                AppButton(
                                  label: 'Set PIN',
                                  icon: Icons.lock_outline,
                                  onPressed: () =>
                                      _showPinDialog(isChanging: false),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Software Updates Card
                      _buildSectionCard(
                        title: 'SOFTWARE UPDATES',
                        subtitle: 'Check for the latest features and bug fixes.',
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Keep your application up to date.',
                                ),
                              ),
                              AppButton(
                                label: 'Check for Updates',
                                icon: Icons.system_update_alt_outlined,
                                isLoading: _isCheckingUpdate,
                                onPressed: _checkForUpdatesManually,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppButton(
                          label: 'Save Settings',
                          isLoading: _isSaving,
                          onPressed: _save,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.label.copyWith(
              color: AppColors.mute,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(color: AppColors.mute),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
