import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import 'services/lockout_service.dart';
import '../repositories/party_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/statement_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/backup/backup_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final partyRepositoryProvider = Provider<PartyRepository>((ref) {
  return PartyRepository(ref.watch(databaseProvider), (partyId) {
    ref.invalidate(partiesListProvider);
    ref.invalidate(dashboardStatsProvider);
    if (partyId != null) ref.invalidate(partyProfileProvider(partyId));
  });
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  Timer? debouncer;
  return TransactionRepository(ref.watch(databaseProvider), (partyId) {
    debouncer?.cancel();
    debouncer = Timer(const Duration(milliseconds: 50), () {
      ref.invalidate(partiesListProvider);
      ref.invalidate(dashboardStatsProvider);
      if (partyId != null) ref.invalidate(partyProfileProvider(partyId));
    });
  });
});

final lockoutServiceProvider = Provider<LockoutService>((ref) {
  return LockoutService(ref.watch(sharedPreferencesProvider));
});

final statementRepositoryProvider = Provider<StatementRepository>((ref) {
  return StatementRepository(ref.watch(databaseProvider));
});
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider), () {
    ref.invalidate(shopSettingsProvider);
  });
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(settingsRepositoryProvider));
});

/// Shop Settings state
final FutureProvider<ShopSetting> shopSettingsProvider =
    FutureProvider<ShopSetting>((ref) async {
      return ref.watch(settingsRepositoryProvider).getSettings();
    });

/// Parties with balances
final FutureProviderFamily<List<PartyWithBalance>, String?>
partiesListProvider = FutureProvider.family<List<PartyWithBalance>, String?>((
  ref,
  typeFilter,
) async {
  return ref
      .watch(partyRepositoryProvider)
      .getPartiesWithBalances(typeFilter: typeFilter);
});

/// Party Profile Data (Party with balance + recent active transactions)
final FutureProviderFamily<(PartyWithBalance?, List<TransactionEntry>), String>
partyProfileProvider =
    FutureProvider.family<(PartyWithBalance?, List<TransactionEntry>), String>((
      ref,
      partyId,
    ) async {
      final partyRepo = ref.watch(partyRepositoryProvider);
      final txnRepo = ref.watch(transactionRepositoryProvider);
      final party = await partyRepo.getPartyWithBalance(partyId);
      final txns = await txnRepo.getAllActiveTransactions(
        partyId: partyId,
        limit: 30,
      );
      return (party, txns);
    });

/// Dashboard Statistics
class DashboardStats {
  final int customerCount;
  final int supplierCount;
  final double customerOutstanding;
  final double supplierOutstanding;
  final int todayTxnCount;
  final double todayPaymentsReceived;
  final double todayPaymentsMade;
  final List<TransactionWithParty> recentTransactions;

  DashboardStats({
    required this.customerCount,
    required this.supplierCount,
    required this.customerOutstanding,
    required this.supplierOutstanding,
    required this.todayTxnCount,
    required this.todayPaymentsReceived,
    required this.todayPaymentsMade,
    required this.recentTransactions,
  });
}

final FutureProvider<DashboardStats> dashboardStatsProvider =
    FutureProvider<DashboardStats>((ref) async {
      final partyRepo = ref.watch(partyRepositoryProvider);
      final txnRepo = ref.watch(transactionRepositoryProvider);

      final parties = await partyRepo.getPartiesWithBalances();

      int custCount = 0;
      int suppCount = 0;
      double custOutstanding = 0.0; // Sum of positive Dr for customers
      double suppOutstanding =
          0.0; // Sum of negative Cr (as positive liability) for suppliers

      for (final p in parties) {
        if (p.party.type == 'customer' || p.party.type == 'both') {
          custCount++;
          if (p.currentBalance > 0) {
            custOutstanding += p.currentBalance;
          }
        }
        if (p.party.type == 'supplier' || p.party.type == 'both') {
          suppCount++;
          if (p.currentBalance < 0) {
            suppOutstanding += p.currentBalance.abs();
          }
        }
      }

      // Today's boundaries
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
        999,
      );

      final todayTxns = await txnRepo.getAllActiveTransactions(
        fromDate: startOfToday,
        toDate: endOfToday,
      );

      double rec = 0.0;
      double paid = 0.0;

      for (final t in todayTxns) {
        if (t.type == 'paymentReceived') {
          rec += t.amount;
        } else if (t.type == 'paymentMade') {
          paid += t.amount;
        }
      }

      final recent = await txnRepo.getRecentTransactionsWithParty(10);

      return DashboardStats(
        customerCount: custCount,
        supplierCount: suppCount,
        customerOutstanding: custOutstanding,
        supplierOutstanding: suppOutstanding,
        todayTxnCount: todayTxns.length,
        todayPaymentsReceived: rec,
        todayPaymentsMade: paid,
        recentTransactions: recent,
      );
    });

// Auth State

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(sharedPreferencesProvider).getBool('isLoggedIn') ?? false;
  }

  void login() {
    state = true;
    ref.read(sharedPreferencesProvider).setBool('isLoggedIn', true);
  }

  void logout() {
    state = false;
    ref.read(sharedPreferencesProvider).setBool('isLoggedIn', false);
    ref.read(pinUnlockedProvider.notifier).lock();
  }
}

final isLoggedInProvider = NotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class PinUnlockedNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Lock by default on launch
  }

  void unlock() {
    state = true;
  }

  void lock() {
    state = false;
  }
}

final pinUnlockedProvider = NotifierProvider<PinUnlockedNotifier, bool>(
  PinUnlockedNotifier.new,
);
