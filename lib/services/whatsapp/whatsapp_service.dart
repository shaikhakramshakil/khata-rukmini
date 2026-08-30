import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/formatters.dart';

class WhatsAppService {
  /// Strips non-digits and standardizes country code (defaults to 91 for Indian 10-digit numbers).
  static String sanitizePhoneNumber(String raw) {
    String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';

    // If starts with 0 and total 11 digits (e.g. 09876543210) -> convert to 919876543210
    if (digits.length == 11 && digits.startsWith('0')) {
      digits = '91${digits.substring(1)}';
    } else if (digits.length == 10) {
      // 10 digits Indian phone number without country code
      digits = '91$digits';
    }

    return digits;
  }

  /// Builds a professional, courteous WhatsApp reminder template.
  static String buildReminderMessage({
    required String customerName,
    required double pendingAmount,
    required String shopName,
    String? shopPhone,
    String? shopAddress,
    DateTime? asOfDate,
  }) {
    final formattedDate = DateFormat(
      'dd MMM yyyy',
    ).format(asOfDate ?? DateTime.now());
    final formattedAmount = AppFormatters.formatCurrency(pendingAmount.abs());

    final buffer = StringBuffer();
    buffer.writeln('Dear *$customerName*,');
    buffer.writeln();
    buffer.writeln('Greetings from *$shopName*.');
    buffer.writeln();
    buffer.writeln(
      'This is a gentle reminder regarding your outstanding balance:',
    );
    buffer.writeln('*Pending Amount: $formattedAmount*');
    buffer.writeln('*As of Date: $formattedDate*');
    buffer.writeln();
    buffer.writeln(
      'Kindly arrange for the settlement of the pending amount at your earliest convenience.',
    );
    buffer.writeln();
    buffer.writeln('*Payment Options:* Cash, UPI, Cheque, or Bank Transfer.');
    buffer.writeln();
    buffer.writeln(
      'If you have already completed this payment, please disregard this message.',
    );
    buffer.writeln();
    buffer.writeln('Thank you for your continued trust and business!');
    buffer.writeln('*$shopName*');
    if (shopPhone != null && shopPhone.trim().isNotEmpty) {
      buffer.writeln('Contact: $shopPhone');
    }
    if (shopAddress != null && shopAddress.trim().isNotEmpty) {
      buffer.writeln('Address: $shopAddress');
    }

    return buffer.toString();
  }

  /// Launches the WhatsApp URL in the user's default browser or desktop WhatsApp app.
  static Future<bool> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    final cleanPhone = sanitizePhoneNumber(phone);
    if (cleanPhone.isEmpty) return false;

    final encodedMessage = Uri.encodeComponent(message);
    final urlString = 'https://wa.me/$cleanPhone?text=$encodedMessage';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    return false;
  }
}
