import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_rukmini/core/database/database.dart';
import 'package:khata_rukmini/core/database/tables.dart';
import 'package:khata_rukmini/repositories/party_repository.dart';
import 'package:khata_rukmini/repositories/statement_repository.dart';
import 'package:khata_rukmini/repositories/transaction_repository.dart';

void main() {
  late AppDatabase db;
  late PartyRepository partyRepo;
  late TransactionRepository txnRepo;
  late StatementRepository stmtRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    partyRepo = PartyRepository(db, (_) {});
    txnRepo = TransactionRepository(db, (_) {});
    stmtRepo = StatementRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Ledger Engine & Mathematical Integrity', () {
    test(
      'Rule: Opening balance + Sale + Payment = Correct Running Balance',
      () async {
        // Create Customer with opening balance ₹10,000 Due (Dr)
        final customer = await partyRepo.createParty(
          name: 'Ahmed Khan',
          type: 'customer',
          phone: '9834472260',
          openingBalance: 10000.0,
        );

        // Verify opening balance
        var balance = await db.getPartyCurrentBalance(customer.id);
        expect(balance, equals(10000.0));

        // Record Sale of ₹20,000 (Debit) on Day 1
        final day1 = DateTime(2026, 8, 1);
        await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.sale,
          date: day1,
          amount: 20000.0,
          description: 'Gold Chain 22k',
        );

        balance = await db.getPartyCurrentBalance(customer.id);
        expect(balance, equals(30000.0)); // 10000 + 20000

        // Record Payment Received of ₹5,000 (Credit) on Day 2
        final day2 = DateTime(2026, 8, 2);
        await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.paymentReceived,
          date: day2,
          amount: 5000.0,
          paymentMode: 'UPI',
          referenceNo: 'UPI12345678',
        );

        balance = await db.getPartyCurrentBalance(customer.id);
        expect(balance, equals(25000.0)); // 30000 - 5000 = 25000 Dr
      },
    );

    test(
      'Rule: Supplier Purchases (Cr) and Payments Made (Dr) maintain correct payable balance',
      () async {
        // Create Supplier with ₹40,000 Payable (Cr -> negative net balance)
        final supplier = await partyRepo.createParty(
          name: 'ABC Bullion Supplier',
          type: 'supplier',
          phone: '9876543210',
          openingBalance: -40000.0, // Cr
        );

        var balance = await db.getPartyCurrentBalance(supplier.id);
        expect(balance, equals(-40000.0)); // Net -40000 (40000 Cr)

        // Shop pays ₹15,000 to supplier (Payment Made -> Debit)
        await txnRepo.createTransaction(
          partyId: supplier.id,
          type: TransactionType.paymentMade,
          date: DateTime(2026, 8, 10),
          amount: 15000.0,
          paymentMode: 'Bank Transfer',
        );

        balance = await db.getPartyCurrentBalance(supplier.id);
        expect(balance, equals(-25000.0)); // -40000 + 15000 = -25000 (25000 Cr)

        // Shop purchases ₹10,000 raw material (Purchase -> Credit)
        await txnRepo.createTransaction(
          partyId: supplier.id,
          type: TransactionType.purchase,
          date: DateTime(2026, 8, 15),
          amount: 10000.0,
        );

        balance = await db.getPartyCurrentBalance(supplier.id);
        expect(balance, equals(-35000.0)); // -25000 - 10000 = -35000 (35000 Cr)
      },
    );

    test(
      'Rule: Party marked as "Both" correctly unifies debit and credit into single net balance',
      () async {
        final artisan = await partyRepo.createParty(
          name: 'Suresh Goldsmith',
          type: 'both',
          phone: '9123456789',
        );

        // Sells gold ornament to artisan (Sale Dr ₹50,000)
        await txnRepo.createTransaction(
          partyId: artisan.id,
          type: TransactionType.sale,
          date: DateTime(2026, 8, 1),
          amount: 50000.0,
        );

        // Artisan supplies handcrafted rings to shop (Purchase Cr ₹30,000)
        await txnRepo.createTransaction(
          partyId: artisan.id,
          type: TransactionType.purchase,
          date: DateTime(2026, 8, 5),
          amount: 30000.0,
        );

        // Net balance should be 50000 - 30000 = 20000 Dr (Artisan owes shop 20,000)
        final balance = await db.getPartyCurrentBalance(artisan.id);
        expect(balance, equals(20000.0));
      },
    );

    test(
      'Rule: Backdated transactions are sequenced chronologically by date in statements',
      () async {
        final customer = await partyRepo.createParty(
          name: 'Chronology Test Party',
          type: 'customer',
        );

        // 1. Enter transaction for 20th August
        await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.sale,
          date: DateTime(2026, 8, 20),
          amount: 10000.0,
        );

        // 2. Backdate a transaction for 5th August
        await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.sale,
          date: DateTime(2026, 8, 5),
          amount: 5000.0,
        );

        // 3. Backdate a payment for 10th August
        await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.paymentReceived,
          date: DateTime(2026, 8, 10),
          amount: 2000.0,
        );

        // Retrieve statement for the month of August
        final stmt = await stmtRepo.getPartyStatement(
          partyId: customer.id,
          fromDate: DateTime(2026, 8, 1),
          toDate: DateTime(2026, 8, 31),
        );

        // Expected chronological sequence:
        // Row 1 (Aug 5): Sale 5000 -> Running Balance: 5000 Dr
        // Row 2 (Aug 10): Payment 2000 -> Running Balance: 3000 Dr
        // Row 3 (Aug 20): Sale 10000 -> Running Balance: 13000 Dr
        expect(stmt.rows.length, equals(3));

        expect(stmt.rows[0].date, equals(DateTime(2026, 8, 5)));
        expect(stmt.rows[0].runningBalance, equals(5000.0));

        expect(stmt.rows[1].date, equals(DateTime(2026, 8, 10)));
        expect(stmt.rows[1].runningBalance, equals(3000.0));

        expect(stmt.rows[2].date, equals(DateTime(2026, 8, 20)));
        expect(stmt.rows[2].runningBalance, equals(13000.0));

        expect(stmt.totalDebit, equals(15000.0));
        expect(stmt.totalCredit, equals(2000.0));
        expect(stmt.closingBalance, equals(13000.0));
      },
    );

    test(
      'Rule: Date filtering accurately computes Brought Forward (b/f) balance',
      () async {
        final customer = await partyRepo.createParty(
          name: 'Brought Forward Test',
          type: 'customer',
        );

        // July 15: Sale ₹15,000
        await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.sale,
          date: DateTime(2026, 7, 15),
          amount: 15000.0,
        );

        // July 25: Payment ₹5,000
        await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.paymentReceived,
          date: DateTime(2026, 7, 25),
          amount: 5000.0,
        );

        // August 10: Sale ₹10,000
        await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.sale,
          date: DateTime(2026, 8, 10),
          amount: 10000.0,
        );

        // Query statement for ONLY August (01 Aug to 31 Aug)
        final stmt = await stmtRepo.getPartyStatement(
          partyId: customer.id,
          fromDate: DateTime(2026, 8, 1),
          toDate: DateTime(2026, 8, 31),
        );

        // Prior balance before Aug 1 should be 15000 - 5000 = 10000 Dr
        expect(stmt.broughtForwardBalance, equals(10000.0));

        // Row 0 is Brought Forward Opening Balance
        expect(stmt.rows[0].isBroughtForward, isTrue);
        expect(stmt.rows[0].runningBalance, equals(10000.0));

        // Row 1 is August 10 sale
        expect(stmt.rows[1].date, equals(DateTime(2026, 8, 10)));
        expect(stmt.rows[1].debit, equals(10000.0));
        expect(stmt.rows[1].runningBalance, equals(20000.0));

        // Closing balance
        expect(stmt.closingBalance, equals(20000.0));
      },
    );

    test(
      'Rule: Integrated upfront payment creates linked entries with correct remaining balance',
      () async {
        final customer = await partyRepo.createParty(
          name: 'Upfront Payment Customer',
          type: 'customer',
        );

        // Customer buys jewelry worth ₹50,000 and pays ₹20,000 immediately
        await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.sale,
          date: DateTime(2026, 8, 1),
          amount: 50000.0,
          description: 'Diamond Ring',
          upfrontPaidAmount: 20000.0,
          upfrontPaymentMode: 'UPI',
          upfrontReferenceNo: 'UPI999888',
        );

        // Total balance owed should immediately be 50,000 - 20,000 = 30,000 Dr
        final balance = await db.getPartyCurrentBalance(customer.id);
        expect(balance, equals(30000.0));

        // Verify two transactions were created and linked
        final allTxns = await txnRepo.getAllActiveTransactions(
          partyId: customer.id,
        );
        expect(allTxns.length, equals(2));

        final saleTxn = allTxns.firstWhere((t) => t.type == 'sale');
        final payTxn = allTxns.firstWhere((t) => t.type == 'paymentReceived');

        expect(saleTxn.amount, equals(50000.0));
        expect(payTxn.amount, equals(20000.0));
        expect(payTxn.linkedTransactionId, equals(saleTxn.id));
        expect(saleTxn.linkedTransactionId, equals(payTxn.id));
      },
    );

    test(
      'Rule: Soft-deleting transaction updates balance immediately; restore re-applies it',
      () async {
        final customer = await partyRepo.createParty(
          name: 'Delete Safety Party',
          type: 'customer',
        );

        final txn = await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.sale,
          date: DateTime(2026, 8, 1),
          amount: 15000.0,
        );

        var balance = await db.getPartyCurrentBalance(customer.id);
        expect(balance, equals(15000.0));

        // Soft delete
        await txnRepo.deleteTransaction(txn.transaction.id);

        // Balance must immediately recalculate to 0
        balance = await db.getPartyCurrentBalance(customer.id);
        expect(balance, equals(0.0));

        // Transaction must appear in Recycle Bin
        final deleted = await txnRepo.getDeletedTransactions();
        expect(deleted.length, equals(1));
        expect(deleted.first.id, equals(txn.transaction.id));

        // Restore transaction
        await txnRepo.restoreTransaction(txn.transaction.id);

        // Balance must return to 15000.0
        balance = await db.getPartyCurrentBalance(customer.id);
        expect(balance, equals(15000.0));
      },
    );

    test(
      'getBalanceBeforeTransaction subtracts debits, adds credits',
      () async {
        // Opening balance ₹10,000 Dr → current balance = 10000
        final customer = await partyRepo.createParty(
          name: 'Balance Test',
          type: 'customer',
          openingBalance: 10000.0,
        );

        // Sale of ₹5,000 (Dr) → current = 15000
        // Before this sale: 10000 (Dr)
        final sale = await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.sale,
          date: DateTime(2026, 8, 1),
          amount: 5000.0,
        );
        expect(
          await txnRepo.getBalanceBeforeTransaction(
            customer.id,
            sale.transaction.id,
          ),
          equals(10000.0),
        );
        expect(await db.getPartyCurrentBalance(customer.id), equals(15000.0));

        // Payment Received of ₹2,000 (Cr) → current = 13000
        // Before this payment: 15000 (Dr)
        final payment = await txnRepo.createTransaction(
          partyId: customer.id,
          type: TransactionType.paymentReceived,
          date: DateTime(2026, 8, 2),
          amount: 2000.0,
        );
        expect(
          await txnRepo.getBalanceBeforeTransaction(
            customer.id,
            payment.transaction.id,
          ),
          equals(15000.0),
        );
        expect(await db.getPartyCurrentBalance(customer.id), equals(13000.0));
      },
    );

    test(
      'getBalanceBeforeTransaction works for paymentMade (debit direction)',
      () async {
        // Supplier opening -₹10,000 (Cr) → current balance = -10000
        final supplier = await partyRepo.createParty(
          name: 'Supplier X',
          type: 'supplier',
          openingBalance: -10000.0,
        );

        // Payment Made of ₹3,000 (Dr) → current = -7000
        // Before this payment: -10000 (Cr)
        // getBalanceBeforeTransaction must add the debit amount back
        final payment = await txnRepo.createTransaction(
          partyId: supplier.id,
          type: TransactionType.paymentMade,
          date: DateTime(2026, 8, 1),
          amount: 3000.0,
        );
        expect(
          await txnRepo.getBalanceBeforeTransaction(
            supplier.id,
            payment.transaction.id,
          ),
          equals(-10000.0),
        );
      },
    );
  });
}
