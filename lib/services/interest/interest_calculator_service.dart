import 'dart:math';
import 'package:intl/intl.dart';

enum InterestRateType {
  monthly, // % per month (e.g. 2% = Rs 2 per 100 per month - standard Indian interest)
  annual, // % per annum (e.g. 18% p.a.)
}

enum InterestCalculationMethod {
  simple, // Simple Interest
  compoundMonthly, // Compound Monthly
}

class InterestCalculationResult {
  final double principal;
  final double rate;
  final InterestRateType rateType;
  final InterestCalculationMethod method;
  final DateTime fromDate;
  final DateTime toDate;
  final int totalDays;
  final int months;
  final int remainingDays;
  final double interestAmount;
  final double totalAmount;

  const InterestCalculationResult({
    required this.principal,
    required this.rate,
    required this.rateType,
    required this.method,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.months,
    required this.remainingDays,
    required this.interestAmount,
    required this.totalAmount,
  });

  String get durationDescription {
    if (months == 0) {
      return '$totalDays ${totalDays == 1 ? 'day' : 'days'}';
    } else if (remainingDays == 0) {
      return '$months ${months == 1 ? 'month' : 'months'} ($totalDays days)';
    } else {
      return '$months ${months == 1 ? 'month' : 'months'}, $remainingDays ${remainingDays == 1 ? 'day' : 'days'} ($totalDays days)';
    }
  }

  String get rateDescription {
    if (rateType == InterestRateType.monthly) {
      return '${rate.toStringAsFixed(rate.truncateToDouble() == rate ? 0 : 2)}% / month';
    } else {
      return '${rate.toStringAsFixed(rate.truncateToDouble() == rate ? 0 : 2)}% p.a.';
    }
  }

  String get ledgerNote {
    final startStr = DateFormat('dd/MM/yyyy').format(fromDate);
    final endStr = DateFormat('dd/MM/yyyy').format(toDate);
    return 'Interest for $durationDescription @ $rateDescription ($startStr to $endStr)';
  }
}

class InterestCalculatorService {
  /// Calculates interest based on principal, rate, dates, and method.
  static InterestCalculationResult calculate({
    required double principal,
    required double rate,
    required DateTime fromDate,
    required DateTime toDate,
    InterestRateType rateType = InterestRateType.monthly,
    InterestCalculationMethod method = InterestCalculationMethod.simple,
  }) {
    if (!(principal > 0) || !(rate > 0)) {
      return InterestCalculationResult(
        principal: principal,
        rate: rate,
        rateType: rateType,
        method: method,
        fromDate: fromDate,
        toDate: toDate,
        totalDays: 0,
        months: 0,
        remainingDays: 0,
        interestAmount: 0.0,
        totalAmount: principal,
      );
    }
    if (toDate.isBefore(fromDate)) {
      return InterestCalculationResult(
        principal: principal,
        rate: rate,
        rateType: rateType,
        method: method,
        fromDate: fromDate,
        toDate: toDate,
        totalDays: 0,
        months: 0,
        remainingDays: 0,
        interestAmount: 0.0,
        totalAmount: principal,
      );
    }

    // Normalize dates to start of day
    final start = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final end = DateTime(toDate.year, toDate.month, toDate.day);
    final totalDays = max(0, end.difference(start).inDays);

    final months = totalDays ~/ 30;
    final remainingDays = totalDays % 30;

    double interest = 0.0;

    if (method == InterestCalculationMethod.simple) {
      if (rateType == InterestRateType.monthly) {
        // Standard Indian Khata / Mahajan rule:
        // Interest = Principal * (Rate / 100) * (Days / 30)
        interest = principal * (rate / 100.0) * (totalDays / 30.0);
      } else {
        // Annual basis:
        // Interest = Principal * (Rate / 100) * (Days / 365)
        interest = principal * (rate / 100.0) * (totalDays / 365.0);
      }
    } else if (method == InterestCalculationMethod.compoundMonthly) {
      final monthlyRate = rateType == InterestRateType.monthly
          ? rate
          : (rate / 12.0);
      final r = monthlyRate / 100.0;
      final timeInMonths = totalDays / 30.0;
      final compoundTotal = principal * pow(1.0 + r, timeInMonths);
      interest = compoundTotal - principal;
    }

    // Round to 2 decimal places
    interest = (interest * 100).roundToDouble() / 100;
    final total = ((principal + interest) * 100).roundToDouble() / 100;

    return InterestCalculationResult(
      principal: principal,
      rate: rate,
      rateType: rateType,
      method: method,
      fromDate: start,
      toDate: end,
      totalDays: totalDays,
      months: months,
      remainingDays: remainingDays,
      interestAmount: interest,
      totalAmount: total,
    );
  }
}
