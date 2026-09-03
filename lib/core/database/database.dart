import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

class PartyWithBalance {
  final Party party;
  final double currentBalance;
  final DateTime? lastTransactionDate;

  PartyWithBalance({
    required this.party,
    required this.currentBalance,
    this.lastTransactionDate,
  });
}

class TransactionWithParty {
  final TransactionEntry transaction;
  final Party party;
  TransactionWithParty(this.transaction, this.party);
}

@DriftDatabase(
  tables: [
    Parties,
    Transactions,
    TransactionLineItems,
    PaymentDetails,
    ShopSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insert initial default shop settings
        await into(shopSettings).insert(
          const ShopSettingsCompanion(
            shopName: Value('Rukmini Jewellers'),
            address: Value('Main Road, Jewellers Street'),
            phone: Value('+91 98765 43210'),
            invoicePrefix: Value('INV-'),
            receiptPrefix: Value('REC-'),
            txnPrefix: Value('TXN-'),
            nextSeq: Value(1001),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(shopSettings, shopSettings.appPin);
        }
        if (from < 3) {
          await m.addColumn(parties, parties.interestRate);
          await m.addColumn(transactions, transactions.interestRate);
        }
        if (from < 4) {
          await m.addColumn(transactionLineItems, transactionLineItems.unit);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // --- Parties Queries ---

  Future<List<Party>> getAllActiveParties({String? typeFilter}) {
    final query = select(parties)..where((tbl) => tbl.deletedAt.isNull());
    if (typeFilter != null && typeFilter.isNotEmpty && typeFilter != 'all') {
      if (typeFilter == 'customer') {
        query.where(
          (tbl) => tbl.type.equals('customer') | tbl.type.equals('both'),
        );
      } else if (typeFilter == 'supplier') {
        query.where(
          (tbl) => tbl.type.equals('supplier') | tbl.type.equals('both'),
        );
      } else {
        query.where((tbl) => tbl.type.equals(typeFilter));
      }
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.get();
  }

  Future<Party?> getPartyById(String id) {
    return (select(
      parties,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<List<PartyWithBalance>> getPartiesWithBalancesOptimized({
    String? typeFilter,
  }) async {
    final drSum = transactions.debit.sum();
    final crSum = transactions.credit.sum();
    final maxDate = transactions.date.max();

    final query = select(parties).join([
      leftOuterJoin(
        transactions,
        transactions.partyId.equalsExp(parties.id) &
            transactions.deletedAt.isNull(),
      ),
    ])..where(parties.deletedAt.isNull());

    if (typeFilter != null && typeFilter.isNotEmpty && typeFilter != 'all') {
      if (typeFilter == 'customer') {
        query.where(
          parties.type.equals('customer') | parties.type.equals('both'),
        );
      } else if (typeFilter == 'supplier') {
        query.where(
          parties.type.equals('supplier') | parties.type.equals('both'),
        );
      } else {
        query.where(parties.type.equals(typeFilter));
      }
    }

    query
      ..addColumns([drSum, crSum, maxDate])
      ..groupBy([parties.id]);

    final rows = await query.get();

    return rows.map((row) {
      final party = row.readTable(parties);
      final dr = row.read(drSum) ?? 0.0;
      final cr = row.read(crSum) ?? 0.0;
      final lastDate = row.read(maxDate);

      return PartyWithBalance(
        party: party,
        currentBalance: dr - cr,
        lastTransactionDate: lastDate,
      );
    }).toList();
  }

  Future<PartyWithBalance?> getPartyWithBalanceOptimized(String id) async {
    final drSum = transactions.debit.sum();
    final crSum = transactions.credit.sum();
    final maxDate = transactions.date.max();

    final query =
        select(parties).join([
            leftOuterJoin(
              transactions,
              transactions.partyId.equalsExp(parties.id) &
                  transactions.deletedAt.isNull(),
            ),
          ])
          ..where(parties.id.equals(id) & parties.deletedAt.isNull())
          ..addColumns([drSum, crSum, maxDate])
          ..groupBy([parties.id]);

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final party = row.readTable(parties);
    final dr = row.read(drSum) ?? 0.0;
    final cr = row.read(crSum) ?? 0.0;
    final lastDate = row.read(maxDate);

    return PartyWithBalance(
      party: party,
      currentBalance: dr - cr,
      lastTransactionDate: lastDate,
    );
  }

  Future<int> insertParty(PartiesCompanion entry) {
    return into(parties).insert(entry);
  }

  Future<bool> updateParty(Party entry) {
    return update(parties).replace(entry);
  }

  Future<int> softDeleteParty(String id) {
    return (update(parties)..where((tbl) => tbl.id.equals(id))).write(
      PartiesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> restoreParty(String id) {
    return (update(parties)..where((tbl) => tbl.id.equals(id))).write(
      const PartiesCompanion(deletedAt: Value(null)),
    );
  }

  // --- Transactions Queries ---

  /// Get active transactions for a party sorted chronologically (date ASC, createdAt ASC, id ASC)
  Future<List<TransactionEntry>> getPartyTransactionsChronological(
    String partyId,
  ) {
    return (select(transactions)
          ..where((tbl) => tbl.partyId.equals(partyId) & tbl.deletedAt.isNull())
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.date),
            (tbl) => OrderingTerm.asc(tbl.createdAt),
            (tbl) => OrderingTerm.asc(tbl.id),
          ]))
        .get();
  }

  /// Get active transactions for a party within date range
  Future<List<TransactionEntry>> getPartyTransactionsInDateRange(
    String partyId,
    DateTime fromDate,
    DateTime toDate,
  ) {
    return (select(transactions)
          ..where(
            (tbl) =>
                tbl.partyId.equals(partyId) &
                tbl.deletedAt.isNull() &
                tbl.date.isBiggerOrEqualValue(fromDate) &
                tbl.date.isSmallerOrEqualValue(toDate),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.date),
            (tbl) => OrderingTerm.asc(tbl.createdAt),
            (tbl) => OrderingTerm.asc(tbl.id),
          ]))
        .get();
  }

  /// Calculates net accumulated balance prior to a given date for Brought Forward (b/f)
  Future<double> getPartyBalancePriorToDate(
    String partyId,
    DateTime date,
  ) async {
    final drSum = transactions.debit.sum();
    final crSum = transactions.credit.sum();
    final query = selectOnly(transactions)
      ..addColumns([drSum, crSum])
      ..where(
        transactions.partyId.equals(partyId) &
            transactions.deletedAt.isNull() &
            transactions.date.isSmallerThanValue(date),
      );
    final row = await query.getSingle();
    final totalDr = row.read(drSum) ?? 0.0;
    final totalCr = row.read(crSum) ?? 0.0;
    return totalDr - totalCr;
  }

  /// Calculates current net balance for a party: totalDr - totalCr
  Future<double> getPartyCurrentBalance(String partyId) async {
    final drSum = transactions.debit.sum();
    final crSum = transactions.credit.sum();
    final query = selectOnly(transactions)
      ..addColumns([drSum, crSum])
      ..where(
        transactions.partyId.equals(partyId) & transactions.deletedAt.isNull(),
      );
    final row = await query.getSingle();
    final totalDr = row.read(drSum) ?? 0.0;
    final totalCr = row.read(crSum) ?? 0.0;
    return totalDr - totalCr;
  }

  /// Calculates the party balance as of just before a specific transaction.
  /// Sums (debit - credit) for all active transactions that were created
  /// strictly before [createdAt], or at the same [createdAt] but with a
  /// lexicographically earlier ID (for deterministic ordering of ties).
  Future<double> getPartyBalanceBefore(
    String partyId,
    DateTime createdAt,
    String transactionId,
  ) async {
    final drSum = transactions.debit.sum();
    final crSum = transactions.credit.sum();
    
    final targetRowIdExpr = subqueryExpression<int>(
      selectOnly(transactions)
        ..addColumns([transactions.rowId])
        ..where(transactions.id.equals(transactionId)),
    );

    final query = selectOnly(transactions)
      ..addColumns([drSum, crSum])
      ..where(
        transactions.partyId.equals(partyId) &
            transactions.deletedAt.isNull() &
            (transactions.createdAt.isSmallerThanValue(createdAt) |
                (transactions.createdAt.equals(createdAt) &
                    transactions.rowId.isSmallerThan(targetRowIdExpr))),
      );
    final row = await query.getSingle();
    final totalDr = row.read(drSum) ?? 0.0;
    final totalCr = row.read(crSum) ?? 0.0;
    return totalDr - totalCr;
  }

  /// Get all active transactions across the system

  Future<List<TransactionWithParty>> getRecentTransactionsWithParty(
    int maxLimit,
  ) async {
    final query =
        select(transactions).join([
            innerJoin(
              parties,
              parties.id.equalsExp(transactions.partyId) &
                  parties.deletedAt.isNull(),
            ),
          ])
          ..where(transactions.deletedAt.isNull())
          ..orderBy([
            OrderingTerm.desc(transactions.date),
            OrderingTerm.desc(transactions.createdAt),
          ])
          ..limit(maxLimit);

    final rows = await query.get();
    return rows.map((row) {
      return TransactionWithParty(
        row.readTable(transactions),
        row.readTable(parties),
      );
    }).toList();
  }

  Future<List<TransactionWithParty>> getAllTransactionsWithParty({
    String? typeFilter,
    bool includeDeleted = false,
    bool onlyDeleted = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query =
        select(transactions).join([
          innerJoin(
            parties,
            parties.id.equalsExp(transactions.partyId) &
                parties.deletedAt.isNull(),
          ),
        ])..orderBy([
          OrderingTerm.desc(transactions.date),
          OrderingTerm.desc(transactions.createdAt),
        ]);

    if (onlyDeleted) {
      query.where(transactions.deletedAt.isNotNull());
    } else if (!includeDeleted) {
      query.where(transactions.deletedAt.isNull());
    }

    if (typeFilter != null && typeFilter.isNotEmpty && typeFilter != 'all') {
      query.where(transactions.type.equals(typeFilter));
    }

    if (startDate != null) {
      query.where(transactions.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(transactions.date.isSmallerOrEqualValue(endDate));
    }

    final rows = await query.get();
    return rows.map((row) {
      return TransactionWithParty(
        row.readTable(transactions),
        row.readTable(parties),
      );
    }).toList();
  }

  Future<List<TransactionWithParty>> getGeneralLedgerTransactions(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final query =
        select(transactions).join([
            innerJoin(
              parties,
              parties.id.equalsExp(transactions.partyId) &
                  parties.deletedAt.isNull(),
            ),
          ])
          ..where(
            transactions.deletedAt.isNull() &
                transactions.date.isBiggerOrEqualValue(fromDate) &
                transactions.date.isSmallerOrEqualValue(toDate),
          )
          ..orderBy([
            OrderingTerm.asc(transactions.date),
            OrderingTerm.asc(transactions.createdAt),
            OrderingTerm.asc(transactions.id),
          ]);

    final rows = await query.get();
    return rows.map((row) {
      return TransactionWithParty(
        row.readTable(transactions),
        row.readTable(parties),
      );
    }).toList();
  }

  Future<List<TransactionEntry>> getAllTransactions({
    DateTime? fromDate,
    DateTime? toDate,
    String? partyId,
    String? typeFilter,
    int? limit,
  }) {
    final query = select(transactions)..where((tbl) => tbl.deletedAt.isNull());
    if (partyId != null && partyId.isNotEmpty) {
      query.where((tbl) => tbl.partyId.equals(partyId));
    }
    if (fromDate != null) {
      query.where((tbl) => tbl.date.isBiggerOrEqualValue(fromDate));
    }
    if (toDate != null) {
      query.where((tbl) => tbl.date.isSmallerOrEqualValue(toDate));
    }
    if (typeFilter != null && typeFilter.isNotEmpty && typeFilter != 'all') {
      query.where((tbl) => tbl.type.equals(typeFilter));
    }
    query.orderBy([
      (tbl) => OrderingTerm.desc(tbl.date),
      (tbl) => OrderingTerm.desc(tbl.createdAt),
    ]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  /// Get soft-deleted transactions for Recycle Bin
  Future<List<TransactionEntry>> getDeletedTransactions() {
    return (select(transactions)
          ..where((tbl) => tbl.deletedAt.isNotNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.deletedAt)]))
        .get();
  }

  Future<TransactionEntry?> getTransactionById(String id) {
    return (select(
      transactions,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTransaction(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }

  Future<bool> updateTransaction(TransactionEntry entry) {
    return update(transactions).replace(entry);
  }

  Future<int> softDeleteTransaction(String id) {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> restoreTransaction(String id) {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // --- Line Items Queries ---
  Future<List<TransactionLineItem>> getLineItemsForTransaction(
    String transactionId,
  ) {
    return (select(
      transactionLineItems,
    )..where((tbl) => tbl.transactionId.equals(transactionId))).get();
  }

  Future<void> replaceLineItems(
    String transactionId,
    List<TransactionLineItemsCompanion> items,
  ) async {
    await transaction(() async {
      await (delete(
        transactionLineItems,
      )..where((tbl) => tbl.transactionId.equals(transactionId))).go();
      for (final item in items) {
        await into(transactionLineItems).insert(item);
      }
    });
  }

  // --- Payment Details Queries ---
  Future<PaymentDetail?> getPaymentDetailForTransaction(String transactionId) {
    return (select(paymentDetails)
          ..where((tbl) => tbl.transactionId.equals(transactionId)))
        .getSingleOrNull();
  }

  Future<void> setPaymentDetail(PaymentDetailsCompanion detail) async {
    final existing =
        await (select(paymentDetails)..where(
              (tbl) => tbl.transactionId.equals(detail.transactionId.value),
            ))
            .getSingleOrNull();
    if (existing != null) {
      await (update(
        paymentDetails,
      )..where((tbl) => tbl.id.equals(existing.id))).write(detail);
    } else {
      await into(paymentDetails).insert(detail);
    }
  }

  // --- Shop Settings Queries ---
  Future<ShopSetting> getShopSettings() async {
    final setting = await (select(shopSettings)..limit(1)).getSingleOrNull();
    if (setting != null) return setting;
    // Fallback if empty
    await into(shopSettings).insert(const ShopSettingsCompanion());
    return (select(shopSettings)..limit(1)).getSingle();
  }

  Future<int> updateShopSettings(ShopSettingsCompanion setting) {
    return (update(
      shopSettings,
    )..where((tbl) => tbl.id.equals(1))).write(setting);
  }

  /// Atomically gets and increments the next sequence number for transactions/invoices
  Future<int> getAndIncrementSeq() async {
    return transaction(() async {
      final s = await getShopSettings();
      final current = s.nextSeq;
      await (update(shopSettings)..where((tbl) => tbl.id.equals(s.id))).write(
        ShopSettingsCompanion(nextSeq: Value(current + 1)),
      );
      return current;
    });
  }

  // --- Global Search Queries ---
  Future<List<Party>> searchParties(String query) {
    final q = '%${query.trim()}%';
    return (select(parties)
          ..where(
            (tbl) =>
                tbl.deletedAt.isNull() &
                (tbl.name.like(q) | tbl.phone.like(q) | tbl.address.like(q)),
          )
          ..limit(20))
        .get();
  }

  Future<List<TransactionEntry>> searchTransactions(String query) {
    final q = '%${query.trim()}%';
    return (select(transactions)
          ..where(
            (tbl) =>
                tbl.deletedAt.isNull() &
                (tbl.transactionNo.like(q) |
                    tbl.referenceNo.like(q) |
                    tbl.description.like(q)),
          )
          ..limit(20))
        .get();
  }

  Future<List<PaymentDetail>> searchPaymentDetails(String query) {
    final q = '%${query.trim()}%';
    return (select(paymentDetails)
          ..where(
            (tbl) =>
                tbl.referenceNo.like(q) |
                tbl.utrNo.like(q) |
                tbl.chequeNo.like(q) |
                tbl.bankName.like(q),
          )
          ..limit(20))
        .get();
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationSupportDirectory();
      final file = File(p.join(dbFolder.path, 'jewelry_khata.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
