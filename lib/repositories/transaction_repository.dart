import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database.dart';
import '../core/database/tables.dart';

class TransactionWithDetails {
  final TransactionEntry transaction;
  final Party party;
  final List<TransactionLineItem> lineItems;
  final PaymentDetail? paymentDetail;

  TransactionWithDetails({
    required this.transaction,
    required this.party,
    required this.lineItems,
    this.paymentDetail,
  });
}

class TransactionRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  final void Function(String? partyId) onTransactionChanged;

  TransactionRepository(this._db, this.onTransactionChanged);

  /// Calculates the balance of a party immediately before a specific transaction.
  /// Sums (debit - credit) for all active transactions belonging to the party
  /// that were created strictly before this transaction.
  Future<double> getBalanceBeforeTransaction(
    String partyId,
    String transactionId,
  ) async {
    final txn = await _db.getTransactionById(transactionId);
    if (txn == null) throw Exception('Transaction not found');
    return _db.getPartyBalanceBefore(partyId, txn.createdAt, transactionId);
  }

  /// Helper to calculate debit and credit amounts based on transaction type
  (double debit, double credit) calculateDebitCredit(
    TransactionType type,
    double amount, {
    bool isOpeningDebit = true,
  }) {
    switch (type) {
      case TransactionType.sale:
      case TransactionType.paymentMade:
      case TransactionType.debitAdjustment:
      case TransactionType.loanGiven:
      case TransactionType.interestCharged:
        return (amount, 0.0);

      case TransactionType.purchase:
      case TransactionType.paymentReceived:
      case TransactionType.creditAdjustment:
      case TransactionType.interestReceived:
      case TransactionType.loanRepayment:
        return (0.0, amount);

      case TransactionType.openingBalance:
        return isOpeningDebit ? (amount, 0.0) : (0.0, amount);
    }
  }

  Future<TransactionWithDetails> createTransaction({
    required String partyId,
    required TransactionType type,
    required DateTime date,
    required double amount,
    double? interestRate,
    String? paymentMode,
    String? referenceNo,
    String? description,
    bool isOpeningDebit = true,
    List<Map<String, dynamic>>? lineItems,
    Map<String, String?>? paymentDetails,
    // Integrated upfront payment on sale
    double? upfrontPaidAmount,
    String? upfrontPaymentMode,
    String? upfrontReferenceNo,
  }) async {
    final now = DateTime.now();
    final party = await _db.getPartyById(partyId);
    if (party == null) throw Exception('Party not found');

    final seq = await _db.getAndIncrementSeq();
    final settings = await _db.getShopSettings();

    final prefix = type == TransactionType.sale
        ? settings.invoicePrefix
        : type == TransactionType.paymentReceived ||
              type == TransactionType.paymentMade
        ? settings.receiptPrefix
        : type == TransactionType.loanGiven ||
              type == TransactionType.loanRepayment
        ? 'LOAN-'
        : type == TransactionType.interestCharged ||
              type == TransactionType.interestReceived
        ? 'INT-'
        : settings.txnPrefix;
    final txnNo = '$prefix$seq';
    final txnId = _uuid.v4();

    final (debit, credit) = calculateDebitCredit(
      type,
      amount,
      isOpeningDebit: isOpeningDebit,
    );

    final txnCompanion = TransactionsCompanion(
      id: Value(txnId),
      transactionNo: Value(txnNo),
      partyId: Value(partyId),
      date: Value(date),
      type: Value(type.name),
      amount: Value(amount),
      debit: Value(debit),
      credit: Value(credit),
      interestRate: Value(interestRate),
      paymentMode: Value(paymentMode),
      referenceNo: Value(
        referenceNo?.trim().isNotEmpty == true ? referenceNo!.trim() : null,
      ),
      description: Value(
        description?.trim().isNotEmpty == true ? description!.trim() : null,
      ),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.insertTransaction(txnCompanion);

    // Insert line items if any
    final savedLineItems = <TransactionLineItem>[];
    if (lineItems != null && lineItems.isNotEmpty) {
      final lineCompanions = lineItems.map((item) {
        return TransactionLineItemsCompanion(
          id: Value(_uuid.v4()),
          transactionId: Value(txnId),
          description: Value(item['description'] as String),
          quantity: Value((item['quantity'] as num?)?.toDouble() ?? 1.0),
          rate: Value((item['rate'] as num?)?.toDouble() ?? 0.0),
          amount: Value((item['amount'] as num).toDouble()),
        );
      }).toList();
      await _db.replaceLineItems(txnId, lineCompanions);
      savedLineItems.addAll(await _db.getLineItemsForTransaction(txnId));
    }

    // Insert payment details if any
    PaymentDetail? savedPaymentDetail;
    if (paymentDetails != null && paymentDetails.isNotEmpty) {
      final payCompanion = PaymentDetailsCompanion(
        id: Value(_uuid.v4()),
        transactionId: Value(txnId),
        paymentMode: Value(paymentMode),
        referenceNo: Value(paymentDetails['referenceNo']),
        utrNo: Value(paymentDetails['utrNo']),
        bankName: Value(paymentDetails['bankName']),
        chequeNo: Value(paymentDetails['chequeNo']),
        notes: Value(paymentDetails['notes']),
      );
      await _db.setPaymentDetail(payCompanion);
      savedPaymentDetail = await _db.getPaymentDetailForTransaction(txnId);
    }

    // If upfront payment was made during sale, create linked paymentReceived transaction
    if (type == TransactionType.sale &&
        upfrontPaidAmount != null &&
        upfrontPaidAmount > 0) {
      final paySeq = await _db.getAndIncrementSeq();
      final payTxnId = _uuid.v4();
      final payTxnNo = '${settings.receiptPrefix}$paySeq';

      await _db.insertTransaction(
        TransactionsCompanion(
          id: Value(payTxnId),
          transactionNo: Value(payTxnNo),
          partyId: Value(partyId),
          date: Value(date),
          type: Value(TransactionType.paymentReceived.name),
          amount: Value(upfrontPaidAmount),
          debit: const Value(0.0),
          credit: Value(upfrontPaidAmount),
          paymentMode: Value(upfrontPaymentMode ?? paymentMode ?? 'Cash'),
          referenceNo: Value(upfrontReferenceNo),
          description: Value('Immediate payment for $txnNo'),
          linkedTransactionId: Value(txnId),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      // Link payment to sale
      final currentTxn = await _db.getTransactionById(txnId);
      if (currentTxn != null) {
        await _db.updateTransaction(
          currentTxn.copyWith(linkedTransactionId: Value(payTxnId)),
        );
      }
    }

    // Notify AFTER all child records are fully committed
    onTransactionChanged(partyId);

    final createdTxn = (await _db.getTransactionById(txnId))!;
    return TransactionWithDetails(
      transaction: createdTxn,
      party: party,
      lineItems: savedLineItems,
      paymentDetail: savedPaymentDetail,
    );
  }

  Future<void> updateTransactionDetails({
    required String id,
    required DateTime date,
    required double amount,
    double? interestRate,
    String? paymentMode,
    String? referenceNo,
    String? description,
    List<Map<String, dynamic>>? lineItems,
    Map<String, String?>? paymentDetails,
  }) async {
    final existing = await _db.getTransactionById(id);
    if (existing == null) throw Exception('Transaction not found');

    final type = TransactionType.values.firstWhere(
      (t) => t.name == existing.type,
      orElse: () => TransactionType.sale,
    );
    final (debit, credit) = calculateDebitCredit(
      type,
      amount,
      isOpeningDebit: existing.debit > 0,
    );

    final updated = existing.copyWith(
      date: date,
      amount: amount,
      debit: debit,
      credit: credit,
      interestRate: Value(interestRate),
      paymentMode: Value(paymentMode),
      referenceNo: Value(
        referenceNo?.trim().isNotEmpty == true ? referenceNo!.trim() : null,
      ),
      description: Value(
        description?.trim().isNotEmpty == true ? description!.trim() : null,
      ),
      updatedAt: DateTime.now(),
    );

    await _db.updateTransaction(updated);

    if (lineItems != null) {
      final lineCompanions = lineItems.map((item) {
        return TransactionLineItemsCompanion(
          id: Value(_uuid.v4()),
          transactionId: Value(id),
          description: Value(item['description'] as String),
          quantity: Value((item['quantity'] as num?)?.toDouble() ?? 1.0),
          rate: Value((item['rate'] as num?)?.toDouble() ?? 0.0),
          amount: Value((item['amount'] as num).toDouble()),
        );
      }).toList();
      await _db.replaceLineItems(id, lineCompanions);
    }

    if (paymentDetails != null) {
      final payCompanion = PaymentDetailsCompanion(
        id: Value(_uuid.v4()),
        transactionId: Value(id),
        paymentMode: Value(paymentMode),
        referenceNo: Value(paymentDetails['referenceNo']),
        utrNo: Value(paymentDetails['utrNo']),
        bankName: Value(paymentDetails['bankName']),
        chequeNo: Value(paymentDetails['chequeNo']),
        notes: Value(paymentDetails['notes']),
      );
      await _db.setPaymentDetail(payCompanion);
    }

    // Notify AFTER all child records are fully committed
    onTransactionChanged(existing.partyId);
  }

  Future<TransactionWithDetails?> getTransactionDetails(String id) async {
    final txn = await _db.getTransactionById(id);
    if (txn == null) return null;

    final party = await _db.getPartyById(txn.partyId);
    if (party == null) return null;

    final lines = await _db.getLineItemsForTransaction(id);
    final payment = await _db.getPaymentDetailForTransaction(id);

    return TransactionWithDetails(
      transaction: txn,
      party: party,
      lineItems: lines,
      paymentDetail: payment,
    );
  }

  Future<void> deleteTransaction(String id) async {
    final existing = await _db.getTransactionById(id);
    await _db.softDeleteTransaction(id);
    if (existing?.linkedTransactionId != null) {
      await _db.softDeleteTransaction(existing!.linkedTransactionId!);
    }
    // Notify AFTER linked transaction is also deleted
    onTransactionChanged(existing?.partyId);
  }

  Future<void> restoreTransaction(String id) async {
    final existing = await _db.getTransactionById(id);
    await _db.restoreTransaction(id);
    if (existing?.linkedTransactionId != null) {
      await _db.restoreTransaction(existing!.linkedTransactionId!);
    }
    // Notify AFTER linked transaction is also restored
    onTransactionChanged(existing?.partyId);
  }

  Future<List<TransactionWithParty>> getRecentTransactionsWithParty(
    int limit,
  ) async {
    return _db.getRecentTransactionsWithParty(limit);
  }

  Future<List<TransactionWithParty>> getAllActiveTransactionsWithParty({
    String? typeFilter,
  }) async {
    return _db.getAllTransactionsWithParty(
      typeFilter: typeFilter,
      includeDeleted: false,
    );
  }

  Future<List<TransactionWithParty>> getDeletedTransactionsWithParty() async {
    return _db.getAllTransactionsWithParty(onlyDeleted: true);
  }

  Future<List<TransactionEntry>> getAllActiveTransactions({
    DateTime? fromDate,
    DateTime? toDate,
    String? partyId,
    String? typeFilter,
    int? limit,
  }) {
    return _db.getAllTransactions(
      fromDate: fromDate,
      toDate: toDate,
      partyId: partyId,
      typeFilter: typeFilter,
      limit: limit,
    );
  }

  Future<List<TransactionEntry>> getDeletedTransactions() {
    return _db.getDeletedTransactions();
  }
}
