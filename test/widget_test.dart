import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khata_rukmini/core/database/database.dart';
import 'package:khata_rukmini/core/providers.dart';
import 'package:khata_rukmini/main.dart';

void main() {
  testWidgets(
    'App smoke test - verifies AppShell renders on desktop viewport',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({
        'isLoggedIn': true,
        'admin_username': 'admin',
      });
      final prefs = await SharedPreferences.getInstance();

      final testDb = AppDatabase(NativeDatabase.memory());
      addTearDown(testDb.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWithValue(testDb),
          ],
          child: const JewelryKhataApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify main navigation items in fixed desktop sidebar
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Customers'), findsWidgets);
      expect(find.text('Suppliers'), findsWidgets);
      expect(find.text('Transactions'), findsWidgets);
      expect(find.text('Statements'), findsWidgets);
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Backup & Restore'), findsWidgets);
    },
  );
}
