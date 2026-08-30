import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs ',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs ',
    decimalDigits: 0,
  );

  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');
  static final DateFormat _inputDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _fileDateFormat = DateFormat('yyyy-MM-dd');

  /// Formats amount with Rs symbol and Indian grouping.
  /// If [showDecimals] is false or amount is an integer, can omit decimals if desired.
  static String formatCurrency(double amount, {bool forceDecimals = false}) {
    if (!forceDecimals && amount == amount.roundToDouble()) {
      return _compactCurrencyFormat.format(amount);
    }
    return _currencyFormat.format(amount);
  }

  /// Formats balance with Dr/Cr notation.
  /// Net positive balance (> 0) means Debit (Dr) -> Party owes shop.
  /// Net negative balance (< 0) means Credit (Cr) -> Shop owes party.
  /// Zero balance means Nil / Settled.
  static String formatBalance(double balance, {bool forceDecimals = false}) {
    if (balance > 0.0001) {
      return '${formatCurrency(balance, forceDecimals: forceDecimals)} Dr';
    } else if (balance < -0.0001) {
      return '${formatCurrency(balance.abs(), forceDecimals: forceDecimals)} Cr';
    } else {
      return '${formatCurrency(0, forceDecimals: forceDecimals)} (Nil)';
    }
  }

  static String formatDate(DateTime date) => _displayDateFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);
  static String formatInputDate(DateTime date) => _inputDateFormat.format(date);
  static String formatDateTime(DateTime dateTime) =>
      _dateTimeFormat.format(dateTime);
  static String formatFileDate(DateTime date) => _fileDateFormat.format(date);

  static DateTime? parseInputDate(String text) {
    try {
      return _inputDateFormat.parseStrict(text.trim());
    } catch (_) {
      try {
        return DateTime.parse(text.trim());
      } catch (_) {
        return null;
      }
    }
  }
}
