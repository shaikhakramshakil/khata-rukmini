import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khata_rukmini/core/database/database.dart';
import 'package:khata_rukmini/core/database/tables.dart';
import 'package:khata_rukmini/core/services/lockout_service.dart';
import 'package:khata_rukmini/core/utils/security_service.dart';
import 'package:khata_rukmini/repositories/party_repository.dart';
import 'package:khata_rukmini/repositories/transaction_repository.dart';

void main() {
  group('SecurityService Tests', () {
    test('hashes secret with salt and verifies correctly', () {
      const pin = '1234';
      final hash = SecurityService.hashSecret(pin);

      expect(hash.startsWith('sha256:'), isTrue);

      final result = SecurityService.verifySecret(pin, hash);
      expect(result.isValid, isTrue);
      expect(result.needsMigration, isFalse);

      final wrongResult = SecurityService.verifySecret('9999', hash);
      expect(wrongResult.isValid, isFalse);
    });

    test(
      'transparently verifies legacy plaintext and flags needsMigration',
      () {
        const legacyPin = '4321';
        final result = SecurityService.verifySecret(legacyPin, legacyPin);

        expect(result.isValid, isTrue);
        expect(result.needsMigration, isTrue);
      },
    );

    test('handles empty or null stored secret safely', () {
      expect(SecurityService.verifySecret('1234', null).isValid, isFalse);
      expect(SecurityService.verifySecret('1234', '').isValid, isFalse);
    });
  });

  group('LockoutService Scoped Rate-Limiting Tests', () {
    late SharedPreferences prefs;
    late LockoutService lockout;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      lockout = LockoutService(prefs);
    });

    test('increments failure counter and locks out on 5th attempt', () async {
      const scope = 'pin_unlock';

      expect(lockout.isLockedOut(scope), isFalse);

      for (int i = 1; i <= 4; i++) {
        final locked = await lockout.recordFailure(scope);
        expect(locked, isFalse);
        expect(lockout.isLockedOut(scope), isFalse);
        expect(lockout.getFailedAttempts(scope), equals(i));
      }

      final locked = await lockout.recordFailure(scope);
      expect(locked, isTrue);
      expect(lockout.isLockedOut(scope), isTrue);
      expect(lockout.getRemainingSeconds(scope), greaterThan(0));
    });

    test(
      'maintains independent scopes between admin_login and pin_unlock',
      () async {
        const pinScope = 'pin_unlock';
        const loginScope = 'admin_login';

        for (int i = 0; i < 5; i++) {
          await lockout.recordFailure(pinScope);
        }

        expect(lockout.isLockedOut(pinScope), isTrue);
        expect(lockout.isLockedOut(loginScope), isFalse);
        expect(lockout.getFailedAttempts(loginScope), equals(0));
      },
    );

    test('recordSuccess clears failed attempts and lockout', () async {
      const scope = 'admin_login';
      await lockout.recordFailure(scope);
      await lockout.recordFailure(scope);
      expect(lockout.getFailedAttempts(scope), equals(2));

      await lockout.recordSuccess(scope);
      expect(lockout.getFailedAttempts(scope), equals(0));
      expect(lockout.isLockedOut(scope), isFalse);
    });
  });

  group('TransactionRepository getBalanceBeforeTransaction Tests', () {
    late AppDatabase db;
    late PartyRepository partyRepo;
    late TransactionRepository txnRepo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      partyRepo = PartyRepository(db, (_) {});
      txnRepo = TransactionRepository(db, (_) {});
    });

    tearDown(() async {
      await db.close();
    });

    test('calculates accurate previousBalance before a sale', () async {
      final party = await partyRepo.createParty(
        name: 'Test Customer',
        type: 'customer',
        openingBalance: 1000.0,
      );

      final sale = await txnRepo.createTransaction(
        partyId: party.id,
        type: TransactionType.sale,
        amount: 500.0,
        date: DateTime.now(),
      );

      final prevBal = await txnRepo.getBalanceBeforeTransaction(
        party.id,
        sale.transaction.id,
      );

      // Opening balance is 1000 Dr. Current balance after 500 sale is 1500 Dr.
      // Balance before the sale was 1000 Dr.
      expect(prevBal, equals(1000.0));
    });
  });
}
