import 'package:drift/drift.dart';
import '../core/database/database.dart';

class SettingsRepository {
  final AppDatabase _db;
  final void Function() onSettingsChanged;

  SettingsRepository(this._db, this.onSettingsChanged);

  Future<ShopSetting> getSettings() {
    return _db.getShopSettings();
  }

  Future<void> updateSettings({
    String? shopName,
    String? address,
    String? phone,
    String? email,
    String? invoicePrefix,
    String? receiptPrefix,
    String? txnPrefix,
    String? terms,
    String? appPin,
    String? backupDirectory,
    String? invoicesDirectory,
  }) async {
    final s = await _db.getShopSettings();
    await _db.updateShopSettings(
      ShopSettingsCompanion(
        id: Value(s.id),
        shopName: shopName != null
            ? Value(shopName.trim())
            : const Value.absent(),
        address: address != null ? Value(address.trim()) : const Value.absent(),
        phone: phone != null ? Value(phone.trim()) : const Value.absent(),
        email: email != null
            ? Value(email.trim().isEmpty ? null : email.trim())
            : const Value.absent(),
        invoicePrefix: invoicePrefix != null
            ? Value(invoicePrefix)
            : const Value.absent(),
        receiptPrefix: receiptPrefix != null
            ? Value(receiptPrefix)
            : const Value.absent(),
        txnPrefix: txnPrefix != null ? Value(txnPrefix) : const Value.absent(),
        terms: terms != null ? Value(terms.trim()) : const Value.absent(),
        appPin: appPin != null
            ? Value(appPin.isEmpty ? null : appPin)
            : const Value.absent(),
        backupDirectory: backupDirectory != null
            ? Value(backupDirectory.isEmpty ? null : backupDirectory)
            : const Value.absent(),
        invoicesDirectory: invoicesDirectory != null
            ? Value(invoicesDirectory.isEmpty ? null : invoicesDirectory)
            : const Value.absent(),
      ),
    );
    onSettingsChanged();
  }

  Future<void> markFirstRunCompleted() async {
    final s = await _db.getShopSettings();
    await _db.updateShopSettings(
      ShopSettingsCompanion(
        id: Value(s.id),
        isFirstRunCompleted: const Value(true),
      ),
    );
    onSettingsChanged();
  }

  Future<void> updateLastBackupDate(String dateStr) async {
    final s = await _db.getShopSettings();
    await _db.updateShopSettings(
      ShopSettingsCompanion(
        id: Value(s.id),
        lastAutoBackupDate: Value(dateStr),
      ),
    );
    onSettingsChanged();
  }
}
