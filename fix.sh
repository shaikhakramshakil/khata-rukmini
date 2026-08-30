sed -i 's/final AppDatabase _db;/final AppDatabase _db;\n\n  final void Function() onSettingsChanged;/g' lib/repositories/settings_repository.dart
sed -i '/SettingsRepository(this._db/ s/;/; this.onSettingsChanged(); /' lib/repositories/settings_repository.dart
