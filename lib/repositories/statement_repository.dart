import 'package:drift/drift.dart';
import '../core/database/database.dart';
import 'models/statement_models.dart';

class StatementRepository {
  final AppDatabase _db;

  StatementRepository(this._db);

  String _formatTypeLabel(String type) {
    switch (type) {
      case 'sale':
        return 'Sale';
      case 'purchase':
        return 'Purchase';
      case 'paymentReceived':
        return 'Payment Received';
      case 'paymentMade':
        return 'Payment Made';
      case 'debitAdjustment':
        return 'Debit Adjustment';
      case 'creditAdjustment':
        return 'Credit Adjustment';
      case 'openingBalance':
        return 'Opening Balance';
      case 'loanGiven':
        return 'Loan Given';
      case 'interestCharged':
        return 'Interest Charged';
      case 'interestReceived':
        return 'Interest Received';
      case 'loanRepayment':
        return 'Loan Repayment';
      default:
        return type;
    }
  }

  Future<PartyStatementData> getPartyStatement({
    required String partyId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final party = await _db.getPartyById(partyId);
    if (party == null) throw Exception('Party not found');

    // Normalize dates to start-of-day and end-of-day
    final start = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
      0,
      0,
      0,
    );
    final end = DateTime(
      toDate.year,
      toDate.month,
      toDate.day,
      23,
      59,
      59,
      999,
    );

    // 1. Calculate Brought Forward (b/f) balance prior to fromDate
    final bfBalance = await _db.getPartyBalancePriorToDate(partyId, start);

    // 2. Fetch period transactions sorted chronologically
    final txns = await _db.getPartyTransactionsInDateRange(partyId, start, end);

    final rows = <StatementRow>[];
    double running = bfBalance;
    double periodDebit = 0.0;
    double periodCredit = 0.0;

    // Add Brought Forward row if non-zero or if starting balance exists
    if (bfBalance.abs() > 0.0001) {
      rows.add(
        StatementRow(
          date: start,
          typeLabel: 'Opening Balance (b/f)',
          referenceNo: '-',
          description: 'Balance brought forward from previous period',
          debit: bfBalance > 0 ? bfBalance : 0.0,
          credit: bfBalance < 0 ? bfBalance.abs() : 0.0,
          runningBalance: running,
          isBroughtForward: true,
        ),
      );
    }

    for (final txn in txns) {
      running += (txn.debit - txn.credit);
      periodDebit += txn.debit;
      periodCredit += txn.credit;

      rows.add(
        StatementRow(
          date: txn.date,
          typeLabel: _formatTypeLabel(txn.type),
          referenceNo: txn.referenceNo ?? txn.transactionNo,
          description: txn.description,
          debit: txn.debit,
          credit: txn.credit,
          runningBalance: running,
          transactionId: txn.id,
        ),
      );
    }

    return PartyStatementData(
      partyId: party.id,
      partyName: party.name,
      partyType: party.type,
      phone: party.phone,
      address: party.address,
      fromDate: start,
      toDate: end,
      broughtForwardBalance: bfBalance,
      rows: rows,
      totalDebit: periodDebit,
      totalCredit: periodCredit,
      closingBalance: running,
    );
  }

  Future<GeneralLedgerData> getGeneralLedger({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final start = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
      0,
      0,
      0,
    );
    final end = DateTime(
      toDate.year,
      toDate.month,
      toDate.day,
      23,
      59,
      59,
      999,
    );

    // Calculate system-wide balance prior to date
    final drSum = _db.transactions.debit.sum();
    final crSum = _db.transactions.credit.sum();
    final bfQuery = _db.selectOnly(_db.transactions)
      ..addColumns([drSum, crSum])
      ..where(
        _db.transactions.deletedAt.isNull() &
            _db.transactions.date.isSmallerThanValue(start),
      );
    final bfRow = await bfQuery.getSingle();
    final bfBalance = (bfRow.read(drSum) ?? 0.0) - (bfRow.read(crSum) ?? 0.0);

    // All active transactions in range joined with parties (no N+1)
    final txns = await _db.getGeneralLedgerTransactions(start, end);

    final rows = <GeneralLedgerRow>[];
    double running = bfBalance;
    double periodDebit = 0.0;
    double periodCredit = 0.0;

    for (final txnWP in txns) {
      final txn = txnWP.transaction;
      final partyName = txnWP.party.name;

      running += (txn.debit - txn.credit);
      periodDebit += txn.debit;
      periodCredit += txn.credit;

      rows.add(
        GeneralLedgerRow(
          date: txn.date,
          partyName: partyName,
          typeLabel: _formatTypeLabel(txn.type),
          referenceNo: txn.referenceNo ?? txn.transactionNo,
          description: txn.description,
          debit: txn.debit,
          credit: txn.credit,
          runningBalance: running,
        ),
      );
    }

    return GeneralLedgerData(
      fromDate: start,
      toDate: end,
      broughtForwardBalance: bfBalance,
      rows: rows,
      totalDebit: periodDebit,
      totalCredit: periodCredit,
      closingBalance: running,
    );
  }
}
