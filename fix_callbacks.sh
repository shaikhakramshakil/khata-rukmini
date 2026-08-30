#!/bin/bash
# SettingsRepository
sed -i 's/SettingsRepository(this._db);/final void Function() onSettingsChanged;\n\n  SettingsRepository(this._db, this.onSettingsChanged);/' lib/repositories/settings_repository.dart
# PartyRepository
sed -i 's/PartyRepository(this._db);/final void Function(String? partyId) onPartyChanged;\n\n  PartyRepository(this._db, this.onPartyChanged);/' lib/repositories/party_repository.dart
# TransactionRepository
sed -i 's/TransactionRepository(this._db);/final void Function(String? partyId) onTransactionChanged;\n\n  TransactionRepository(this._db, this.onTransactionChanged);/' lib/repositories/transaction_repository.dart

