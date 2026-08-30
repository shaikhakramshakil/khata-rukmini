import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database.dart';
import '../core/database/tables.dart';

class PartyRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  final void Function(String? partyId) onPartyChanged;

  PartyRepository(this._db, this.onPartyChanged);

  Future<List<PartyWithBalance>> getPartiesWithBalances({
    String? typeFilter,
  }) async {
    return await _db.getPartiesWithBalancesOptimized(typeFilter: typeFilter);
  }

  Future<PartyWithBalance?> getPartyWithBalance(String id) async {
    return await _db.getPartyWithBalanceOptimized(id);
  }

  Future<Party> createParty({
    required String name,
    required String type, // 'customer', 'supplier', 'both'
    String? phone,
    String? address,
    String? notes,
    double? interestRate,
    double? openingBalance, // if > 0 opening debit, if < 0 opening credit
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = PartiesCompanion(
      id: Value(id),
      name: Value(name.trim()),
      type: Value(type),
      phone: Value(phone?.trim().isNotEmpty == true ? phone!.trim() : null),
      address: Value(
        address?.trim().isNotEmpty == true ? address!.trim() : null,
      ),
      notes: Value(notes?.trim().isNotEmpty == true ? notes!.trim() : null),
      interestRate: Value(interestRate),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.insertParty(companion);

    // If an opening balance is specified, create an opening balance transaction
    if (openingBalance != null && openingBalance != 0) {
      final double absAmount = openingBalance.abs();
      double debit = 0;
      double credit = 0;

      if (openingBalance > 0) {
        // Party owes shop (Dr)
        debit = absAmount;
      } else {
        // Shop owes party (Cr)
        credit = absAmount;
      }

      await _db.insertTransaction(
        TransactionsCompanion(
          id: Value(_uuid.v4()),
          transactionNo: Value(
            'OPN-${now.millisecondsSinceEpoch.toString().substring(7)}',
          ),
          partyId: Value(id),
          date: Value(now),
          type: Value(TransactionType.openingBalance.name),
          amount: Value(absAmount),
          debit: Value(debit),
          credit: Value(credit),
          description: const Value('Opening Balance'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    // Notify AFTER opening balance transaction is also committed
    onPartyChanged(id);

    return (await _db.getPartyById(id))!;
  }

  Future<void> updatePartyDetails({
    required String id,
    required String name,
    required String type,
    String? phone,
    String? address,
    String? notes,
    double? interestRate,
  }) async {
    final existing = await _db.getPartyById(id);
    if (existing == null) return;

    await _db.updateParty(
      existing.copyWith(
        name: name.trim(),
        type: type,
        phone: Value(phone?.trim().isNotEmpty == true ? phone!.trim() : null),
        address: Value(
          address?.trim().isNotEmpty == true ? address!.trim() : null,
        ),
        notes: Value(notes?.trim().isNotEmpty == true ? notes!.trim() : null),
        interestRate: Value(interestRate),
        updatedAt: DateTime.now(),
      ),
    );
    onPartyChanged(id);
  }

  Future<void> deleteParty(String id) async {
    await _db.softDeleteParty(id);
    onPartyChanged(id);
  }
}
