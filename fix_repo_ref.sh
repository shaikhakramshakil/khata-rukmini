#!/bin/bash
# add import flutter_riverpod if not there
for f in lib/repositories/*.dart; do
    if ! grep -q "import 'package:flutter_riverpod/flutter_riverpod.dart';" "$f"; then
        sed -i '1s/^/import '\''package:flutter_riverpod\/flutter_riverpod.dart'\'';\n/' "$f"
    fi
done

# PartyRepository
sed -i 's/PartyRepository(this._db);/final Ref _ref;\n\n  PartyRepository(this._db, this._ref);/' lib/repositories/party_repository.dart
# TransactionRepository
sed -i 's/TransactionRepository(this._db);/final Ref _ref;\n\n  TransactionRepository(this._db, this._ref);/' lib/repositories/transaction_repository.dart
# SettingsRepository
sed -i 's/SettingsRepository(this._db);/final Ref _ref;\n\n  SettingsRepository(this._db, this._ref);/' lib/repositories/settings_repository.dart
# StatementRepository (if it needs it)
sed -i 's/StatementRepository(this._db);/final Ref _ref;\n\n  StatementRepository(this._db, this._ref);/' lib/repositories/statement_repository.dart

# update providers.dart
sed -i 's/PartyRepository(ref.watch(databaseProvider))/PartyRepository(ref.watch(databaseProvider), ref)/g' lib/core/providers.dart
sed -i 's/TransactionRepository(ref.watch(databaseProvider))/TransactionRepository(ref.watch(databaseProvider), ref)/g' lib/core/providers.dart
sed -i 's/SettingsRepository(ref.watch(databaseProvider))/SettingsRepository(ref.watch(databaseProvider), ref)/g' lib/core/providers.dart
sed -i 's/StatementRepository(ref.watch(databaseProvider))/StatementRepository(ref.watch(databaseProvider), ref)/g' lib/core/providers.dart
