import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/whatsapp_icon.dart';
import '../../services/whatsapp/whatsapp_service.dart';

class WhatsAppReminderDialog extends ConsumerStatefulWidget {
  final Party party;
  final double balance;

  const WhatsAppReminderDialog({
    super.key,
    required this.party,
    required this.balance,
  });

  @override
  ConsumerState<WhatsAppReminderDialog> createState() =>
      _WhatsAppReminderDialogState();
}

class _WhatsAppReminderDialogState
    extends ConsumerState<WhatsAppReminderDialog> {
  late TextEditingController _phoneController;
  late TextEditingController _messageController;
  bool _isSending = false;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.party.phone ?? '');
    _messageController = TextEditingController();

    // Generate initial message using settings once available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateTemplate();
    });
  }

  void _generateTemplate() {
    final settings = ref.read(shopSettingsProvider).value;
    final shopName = settings?.shopName ?? 'Rukmini Khata Book';
    final shopPhone = settings?.phone;
    final shopAddress = settings?.address;

    final msg = WhatsAppService.buildReminderMessage(
      customerName: widget.party.name,
      pendingAmount: widget.balance,
      shopName: shopName,
      shopPhone: shopPhone,
      shopAddress: shopAddress,
    );

    setState(() {
      _messageController.text = msg;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendWhatsApp() async {
    final phone = _phoneController.text.trim();
    final sanitized = WhatsAppService.sanitizePhoneNumber(phone);

    if (sanitized.length < 10) {
      setState(() {
        _phoneError =
            'Please enter a valid 10-digit phone number with country code';
      });
      return;
    }

    setState(() {
      _phoneError = null;
      _isSending = true;
    });

    final success = await WhatsAppService.launchWhatsApp(
      phone: phone,
      message: _messageController.text,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const WhatsAppIcon(size: 16),
                const SizedBox(width: 8),
                Text('Redirecting to WhatsApp for ${widget.party.name}...'),
              ],
            ),
            backgroundColor: AppColors.ink,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open WhatsApp. Make sure your browser or WhatsApp app is available.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const WhatsAppIcon(size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send WhatsApp Reminder',
                          style: AppTypography.headingMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Directs to WhatsApp Web/App with pre-filled customer details',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.mute,
                          ),
                        ),
                      ],
                    ),
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

              // Customer & Amount Card
              Container(
                padding: const EdgeInsets.all(16),
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
                          const SizedBox(height: 4),
                          Text(
                            widget.party.name,
                            style: AppTypography.label.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PENDING BALANCE',
                          style: AppTypography.monoEyebrow,
                        ),
                        const SizedBox(height: 4),
                        BalanceBadge(
                          balance: widget.balance,
                          forceDecimals: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Phone Number Field
              Text('Recipient WhatsApp Number *', style: AppTypography.label),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. 9876543210 or +91 98765 43210',
                  errorText: _phoneError,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: AppColors.mute,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.hairline),
                  ),
                ),
                onChanged: (_) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
              ),

              const SizedBox(height: 16),

              // Message Template Field with Reset Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Message Template (Editable)',
                    style: AppTypography.label,
                  ),
                  TextButton.icon(
                    onPressed: _generateTemplate,
                    icon: const Icon(
                      Icons.refresh,
                      size: 14,
                      color: AppColors.mute,
                    ),
                    label: Text(
                      'Reset Template',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mute,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Expanded(
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: AppTypography.codeMono.copyWith(
                    fontSize: 12,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.ink),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Copy Text',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.copy_outlined,
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: _messageController.text),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendWhatsApp,
                    icon: const WhatsAppIcon(size: 18, color: Colors.white),
                    label: Text(
                      _isSending ? 'Opening WhatsApp...' : 'Open in WhatsApp',
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
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
